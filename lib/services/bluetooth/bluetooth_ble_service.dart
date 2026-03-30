
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../StateManagement/mqtt_payload_provider.dart';
import '../../utils/enums.dart';
import 'model/ble_bluetooth_device_model.dart';



class BluetoothBleService {
  static BluetoothBleService? _instance;
  BluetoothBleService._internal();
  VoidCallback? onDeviceFound;

  factory BluetoothBleService() {
    _instance ??= BluetoothBleService._internal();
    return _instance!;
  }

  /// ---------------- VARIABLES ----------------
  static const String serviceUuid = "12345678-1234-5678-1234-56789abcdef0";
  static const String writeUuid = "12345678-1234-5678-1234-56789abcdef1";
  static const String notifyUuid1 = "12345678-1234-5678-1234-56789abcdef2";
  static const String notifyUuid2 = "12345678-1234-5678-1234-56789abcdef4";
  static const String notifyUuid3 = "12345678-1234-5678-1234-56789abcdef6";

  static const List<String> notifyUuids = [
    notifyUuid1,
    notifyUuid2,
    notifyUuid3,
  ];

  static const List<String> writeUuids = [
    writeUuid,
    "12345678-1234-5678-1234-56789abcdef3",
    "12345678-1234-5678-1234-56789abcdef5",
  ];

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _notifySubscription;

  final List<BleBluetoothDeviceModel> _devices = [];
  MqttPayloadProvider? providerState;

  bool _isScanning = false;
  bool _writeReady = false;
  bool _isConnecting = false;
  bool _isReconnecting = false;
  bool _isAlreadyConnected = false;

  BleBluetoothDeviceModel? _connectedDevice;
  BluetoothCharacteristic? _writeChar;
  BluetoothCharacteristic? _notifyChar;

  Timer? _reconnectTimer;
  Timer? _keepAliveTimer;
  int _reconnectAttempts = 0;
  static const int MAX_RECONNECT_ATTEMPTS = 3;
  static const int KEEP_ALIVE_INTERVAL = 15;

  DateTime? _lastActivity;
  String? _currentDeviceId;

  // Buffer for parsing incoming data
  String _buffer = '';

  /// ---------------- INIT ----------------
  Future<void> initializeBleService({MqttPayloadProvider? state}) async {
    providerState = state;

    _adapterSubscription = FlutterBluePlus.adapterState.listen((adapterState) {
      debugPrint("🔵 BLE Bluetooth State: $adapterState");
      if (adapterState != BluetoothAdapterState.on) {
        debugPrint("⚠️ BLE Bluetooth is not on! State: $adapterState");
        if (_connectedDevice != null) {
          _resetConnection();
          providerState?.updateBleConnectedDeviceStatus(null);
          _stopKeepAlive();
        }
      }
    });

    debugPrint("✅ BLE Service Initialized with provider");
  }

  /// ---------------- PERMISSIONS ----------------
  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid) return true;

    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      debugPrint("📱 Android SDK Version: $sdkInt");

      final List<Permission> permissions = [];

      if (sdkInt >= 31) { // Android 12+
        permissions.addAll([
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.locationWhenInUse,
        ]);
      } else if (sdkInt >= 23) { // Android 6-11
        permissions.addAll([
          Permission.bluetooth,
          Permission.location,
        ]);
      } else { // Older Android versions
        permissions.add(Permission.bluetooth);
      }

      debugPrint("🔐 Requesting BLE permissions: ${permissions.map((p) => p.toString()).toList()}");

      final Map<Permission, PermissionStatus> statuses = await permissions.request();

      bool allGranted = true;
      for (var permission in permissions) {
        final status = statuses[permission];
        debugPrint("BLE Permission $permission: $status");

        if (status == null || !status.isGranted) {
          allGranted = false;

          if (status == PermissionStatus.permanentlyDenied) {
            debugPrint("⚠️ BLE Permission $permission is permanently denied");
            await openAppSettings();
            return false;
          }
        } else {
          debugPrint("✅ BLE Permission granted: $permission");
        }
      }

      if (!allGranted) {
        debugPrint("❌ Not all BLE permissions granted");
        return false;
      }

      debugPrint("✅ All BLE permissions granted successfully");
      return true;

    } catch (e) {
      debugPrint("❌ Error requesting BLE permissions: $e");
      return false;
    }
  }

  /// ---------------- CHECK BLUETOOTH ----------------
  Future<bool> checkBluetooth() async {
    if (!await FlutterBluePlus.isSupported) {
      debugPrint("❌ BLE not supported on this device");
      return false;
    }

    final state = await FlutterBluePlus.adapterState.first;
    debugPrint("📱 BLE Adapter State: $state");

    if (state != BluetoothAdapterState.on) {
      debugPrint("❌ BLE Bluetooth is not ON. Please enable Bluetooth");
      return false;
    }

    return true;
  }

  /// ---------------- START SCAN ----------------
  Future<void> startScan({String? deviceId}) async {
    debugPrint("🔍 Starting BLE scan process...");
    debugPrint("deviceNameFilter:$deviceId");

    if (_isScanning) {
      debugPrint("⚠️ BLE Scan already in progress");
      return;
    }

    debugPrint("📱 Requesting BLE permissions...");
    if (!await requestPermissions()) {
      debugPrint("❌ BLE Permissions not granted");
      return;
    }

    debugPrint("📱 Checking BLE Bluetooth...");
    if (!await checkBluetooth()) {
      debugPrint("❌ BLE Bluetooth not available");
      return;
    }

    debugPrint("🧹 Clearing previous BLE devices...");
    _devices.clear();
    try {
      providerState?.updateBlePairedDevices([]);
    } catch (e) {
      debugPrint("⚠️ Error updating BLE provider: $e");
    }

    debugPrint("🛑 Stopping any existing BLE scan...");
    await stopScan();

    _isScanning = true;
    debugPrint("🔍 BLE Scan Started - Looking for devices with service: $serviceUuid");

    try {
      await FlutterBluePlus.startScan(
        withServices: [Guid(serviceUuid)],
        timeout: const Duration(seconds: 15),
      );
      debugPrint("✅ BLE Scan started successfully");

      _scanSubscription = FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
        debugPrint("📡 Received ${results.length} BLE scan results");

        for (final r in results) {
          final device = r.device;
          final name = device.platformName;

          debugPrint("============ BLE DEVICE FOUND ============");
          debugPrint("Name: $name");
          debugPrint("ID: ${device.remoteId}");
          debugPrint("RSSI: ${r.rssi}");
          debugPrint("======================================");

          bool shouldAddDevice = false;

          if (deviceId != null && deviceId.isNotEmpty) {
            if (name.startsWith("NIA_")) {
              final deviceIdFromName = name.substring(4);
              if (deviceIdFromName == deviceId) {
                shouldAddDevice = true;
                debugPrint("✅ BLE Device matches filter: $deviceIdFromName == $deviceId");
              } else {
                debugPrint("❌ BLE Device filtered out: $deviceIdFromName != $deviceId");
              }
            } else {
              if (name == deviceId) {
                shouldAddDevice = true;
                debugPrint("✅ BLE Device matches direct filter: $name == $deviceId");
              } else {
                debugPrint("❌ BLE Device filtered out: $name != $deviceId");
              }
            }
          } else {
            shouldAddDevice = name.isNotEmpty;
            debugPrint("ℹ️ No filter applied, adding BLE device if name exists");
          }

          final exists = _devices.any((d) => d.deviceId == device.remoteId.str);

          if (!exists && shouldAddDevice) {
            debugPrint("➕ Adding new BLE device: $name");

            final newDevice = BleBluetoothDeviceModel(
              device: device,
              connectionState: BlueConnectionState.disconnected,
              rssi: r.rssi,
              name: name,
            );

            _devices.add(newDevice);

            final updatedDevices = List<BleBluetoothDeviceModel>.from(_devices);
            try {
              providerState?.updateBlePairedDevices(updatedDevices);
            } catch (e) {
              debugPrint("⚠️ Error updating BLE provider: $e");
            }
            onDeviceFound?.call();

            debugPrint("✅ BLE Device added successfully. Total devices: ${_devices.length}");
          }
        }
      });

      // Monitor scan completion
      FlutterBluePlus.isScanning.listen((isScanning) {
        if (!isScanning && _isScanning) {
          debugPrint("🛑 BLE Scan automatically stopped");
          _isScanning = false;
          _scanSubscription?.cancel();
          _scanSubscription = null;
        }
      });

    } catch (e) {
      debugPrint("❌ Error starting BLE scan: $e");
      _isScanning = false;
      rethrow;
    }
  }

  /// ---------------- STOP SCAN ----------------
  Future<void> stopScan() async {
    if (!_isScanning) {
      debugPrint("ℹ️ No active BLE scan to stop");
      return;
    }

    _isScanning = false;
    debugPrint("🛑 Stopping BLE Scan...");

    try {
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      await FlutterBluePlus.stopScan();
      debugPrint("✅ BLE Scan stopped successfully");
    } catch (e) {
      debugPrint("❌ Error stopping BLE scan: $e");
    }
  }

  /// ---------------- KEEP ALIVE MECHANISM ----------------
  void _startKeepAlive() {
    _stopKeepAlive();
    _keepAliveTimer = Timer.periodic(
        const Duration(seconds: KEEP_ALIVE_INTERVAL),
            (timer) async {
          if (_connectedDevice != null && _writeChar != null &&
              _connectedDevice!.connectionState == BlueConnectionState.connected) {
            if (_lastActivity != null &&
                DateTime.now().difference(_lastActivity!) > const Duration(seconds: 20)) {
              debugPrint("💓 Sending BLE keep-alive ping...");
              await write("2,status", silent: true);
            }
          } else {
            timer.cancel();
          }
        }
    );
  }

  void _stopKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
  }

  /// ---------------- CONNECT TO DEVICE ----------------
  Future<bool> connectToDevice(BleBluetoothDeviceModel d) async {
    // CRITICAL: Check if device is already connected
    if (_isAlreadyConnected || _connectedDevice != null) {
      debugPrint("✅ Device already connected! Using existing connection.");
      d.connectionState = BlueConnectionState.connected;
      _connectedDevice = d;
      _startKeepAlive();
      return true;
    }

    if (_isConnecting || _isReconnecting) {
      debugPrint("⚠️ BLE Connection already in progress");
      return false;
    }

    debugPrint("🔌 Attempting to connect to BLE device: ${d.deviceName} (ID: ${d.deviceId})");
    _currentDeviceId = d.deviceId;

    _isConnecting = true;
    _reconnectAttempts = 0;

    try {
      // Step 1: Request permissions
      if (!await requestPermissions()) {
        debugPrint("❌ BLE Permissions not granted");
        _isConnecting = false;
        return false;
      }

      // Step 2: Stop scanning BEFORE connecting
      await stopScan();
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 3: Clear any existing connection state
      await _clearConnectionState();

      // Step 4: Update UI state to CONNECTING
      d.connectionState = BlueConnectionState.connecting;
      try {
        providerState?.updateBleDeviceStatus(
            d.deviceId, BlueConnectionState.connecting.index);
        providerState?.updateBleConnectedDeviceStatus(null);
      } catch (e) {
        debugPrint("⚠️ Error updating BLE status: $e");
      }

      // Step 5: Check if we're already receiving data from this device
      // If we're getting JSON data, the device is already connected through some means
      if (_lastActivity != null &&
          DateTime.now().difference(_lastActivity!) < const Duration(seconds: 10)) {
        debugPrint("✅ Device appears to be already connected (receiving data)");
        _isAlreadyConnected = true;
        d.connectionState = BlueConnectionState.connected;
        _connectedDevice = d;
        _startKeepAlive();
        await _updateDeviceStatus(d.deviceId, BlueConnectionState.connected, d);
        _isConnecting = false;
        return true;
      }

      // Step 6: Try to connect without explicit bonding first
      debugPrint("🔗 Connecting to BLE ${d.deviceId}...");
      debugPrint("ℹ️ If a pairing dialog appears, please accept it");

      await d.device.connect(
        timeout: const Duration(seconds: 30),
        autoConnect: false,
        license: License.free,
      );

      debugPrint("✅ BLE Connected successfully");
      _lastActivity = DateTime.now();
      _isAlreadyConnected = true;

      // Step 7: Wait for connection to stabilize
      await Future.delayed(const Duration(seconds: 2));

      // Step 8: Request MTU
      final mtuSizes = [247, 185, 128, 64];

      for (var mtu in mtuSizes) {
        try {
          // Check if still connected
          final isConnected = await d.device.isConnected;
          if (!isConnected) {
            debugPrint("❌ Device disconnected before MTU request");
            break;
          }

          await d.device.requestMtu(mtu);
          debugPrint("✅ BLE MTU set to $mtu");
          break;
        } catch (e) {
          debugPrint("⚠️ BLE MTU $mtu request failed: $e");
          if (e.toString().contains('not connected')) {
            debugPrint("❌ Device disconnected during MTU negotiation");
            break;
          }
        }
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Step 9: Discover services
      _connectedDevice = d;
      _writeReady = false;

      debugPrint("🔍 Discovering BLE services...");
      bool servicesFound = await _discoverServicesWithRetry(d, maxRetries: 3);

      if (!servicesFound) {
        debugPrint("⚠️ BLE Custom service not found after retries");
        _showConfigurationInstructions();

        d.connectionState = BlueConnectionState.disconnected;
        providerState?.updateBleDeviceStatus(
            d.deviceId, BlueConnectionState.disconnected.index);
        providerState?.updateBleConnectedDeviceStatus(null);
        _isConnecting = false;
        _isAlreadyConnected = false;
        return false;
      }

      // Step 10: Set up connection monitoring
      await _setupConnectionMonitoring(d);

      // Step 11: Update final status to CONNECTED
      d.connectionState = BlueConnectionState.connected;
      try {
        providerState?.updateBleDeviceStatus(d.deviceId,
            BlueConnectionState.connected.index);
        providerState?.updateBleConnectedDeviceStatus(d);
      } catch (e) {
        debugPrint("⚠️ Error updating BLE final status: $e");
      }

      _startKeepAlive();

      debugPrint("✅ BLE Connection complete - Write: ${_writeChar != null}, Notify: ${_notifyChar != null}");
      _isConnecting = false;
      return true;

    } catch (e) {
      debugPrint("❌ BLE Connection Failed: $e");

      // Check for authentication failure
      if (e.toString().contains('AUTHENTICATION_FAILURE') || e.toString().contains('133')) {
        debugPrint("⚠️ Authentication required for this device");
        debugPrint("💡 Please ensure you:");
        debugPrint("   1. The device is not already connected to another phone");
        debugPrint("   2. Accept the pairing request when it appears");
        debugPrint("   3. Enter the correct pairing code (usually 0000 or 1234)");
        debugPrint("   4. If still failing, unpair the device in Bluetooth settings and try again");
      }

      d.connectionState = BlueConnectionState.disconnected;
      try {
        providerState?.updateBleDeviceStatus(
            d.deviceId,
            BlueConnectionState.disconnected.index);
        providerState?.updateBleConnectedDeviceStatus(null);
      } catch (e) {
        debugPrint("⚠️ Error updating BLE status: $e");
      }

      _resetConnection();
      _isConnecting = false;
      _isAlreadyConnected = false;
      return false;
    }
  }

  /// ---------------- SETUP CONNECTION MONITORING ----------------
  Future<void> _setupConnectionMonitoring(BleBluetoothDeviceModel d) async {
    _connectionSubscription = d.device.connectionState.listen((state) {
      debugPrint("📱 BLE Connection State: $state at ${DateTime.now()}");

      if (state == BluetoothConnectionState.disconnected) {
        debugPrint("🔌 BLE Device disconnected");
        _lastActivity = null;
        _stopKeepAlive();
        _isAlreadyConnected = false;

        // Update to disconnected state
        d.connectionState = BlueConnectionState.disconnected;
        _resetConnection();

        try {
          providerState?.updateBleDeviceStatus(
              d.deviceId,
              BlueConnectionState.disconnected.index);
          providerState?.updateBleConnectedDeviceStatus(null);
        } catch (e) {
          debugPrint("⚠️ Error updating BLE status: $e");
        }

        if (_currentDeviceId != null && !_isConnecting && !_isReconnecting) {
          _attemptReconnect(d);
        }
      } else if (state == BluetoothConnectionState.connected) {
        debugPrint("✅ BLE Device connected and stable");
        d.connectionState = BlueConnectionState.connected;
        _isAlreadyConnected = true;
        _startKeepAlive();
      } else if (state == BluetoothConnectionState.connecting) {
        d.connectionState = BlueConnectionState.connecting;
      }
    });
  }

  /// ---------------- UPDATE DEVICE STATUS ----------------
  Future<void> _updateDeviceStatus(String deviceId, BlueConnectionState state, BleBluetoothDeviceModel? device) async {
    try {
      providerState?.updateBleDeviceStatus(deviceId, state.index);
      if (device != null) {
        providerState?.updateBleConnectedDeviceStatus(device);
      } else if (state == BlueConnectionState.disconnected) {
        providerState?.updateBleConnectedDeviceStatus(null);
      }
    } catch (e) {
      debugPrint("⚠️ Error updating BLE status: $e");
    }
  }

  /// ---------------- WRITE METHOD ----------------
  Future<bool> write(String payload, {bool silent = false, int maxRetries = 3}) async {
    if (_writeChar == null) {
      if (!silent) debugPrint("❌ BLE write characteristic not available");
      return false;
    }

    if (!_writeReady) {
      if (!silent) debugPrint("⚠️ BLE write not ready, waiting...");
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (_connectedDevice == null ||
        _connectedDevice!.connectionState != BlueConnectionState.connected) {
      if (!silent) debugPrint("❌ BLE device not connected");
      return false;
    }

    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        final finalPayload = '*$payload#';
        final dataWithTerminator = '$finalPayload\r\n';
        final bytes = utf8.encode(dataWithTerminator);

        if (!silent) debugPrint("📤 [BLE] Sending: $finalPayload (Attempt ${attempts + 1})");

        await _writeChar!.write(bytes, withoutResponse: false);
        if (!silent) debugPrint("✅ [BLE] Sent successfully");

        _lastActivity = DateTime.now();
        await Future.delayed(const Duration(milliseconds: 100));
        return true;

      } catch (e) {
        attempts++;
        if (!silent) debugPrint("❌ [BLE] Write Error (Attempt $attempts): $e");

        if (attempts < maxRetries) {
          await Future.delayed(const Duration(milliseconds: 500));
          await _refreshCharacteristics();
        }
      }
    }

    if (!silent) debugPrint("❌ [BLE] Failed to write after $maxRetries attempts");
    return false;
  }

  /// ---------------- AUTO RECONNECT ----------------
  void _attemptReconnect(BleBluetoothDeviceModel d) {
    if (_reconnectTimer != null || _isReconnecting) return;

    if (_reconnectAttempts < MAX_RECONNECT_ATTEMPTS) {
      _reconnectAttempts++;
      _isReconnecting = true;
      debugPrint("🔄 BLE Auto-reconnect attempt $_reconnectAttempts/$MAX_RECONNECT_ATTEMPTS in 5 seconds...");

      _reconnectTimer = Timer(const Duration(seconds: 5), () async {
        _reconnectTimer = null;

        if (_connectedDevice == null && !_isConnecting) {
          await Future.delayed(const Duration(seconds: 2));

          final success = await connectToDevice(d);
          _isReconnecting = false;

          if (!success && _reconnectAttempts < MAX_RECONNECT_ATTEMPTS) {
            debugPrint("⚠️ BLE Reconnect failed, will retry on next disconnect");
          } else if (!success) {
            debugPrint("❌ BLE All reconnect attempts failed");
            _reconnectAttempts = 0;
            _currentDeviceId = null;
            _isAlreadyConnected = false;
          }
        } else {
          _isReconnecting = false;
        }
      });
    } else {
      debugPrint("❌ BLE Max reconnect attempts reached. Manual reconnect required.");
      _reconnectAttempts = 0;
      _currentDeviceId = null;
      _isReconnecting = false;
      _isAlreadyConnected = false;
    }
  }

  /// ---------------- CLEAR CONNECTION STATE ----------------
  Future<void> _clearConnectionState() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _stopKeepAlive();

    await _notifySubscription?.cancel();
    _notifySubscription = null;

    await _connectionSubscription?.cancel();
    _connectionSubscription = null;

    _writeChar = null;
    _notifyChar = null;
    _writeReady = false;

    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.device.disconnect();
        await Future.delayed(const Duration(milliseconds: 1000));
      } catch (e) {
        debugPrint("⚠️ Error disconnecting BLE: $e");
      }
      _connectedDevice = null;
    }

    _isAlreadyConnected = false;
  }

  /// ---------------- DISCOVER SERVICES WITH RETRY ----------------
  Future<bool> _discoverServicesWithRetry(BleBluetoothDeviceModel d, {int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      debugPrint("🔍 BLE Service discovery attempt $attempt/$maxRetries");

      try {
        // Check if still connected
        final isConnected = await d.device.isConnected;
        if (!isConnected) {
          debugPrint("❌ Device not connected during service discovery");
          return false;
        }

        final services = await d.device.discoverServices();
        debugPrint("📋 Found ${services.length} BLE services");

        for (var service in services) {
          debugPrint("BLE Service: ${service.uuid}");
        }

        bool foundCustomService = services.any(
                (s) => s.uuid.toString().toLowerCase() == serviceUuid.toLowerCase()
        );

        if (foundCustomService) {
          debugPrint("✅ Found BLE custom service on attempt $attempt");
          await _processServices(services);
          return true;
        }

        if (attempt < maxRetries) {
          debugPrint("⚠️ BLE Custom service not found, retrying in 1 second...");
          await Future.delayed(const Duration(seconds: 1));
        }

      } catch (e) {
        debugPrint("❌ BLE Service discovery attempt $attempt failed: $e");
        if (attempt < maxRetries) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }

    debugPrint("❌ BLE Custom service not found after $maxRetries attempts");
    return false;
  }

  /// ---------------- PROCESS SERVICES ----------------
  Future<void> _processServices(List<BluetoothService> services) async {
    for (var service in services) {
      if (service.uuid.toString().toLowerCase() == serviceUuid.toLowerCase()) {
        debugPrint("✅ BLE Target Service Found: ${service.uuid}");
        debugPrint("📊 Found ${service.characteristics.length} BLE characteristics");

        for (var char in service.characteristics) {
          final uuid = char.uuid.toString().toLowerCase();
          debugPrint("  BLE Characteristic: $uuid");
          debugPrint("    Properties: ${char.properties}");

          if (writeUuids.contains(uuid) && (char.properties.write || char.properties.writeWithoutResponse)) {
            if (_writeChar == null) {
              _writeChar = char;
              _writeReady = true;
              debugPrint("✅ BLE Write characteristic ready: $uuid");
            }
          }

          if (notifyUuids.contains(uuid) && char.properties.notify) {
            if (_notifyChar == null) {
              _notifyChar = char;
              debugPrint("✅ BLE Notify characteristic found: $uuid");

              try {
                await _notifyChar!.setNotifyValue(true);
                debugPrint("✅ BLE Notify enabled successfully");

                _notifySubscription = _notifyChar!.onValueReceived.listen((value) {
                  final response = String.fromCharCodes(value);
                  debugPrint("📩 BLE Device Response: $response");
                  _handleDeviceResponse(response);
                });
              } catch (e) {
                debugPrint("⚠️ Could not enable BLE notifications: $e");
              }
            }
          }
        }
      }
    }
  }

  /// ---------------- REFRESH CHARACTERISTICS ----------------
  Future<void> _refreshCharacteristics() async {
    if (_connectedDevice != null) {
      try {
        final services = await _connectedDevice!.device.discoverServices();
        await _processServices(services);
      } catch (e) {
        debugPrint("⚠️ Error refreshing BLE characteristics: $e");
      }
    }
  }

  /// ---------------- HANDLE DEVICE RESPONSE ----------------
  void _handleDeviceResponse(String response) {
    debugPrint("📱 Processing BLE device response: $response");
    _lastActivity = DateTime.now();

    // If we're receiving data, we must be connected
    if (!_isAlreadyConnected && _connectedDevice != null) {
      debugPrint("✅ Received data - marking as connected");
      _isAlreadyConnected = true;
      _connectedDevice!.connectionState = BlueConnectionState.connected;
    }

    _buffer += response;
    _parseBuffer();
  }

  /// ---------------- PARSE BUFFER ----------------
  void _parseBuffer() {
    debugPrint('BLE _buffer----> $_buffer');

    if (_buffer.isEmpty) return;

    while (_buffer.contains('*Start') && _buffer.contains('#End')) {
      final start = _buffer.indexOf('*Start');
      final end = _buffer.indexOf('#End', start);

      if (start != -1 && end != -1 && end > start) {
        final jsonString = _buffer.substring(start + 6, end).trim();
        _processData(jsonString);
        _buffer = _buffer.substring(end + 4);
      } else {
        break;
      }
    }
  }

  /// ---------------- PROCESS DATA ----------------
  void _processData(String jsonString) {
    debugPrint("BLE _processData call $jsonString");
    try {
      final data = json.decode(jsonString);
      final jsonStr = json.encode(data);

      providerState?.updateReceivedPayload(jsonStr, false);

      switch (data['mC'].toString()) {
        case '7300':
          final rawList = data["cM"]?["7301"]?["ListOfWifi"];
          final wifiStatus = data["cM"]?["7301"]?["Status"];
          final interfaceType = data["cM"]?["7301"]?["InterfaceType"];
          final ipAddress = data["cM"]?["7301"]?["IpAddress"];

          providerState?.updateWifiStatus(wifiStatus, false);
          providerState?.updateInterfaceType(interfaceType);
          providerState?.updateIpAddress(ipAddress);

          if (rawList is List) {
            final wifiList = rawList.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
            providerState?.updateWifiList(wifiList);
          }
          break;
        case '4200':
          final message = data['cM']?.entries.first.value['Message']?.trim();
          if (message != null) {
            providerState?.updateWifiMessage(message);
          }
          break;
        case '6600':
          providerState?.updateReceivedPayload(jsonStr, false);
          break;
        default:
          providerState?.updateReceivedPayload(jsonStr, true);
          break;
      }
    } catch (e) {
      debugPrint("Error parsing BLE JSON: $e");
    }
  }

  /// ---------------- SHOW CONFIGURATION INSTRUCTIONS ----------------
  void _showConfigurationInstructions() {
    debugPrint("""
  ═══════════════════════════════════════════════════════════
  📱 BLE DEVICE CONFIGURATION MODE REQUIRED
  ═══════════════════════════════════════════════════════════
  Please ensure your device is in configuration mode.
  """);
  }

  /// ---------------- DISCONNECT ----------------
  Future<void> disconnect(BleBluetoothDeviceModel d) async {
    debugPrint("🔌 Manually disconnecting from BLE device");
    _stopKeepAlive();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
    _isConnecting = false;
    _isReconnecting = false;
    _currentDeviceId = null;
    _lastActivity = null;
    _buffer = '';
    _isAlreadyConnected = false;

    try {
      await d.device.disconnect();
    } catch (e) {
      debugPrint("⚠️ Error during BLE disconnect: $e");
    }

    d.connectionState = BlueConnectionState.disconnected;
    _resetConnection();
    try {
      providerState?.updateBleConnectedDeviceStatus(null);
    } catch (e) {
      debugPrint("⚠️ Error updating BLE status: $e");
    }
  }

  /// ---------------- RESET ----------------
  void _resetConnection() {
    _stopKeepAlive();
    _writeReady = false;
    _writeChar = null;
    _notifyChar = null;
    _connectedDevice = null;
    _buffer = '';
    _notifySubscription?.cancel();
    _notifySubscription = null;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _isAlreadyConnected = false;
  }

  /// ---------------- RECONNECT ----------------
  Future<bool> reconnect() async {
    if (_connectedDevice == null) {
      debugPrint("❌ No BLE device to reconnect");
      return false;
    }

    debugPrint("🔄 Attempting to reconnect BLE...");
    return await connectToDevice(_connectedDevice!);
  }

  /// ---------------- DISPOSE ----------------
  Future<void> dispose() async {
    _stopKeepAlive();
    _reconnectTimer?.cancel();
    await stopScan();
    await _adapterSubscription?.cancel();
    _resetConnection();
  }

  /// ---------------- GETTERS ----------------
  List<BleBluetoothDeviceModel> get devices => _devices;

  bool get isConnected => _connectedDevice != null &&
      _writeChar != null &&
      _notifyChar != null &&
      _connectedDevice!.connectionState == BlueConnectionState.connected;

  bool get isWriteReady => _writeReady;
  BleBluetoothDeviceModel? get connectedDevice => _connectedDevice;
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  bool get isReconnecting => _isReconnecting;
  String? get currentDeviceId => _currentDeviceId;
  DateTime? get lastActivity => _lastActivity;
  bool get isAlreadyConnected => _isAlreadyConnected;
}

/*class BluetoothBleService {

  static BluetoothBleService? _instance;
  BluetoothBleService._internal();
  VoidCallback? onDeviceFound;

  factory BluetoothBleService() {
    _instance ??= BluetoothBleService._internal();
    return _instance!;
  }

  /// ---------------- VARIABLES ----------------
  static const String serviceUuid = "12345678-1234-5678-1234-56789abcdef0";
  static const String writeUuid = "12345678-1234-5678-1234-56789abcdef1";
  static const String notifyUuid = "12345678-1234-5678-1234-56789abcdef2";

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _notifySubscription;

  final List<BleBluetoothDeviceModel> _devices = [];
  MqttPayloadProvider? providerState;

  bool _isScanning = false;
  bool _writeReady = false;

  BleBluetoothDeviceModel? _connectedDevice;
  BluetoothCharacteristic? _writeChar;
  BluetoothCharacteristic? _notifyChar;

  /// ---------------- INIT ----------------
  Future<void> initializeBleService({required MqttPayloadProvider state}) async {
    providerState = state;

    _adapterSubscription =
        FlutterBluePlus.adapterState.listen((adapterState) {
          debugPrint("🔵 Bluetooth State: $adapterState");
          if (adapterState != BluetoothAdapterState.on) {
            debugPrint("⚠️ Bluetooth is not on! State: $adapterState");
          }
        });
  }

  /// ---------------- PERMISSIONS ----------------
  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    final permissions = [
      if (sdkInt >= 31) ...[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
      ] else
        Permission.bluetooth,
      Permission.location,
    ];

    final result = await permissions.request();

    bool allGranted = true;
    for (var permission in permissions) {
      final status = await permission.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        debugPrint("❌ Permission denied: $permission");
        allGranted = false;
      } else {
        debugPrint("✅ Permission granted: $permission");
      }
    }

    if (!allGranted) {
      debugPrint("❌ Not all permissions granted");
      return false;
    }

    return true;
  }

  /// ---------------- CHECK BLUETOOTH ----------------
  Future<bool> checkBluetooth() async {
    if (!await FlutterBluePlus.isSupported) {
      debugPrint("❌ BLE not supported on this device");
      return false;
    }

    final state = await FlutterBluePlus.adapterState.first;
    debugPrint("📱 Bluetooth Adapter State: $state");

    if (state != BluetoothAdapterState.on) {
      debugPrint("❌ Bluetooth is not ON. Please enable Bluetooth");
      return false;
    }

    return true;
  }

  /// ---------------- START SCAN ----------------
  Future<void> startScan({
    String? deviceNameFilter,
    String? macAddressFilter,
    Duration? timeout,
  }) async {
    debugPrint("🔍 Starting scan process...");
    debugPrint("🔍 Using device name filter: $deviceNameFilter");
    debugPrint("🔍 Using MAC address filter: $macAddressFilter");

    if (_isScanning) {
      debugPrint("⚠️ Scan already in progress");
      return;
    }

    debugPrint("📱 Requesting permissions...");
    if (!await requestPermissions()) {
      debugPrint("❌ Permissions not granted");
      return;
    }

    debugPrint("📱 Checking Bluetooth...");
    if (!await checkBluetooth()) {
      debugPrint("❌ Bluetooth not available");
      return;
    }

    debugPrint("🧹 Clearing previous devices...");
    _devices.clear();
    providerState?.updateBlePairedDevices([]);

    debugPrint("🛑 Stopping any existing scan...");
    await stopScan();

    _isScanning = true;
    debugPrint("🔍 BLE Scan Started - Looking for devices with service: $serviceUuid");

    try {
      await FlutterBluePlus.startScan(
        withServices: [Guid(serviceUuid)],
        timeout: timeout ?? const Duration(seconds: 15),
      );
      debugPrint("✅ Scan started successfully");

      _scanSubscription = FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
        debugPrint("📡 Received ${results.length} scan results");

        for (final r in results) {
          final device = r.device;
          final name = device.platformName;
          final macAddress = device.remoteId.str;
          final macAddressNoColons = macAddress.replaceAll(":", "").toUpperCase();

          debugPrint("============ DEVICE FOUND ============");
          debugPrint("Name: $name");
          debugPrint("MAC Address: $macAddress");
          debugPrint("MAC (no colons): $macAddressNoColons");
          debugPrint("RSSI: ${r.rssi}");
          debugPrint("======================================");

          *//*bool shouldInclude = true;

          if (deviceNameFilter != null && deviceNameFilter.isNotEmpty) {
            if (name.isEmpty) {
              debugPrint("⏭️ Skipping device - no name provided");
              shouldInclude = false;
            } else {
              final nameLower = name.toLowerCase();
              final filterLower = deviceNameFilter.toLowerCase();

              if (!nameLower.contains(filterLower)) {
                debugPrint("⏭️ Skipping device - name '$name' doesn't contain filter '$deviceNameFilter'");
                shouldInclude = false;
              } else {
                debugPrint("✅ Device name matches filter: $name");
              }
            }
          }

          if (shouldInclude && macAddressFilter != null && macAddressFilter.isNotEmpty) {
            final filterMac = macAddressFilter.replaceAll(":", "").toUpperCase();
            final deviceMac = macAddressNoColons;

            if (deviceMac.contains(filterMac) || filterMac.contains(deviceMac)) {
              debugPrint("✅ Device MAC address matches filter: $macAddress");
            } else {
              debugPrint("⏭️ Skipping device - MAC address '$macAddress' doesn't match filter '$macAddressFilter'");
              shouldInclude = false;
            }
          }

          if (!shouldInclude) {
            continue;
          }*//*

          final exists = _devices.any((d) => d.device.remoteId.str == device.remoteId.str);

          if (!exists) {
            debugPrint("➕ Adding new device: $name ($macAddress)");

            final newDevice = BleBluetoothDeviceModel(
              device: device,
              connectionState: BlueConnectionState.disconnected,
            );

            _devices.add(newDevice);

            final updatedDevices = List<BleBluetoothDeviceModel>.from(_devices);
            providerState?.updateBlePairedDevices(updatedDevices);
            onDeviceFound?.call();

            debugPrint("✅ Device added successfully. Total devices: ${_devices.length}");
          } else {
            debugPrint("⏭️ Device already in list: $name");
          }
        }
      });

      FlutterBluePlus.isScanning.listen((isScanning) {
        if (!isScanning && _isScanning) {
          debugPrint("🛑 BLE Scan automatically stopped");
          _isScanning = false;
          _scanSubscription?.cancel();
          _scanSubscription = null;
        }
      });

    } catch (e) {
      debugPrint("❌ Error starting scan: $e");
      _isScanning = false;
      rethrow;
    }
  }

  /// ---------------- STOP SCAN ----------------
  Future<void> stopScan() async {
    if (!_isScanning) {
      debugPrint("ℹ️ No active scan to stop");
      return;
    }

    _isScanning = false;
    debugPrint("🛑 Stopping BLE Scan...");

    try {
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      await FlutterBluePlus.stopScan();
      debugPrint("✅ BLE Scan stopped successfully");
    } catch (e) {
      debugPrint("❌ Error stopping scan: $e");
    }
  }

  /// ---------------- CONNECT ----------------
  Future<void> connectToDevice(BleBluetoothDeviceModel d) async {
    debugPrint("🔌 Attempting to connect to device: ${d.device.platformName}");

    try {
      await requestPermissions();
      await FlutterBluePlus.stopScan();

      providerState?.updateBleDeviceStatus(
          d.device.remoteId.str, BlueConnectionState.connecting.index);

      debugPrint("🔗 Connecting to ${d.device.remoteId.str}...");
      await d.device.connect(
        timeout: const Duration(seconds: 25),
        autoConnect: false,
        license: License.free,
      );
      debugPrint("✅ Connected successfully");

      _connectedDevice = d;
      _writeReady = false;

      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint("📡 Requesting MTU 247...");
      await d.device.requestMtu(247);
      debugPrint("✅ MTU request sent");

      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint("🔍 Discovering services...");
      await _discoverServices(d);

      if (_writeChar == null) {
        debugPrint("⚠️ Write characteristic not found!");
      }

      if (_notifyChar == null) {
        debugPrint("⚠️ Notify characteristic not found or couldn't be enabled");
        debugPrint("⚠️ Device will still be connected but notifications won't work");
      }

      _connectionSubscription = d.device.connectionState.listen((state) {
        debugPrint("📱 Connection State: $state");
        if (state == BluetoothConnectionState.disconnected) {
          debugPrint("🔌 Device disconnected");
          _resetConnection();
          providerState?.updateBleDeviceStatus(
              d.device.remoteId.str,
              BlueConnectionState.disconnected.index);
        }
      });

      providerState?.updateBleDeviceStatus(d.device.remoteId.str,
          BlueConnectionState.connected.index);
      providerState?.updateBleConnectedDeviceStatus(d);

      debugPrint("✅ Connection complete");
      debugPrint("📊 Connection status - Write: ${_writeChar != null}, Notify: ${_notifyChar != null}");

    } catch (e) {
      debugPrint("❌ BLE Connection Failed: $e");
      _resetConnection();
    }
  }

  /// ---------------- DISCOVER SERVICES ----------------
  Future<void> _discoverServices(BleBluetoothDeviceModel d) async {
    debugPrint("🔍 Discovering services for ${d.device.platformName}...");

    final services = await d.device.discoverServices();
    debugPrint("📋 Found ${services.length} services");

    for (var service in services) {
      debugPrint("Service: ${service.uuid}");

      if (service.uuid.toString().toLowerCase() == serviceUuid.toLowerCase()) {
        debugPrint("✅ Target Service Found: ${service.uuid}");

        // Debug all characteristics
        for (var char in service.characteristics) {
          final uuid = char.uuid.toString().toLowerCase();
          debugPrint("  Characteristic: $uuid");
          debugPrint("    Properties: ${char.properties}");
          debugPrint("    Descriptors: ${char.descriptors.length}");

          for (var desc in char.descriptors) {
            debugPrint("      Descriptor: ${desc.uuid}");
          }
        }

        // Find write characteristic
        for (var char in service.characteristics) {
          final uuid = char.uuid.toString().toLowerCase();
          if (uuid == writeUuid.toLowerCase()) {
            _writeChar = char;
            _writeReady = true;
            debugPrint("✅ Write characteristic ready: $uuid");
            break;
          }
        }

        // Setup notify characteristic
        await _setupNotifyCharacteristic(service);
      }
    }
  }

  /// ---------------- SETUP NOTIFY CHARACTERISTIC ----------------
  Future<void> _setupNotifyCharacteristic(BluetoothService service) async {
    debugPrint("🔔 Setting up notify characteristic...");

    List<BluetoothCharacteristic> notifyCharacteristics = [];

    for (var char in service.characteristics) {
      final uuid = char.uuid.toString().toLowerCase();
      if (char.properties.notify) {
        notifyCharacteristics.add(char);
        debugPrint("📋 Found notify characteristic: $uuid");
        debugPrint("   Descriptors count: ${char.descriptors.length}");

        for (var desc in char.descriptors) {
          debugPrint("     Descriptor UUID: ${desc.uuid}");
        }
      }
    }

    if (notifyCharacteristics.isEmpty) {
      debugPrint("⚠️ No notify characteristics found");
      return;
    }

    // Try each notify characteristic
    for (var char in notifyCharacteristics) {
      final uuid = char.uuid.toString().toLowerCase();
      debugPrint("🔍 Trying to enable notifications for: $uuid");

      // Add a small delay between attempts
      await Future.delayed(const Duration(milliseconds: 300));

      try {
        bool success = await _enableNotificationsWithFallback(char, service);

        if (success && _notifyChar != null) {
          _notifySubscription = _notifyChar!.onValueReceived.listen((value) {
            final response = String.fromCharCodes(value);
            debugPrint("📩 Device Response: $response");
            _handleDeviceResponse(response);
          });
          debugPrint("✅ Notify enabled successfully for $uuid");
          return;
        }
      } catch (e) {
        debugPrint("❌ Failed to enable notifications for $uuid: $e");
      }
    }

    debugPrint("❌ Could not enable notifications on any characteristic");
  }

  /// ---------------- ENABLE NOTIFICATIONS WITH FALLBACK ----------------
  Future<bool> _enableNotificationsWithFallback(BluetoothCharacteristic characteristic, BluetoothService service) async {
    // Find the CCCD descriptor
    BluetoothDescriptor? cccdDescriptor;

    debugPrint("🔍 Looking for CCCD descriptor in ${characteristic.descriptors.length} descriptors");

    for (var desc in characteristic.descriptors) {
      final descUuid = desc.uuid.toString().toLowerCase();
      debugPrint("  Checking descriptor: $descUuid");

      if (descUuid == "2902" ||
          descUuid == "00002902-0000-1000-8000-00805f9b34fb") {
        cccdDescriptor = desc;
        debugPrint("✅ Found CCCD descriptor! UUID: $descUuid");
        break;
      }
    }

    // APPROACH 1: Try listening without enabling (if device sends automatically)
    try {
      debugPrint("📝 Trying to listen without explicit enable...");
      _notifyChar = characteristic;
      _notifySubscription = _notifyChar!.onValueReceived.listen((value) {
        final response = String.fromCharCodes(value);
        debugPrint("📩 Device Response: $response");
        _handleDeviceResponse(response);
      });
      debugPrint("✅ Listening without explicit enable (device may auto-notify)");
      return true;
    } catch (e) {
      debugPrint("❌ Auto-listen failed: $e");
    }

    if (cccdDescriptor == null) {
      debugPrint("⚠️ No CCCD descriptor found - trying setNotifyValue anyway");
      try {
        await characteristic.setNotifyValue(true);
        _notifyChar = characteristic;
        debugPrint("✅ setNotifyValue successful (no CCCD)");
        return true;
      } catch (e) {
        debugPrint("❌ setNotifyValue failed: $e");
        return false;
      }
    }

    // APPROACH 2: Try reading the characteristic first (some devices need this)
    if (characteristic.properties.read) {
      try {
        debugPrint("📝 Attempting to read characteristic first...");
        await characteristic.read();
        await Future.delayed(const Duration(milliseconds: 100));

        debugPrint("📝 Writing to CCCD after read...");
        await cccdDescriptor.write([0x01, 0x00]);
        await Future.delayed(const Duration(milliseconds: 200));

        _notifyChar = characteristic;
        debugPrint("✅ Notify enabled after read");
        return true;
      } catch (e) {
        debugPrint("❌ Read-then-write approach failed: $e");
      }
    }

    // APPROACH 3: Try with a longer delay
    try {
      debugPrint("📝 Waiting longer before CCCD write...");
      await Future.delayed(const Duration(milliseconds: 500));

      await cccdDescriptor.write([0x01, 0x00]);
      await Future.delayed(const Duration(milliseconds: 200));

      _notifyChar = characteristic;
      debugPrint("✅ Notify enabled after delay");
      return true;
    } catch (e) {
      debugPrint("❌ Delayed write failed: $e");
    }

    // APPROACH 4: Try writing with different values
    try {
      debugPrint("📝 Trying different CCCD values...");

      // Try with reversed byte order
      await cccdDescriptor.write([0x00, 0x01]);
      await Future.delayed(const Duration(milliseconds: 200));

      _notifyChar = characteristic;
      debugPrint("✅ Notify enabled with reversed bytes");
      return true;
    } catch (e) {
      debugPrint("❌ Reversed bytes failed: $e");
    }

    // APPROACH 5: Try indications instead of notifications
    try {
      debugPrint("📝 Trying to enable indications...");
      await cccdDescriptor.write([0x02, 0x00]); // Indications
      await Future.delayed(const Duration(milliseconds: 200));

      _notifyChar = characteristic;
      debugPrint("✅ Indications enabled successfully");
      return true;
    } catch (e) {
      debugPrint("❌ Indications failed: $e");
    }

    // APPROACH 6: Try both notifications and indications
    try {
      debugPrint("📝 Trying both notifications and indications...");
      await cccdDescriptor.write([0x03, 0x00]); // Both
      await Future.delayed(const Duration(milliseconds: 200));

      _notifyChar = characteristic;
      debugPrint("✅ Both notifications and indications enabled");
      return true;
    } catch (e) {
      debugPrint("❌ Both failed: $e");
    }

    // APPROACH 7: Try setNotifyValue
    try {
      debugPrint("📝 Attempting setNotifyValue...");
      await characteristic.setNotifyValue(true);
      _notifyChar = characteristic;
      debugPrint("✅ setNotifyValue successful");
      return true;
    } catch (e) {
      debugPrint("❌ setNotifyValue failed: $e");
    }

    // APPROACH 8: Try writing to a control characteristic first if exists
    try {
      debugPrint("📝 Looking for control characteristic...");
      for (var c in service.characteristics) {
        if (c.properties.write || c.properties.writeWithoutResponse) {
          if (c.uuid != characteristic.uuid) {
            debugPrint("📝 Writing to control characteristic: ${c.uuid}");
            await c.write([0x01], withoutResponse: true);
            await Future.delayed(const Duration(milliseconds: 100));

            await cccdDescriptor.write([0x01, 0x00]);
            await Future.delayed(const Duration(milliseconds: 200));

            _notifyChar = characteristic;
            debugPrint("✅ Notify enabled after control write");
            return true;
          }
        }
      }
    } catch (e) {
      debugPrint("❌ Control characteristic approach failed: $e");
    }

    debugPrint("❌ All notification enabling methods failed for ${characteristic.uuid}");
    return false;
  }

  /// ---------------- HANDLE DEVICE RESPONSE ----------------
  void _handleDeviceResponse(String response) {
    debugPrint("📱 Processing device response: $response");
    // Add your response handling logic here
  }


  /// ---------------- WRITE NORMAL (Enhanced) ----------------
  Future<void> write(String payload, {bool withResponse = true}) async {
    debugPrint("📤 Attempting to write: $payload");

    // First, prepare for write
    bool isReady = await prepareWrite();
    if (!isReady) {
      debugPrint("❌ Cannot write: device not ready");
      return;
    }

    try {
      // Convert string to bytes
      final finalPayload = '*$payload#';
      List<int> bytes = finalPayload.codeUnits;
      debugPrint("📤 Sending: $finalPayload");
      debugPrint("📤 Bytes: $bytes");
      debugPrint("📤 Length: ${bytes.length} bytes");

      // Try to write with the appropriate method
      if (withResponse && _writeChar!.properties.write) {
        // Use write with response
        await _writeChar!.write(bytes, withoutResponse: false);
        debugPrint("✅ Message sent successfully (with response)");
      } else if (_writeChar!.properties.writeWithoutResponse) {
        // Use write without response
        await _writeChar!.write(bytes, withoutResponse: true);
        debugPrint("✅ Message sent successfully (without response)");
      } else {
        debugPrint("❌ No suitable write method available");
        debugPrint("   Available properties: ${_writeChar!.properties}");
      }

    } catch (e) {
      debugPrint("❌ Write Error: $e");
      // Try fallback: write without response
      if (withResponse) {
        debugPrint("⚠️ Retrying without response...");
        try {
          final finalPayload = '*$payload#';
          List<int> fallbackBytes = finalPayload.codeUnits;
          await _writeChar!.write(fallbackBytes, withoutResponse: true);
          debugPrint("✅ Message sent successfully (fallback)");
        } catch (e2) {
          debugPrint("❌ Fallback also failed: $e2");
        }
      }
    }
  }

  /// ---------------- WRITE WITH NEWLINE ----------------
  Future<void> writeWithNewline(String data) async {
    await write("$data\r\n");
  }

  /// ---------------- PREPARE WRITE ----------------
  Future<bool> prepareWrite() async {
    if (_writeChar == null) {
      debugPrint("❌ Write characteristic not available");
      return false;
    }

    if (_connectedDevice == null) {
      debugPrint("❌ No device connected");
      return false;
    }

    try {
      // Check connection state
      final connectionState = await _connectedDevice!.device.connectionState.first;
      if (connectionState != BluetoothConnectionState.connected) {
        debugPrint("❌ Device not connected. State: $connectionState");
        return false;
      }

      // Verify characteristic properties
      if (!_writeChar!.properties.write && !_writeChar!.properties.writeWithoutResponse) {
        debugPrint("❌ Write characteristic does not support writing!");
        debugPrint("   Properties: ${_writeChar!.properties}");
        return false;
      }

      debugPrint("✅ Write characteristic ready for writing");
      debugPrint("   UUID: ${_writeChar!.uuid}");
      debugPrint("   Properties: ${_writeChar!.properties}");
      return true;

    } catch (e) {
      debugPrint("❌ Error preparing write: $e");
      return false;
    }
  }

  /// ---------------- WRITE WIFI ----------------
  Future<void> writeWifiCredentials(String ssid, String password) async {
    if (_writeChar == null) {
      debugPrint("❌ Write characteristic not available");
      return;
    }

    final payload = "$ssid,$password\n";
    final bytes = payload.codeUnits;
    const int maxChunk = 20;

    debugPrint("📤 Sending WiFi credentials (${bytes.length} bytes)");

    for (int i = 0; i < bytes.length; i += maxChunk) {
      int end = (i + maxChunk > bytes.length) ? bytes.length : i + maxChunk;
      List<int> chunk = bytes.sublist(i, end);

      await _writeChar!.write(chunk, withoutResponse: false);
      debugPrint("  Sent chunk ${(i ~/ maxChunk) + 1}: ${String.fromCharCodes(chunk)}");
      await Future.delayed(const Duration(milliseconds: 50));
    }

    debugPrint("✅ WiFi credentials sent successfully");
  }

  /// ---------------- DISCONNECT ----------------
  Future<void> disconnect(BleBluetoothDeviceModel d) async {
    await d.device.disconnect();
    _resetConnection();
    providerState?.updateBleConnectedDeviceStatus(null);
  }

  /// ---------------- RESET ----------------
  void _resetConnection() {
    _writeReady = false;
    _writeChar = null;
    _notifyChar = null;
    _connectedDevice = null;
    _notifySubscription?.cancel();
    _notifySubscription = null;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
  }

  /// ---------------- DISPOSE ----------------
  Future<void> dispose() async {
    await stopScan();
    await _adapterSubscription?.cancel();
    _resetConnection();
  }

  /// ---------------- GETTERS ----------------
  List<BleBluetoothDeviceModel> get devices => _devices;
  bool get isConnected => _connectedDevice != null && _writeChar != null && _notifyChar != null;
}*/
