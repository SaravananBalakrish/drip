import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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
          debugPrint("Bluetooth State: $adapterState");
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

    if (result.values.any(
            (status) => status.isDenied || status.isPermanentlyDenied)) {
      debugPrint("Permissions not granted");
      return false;
    }

    return true;
  }

  /// ---------------- CHECK BLUETOOTH ----------------
  Future<bool> checkBluetooth() async {
    if (!await FlutterBluePlus.isSupported) return false;

    final state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }

  /// ---------------- START SCAN ----------------
  Future<void> startScan({String? deviceNameFilter}) async {
    if (_isScanning) return;

    if (!await requestPermissions()) return;
    if (!await checkBluetooth()) return;

    _devices.clear();
    providerState?.updateBlePairedDevices([]);

    await stopScan();

    _isScanning = true;
    debugPrint("BLE Scan Started");

    await FlutterBluePlus.startScan(
      withServices: [Guid(serviceUuid)],
      timeout: const Duration(seconds: 10),
    );

    //await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    _scanSubscription =
        FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
          for (final r in results) {
            final device = r.device;
            final name = device.platformName;

            if (deviceNameFilter != null &&
                !name.toLowerCase().contains(deviceNameFilter.toLowerCase())) {
              continue;
            }

            final exists = _devices
                .any((d) => d.device.remoteId.str == device.remoteId.str);

            if (!exists) {
              final newDevice = BleBluetoothDeviceModel(
                device: device,
                connectionState: BlueConnectionState.disconnected,
              );

              _devices.add(newDevice);
              providerState?.updateBlePairedDevices(List.from(_devices));
              onDeviceFound?.call();
            }
          }
        });

    await Future.delayed(const Duration(seconds: 10));
    await stopScan();
  }

  /// ---------------- STOP SCAN ----------------
  Future<void> stopScan() async {
    if (!_isScanning) return;

    _isScanning = false;
    debugPrint("BLE Scan Stopped");

    await _scanSubscription?.cancel();
    _scanSubscription = null;

    await FlutterBluePlus.stopScan();
  }

  /// ---------------- CONNECT ----------------
  Future<void> connectToDevice(BleBluetoothDeviceModel d) async {
    try {
      await requestPermissions();
      await FlutterBluePlus.stopScan();

      providerState?.updateBleDeviceStatus(
          d.device.remoteId.str, BlueConnectionState.connecting.index);

      // 🔹 CONNECT
      await d.device.connect(
<<<<<<< HEAD
        timeout: const Duration(seconds: 25),
        autoConnect: false,
=======
        timeout: const Duration(seconds: 15),
        autoConnect: false, license: License.free,
>>>>>>> a991a6b49bf4854b75ab7ca3ad4b0cb0257e2a9c
      );

      _connectedDevice = d;
      _writeReady = false;

      // 🔹 WAIT SMALL DELAY (VERY IMPORTANT)
      await Future.delayed(const Duration(milliseconds: 500));

      // 🔹 REQUEST MTU
      await d.device.requestMtu(247);

      await Future.delayed(const Duration(milliseconds: 500));

      // 🔹 DISCOVER SERVICES (ONLY ONCE)
      await _discoverServices(d);

      if (!isConnected) {
        throw Exception("❌ BLE setup incomplete");
      }

      // 🔹 NOW listen for disconnect only
      _connectionSubscription = d.device.connectionState.listen((state) {
            debugPrint("BLE STATE: $state");

            if (state == BluetoothConnectionState.disconnected) {
              _resetConnection();
              providerState?.updateBleDeviceStatus(
                  d.device.remoteId.str,
                  BlueConnectionState.disconnected.index);
            }
          });

      providerState?.updateBleDeviceStatus(d.device.remoteId.str,
          BlueConnectionState.connected.index);

      providerState?.updateBleConnectedDeviceStatus(d);

    } catch (e) {
      debugPrint("BLE Connection Failed: $e");
      _resetConnection();
    }
  }

  /// ---------------- DISCOVER SERVICES ----------------
  Future<void> _discoverServices(BleBluetoothDeviceModel d) async {
    final services = await d.device.discoverServices();

    for (var service in services) {
      if (service.uuid.toString().toLowerCase() == "12345678-1234-5678-1234-56789abcdef0") {

        debugPrint("✅ Target Service Found");

        for (var char in service.characteristics) {

          final uuid = char.uuid.toString().toLowerCase();

          debugPrint("Characteristic: $uuid");
          debugPrint("Properties: ${char.properties}");

          /// 🔹 WRITE CHAR
          if (uuid == "12345678-1234-5678-1234-56789abcdef1") {
            _writeChar = char;
            _writeReady = true;
            debugPrint("✅ Write characteristic ready");
          }

          if (uuid == "12345678-1234-5678-1234-56789abcdef2") {
            _notifyChar = char;

            if (_notifyChar!.properties.notify) {
              try {
                await _notifyChar!.setNotifyValue(true);
                debugPrint("✅ Notify enabled successfully");
              } catch (e) {
                debugPrint("❌ Notify failed: $e");
                debugPrint("⚠️ Continuing without crash...");
              }
            }

            await Future.delayed(const Duration(milliseconds: 300));

            _notifySubscription =
                _notifyChar!.onValueReceived.listen((value) {
                  final response = String.fromCharCodes(value);
                  debugPrint("📩 Device Response: $response");
                });
          }

          /// 🔹 NOTIFY CHAR
          /*if (uuid == "12345678-1234-5678-1234-56789abcdef2") {
            _notifyChar = char;

            /// 🔥 ENABLE NOTIFY HERE
            if (_notifyChar!.properties.notify) {
              await _notifyChar!.setNotifyValue(true);
            }

            /// 🔥 IMPORTANT DELAY (BlueZ needs this)
            await Future.delayed(const Duration(milliseconds: 300));

            _notifySubscription =
                _notifyChar!.onValueReceived.listen((value) {
                  final response = String.fromCharCodes(value);
                  debugPrint("📩 Device Response: $response");
                });



            debugPrint("✅ Notify enabled");
          }*/
        }
      }
    }

    if (_writeChar != null && _notifyChar != null) {
      //isConnected = true;
    }
  }
  /*Future<void> _discoverServices(BleBluetoothDeviceModel d) async {
    final services = await d.device.discoverServices();

    for (final service in services) {
      if (service.uuid.toString().toLowerCase() == serviceUuid) {
        debugPrint("✅ Target Service Found");

        for (final char in service.characteristics) {
          final uuid = char.uuid.toString().toLowerCase();

          for (final char in service.characteristics) {
            debugPrint("Characteristic: ${char.uuid}");
            debugPrint("Characteristic properties: ${char.properties}");
            for (final desc in char.descriptors) {
              debugPrint("  Descriptor: ${desc.uuid}");
            }
          }

          /// WRITE (App → Device)
          if (uuid == writeUuid) {
            _writeChar = char;
            debugPrint("✅ Write characteristic ready");
          }

          /// NOTIFY (Device → App)
          if (uuid == notifyUuid) {
            _notifyChar = char;

            if (_notifyChar!.properties.notify) {
              await _notifyChar!.setNotifyValue(true);
            }

            _notifySubscription =
                _notifyChar!.onValueReceived.listen((value) {
                  final response = String.fromCharCodes(value);
                  debugPrint("📩 Device Response: $response");
                });

            debugPrint("✅ Notify enabled");
          }
        }
      }
    }

    /// FINAL VALIDATION
    if (_writeChar == null || _notifyChar == null) {
      throw Exception("❌ Required characteristics not found");
    }
  }*/

  /// ---------------- WRITE NORMAL ----------------
  Future<void> write(String data) async {
    if (!isConnected) {
      debugPrint("❌ Not connected properly");
      return;
    }

    try {
      await _writeChar!.write(
        data.codeUnits,
        withoutResponse: false,
      );

      debugPrint("📤 Sent: $data");
    } catch (e) {
      debugPrint("❌ Write Error: $e");
    }
  }

  /// ---------------- WRITE WIFI ----------------
  Future<void> writeWifiCredentials(String ssid, String password) async {
    if (_connectedDevice == null || _writeChar == null) {
      debugPrint("❌ Device not ready");
      return;
    }

    final connectionState =
    await _connectedDevice!.device.connectionState.first;

    if (connectionState != BluetoothConnectionState.connected) {
      debugPrint("❌ Not connected");
      return;
    }

    final payload = "$ssid,$password\n";
    final bytes = payload.codeUnits;

    const int maxChunk = 20; // 🔥 FORCE SAFE SIZE

    debugPrint("Sending in 20-byte chunks");
    debugPrint("Total bytes: ${bytes.length}");

    for (int i = 0; i < bytes.length; i += maxChunk) {
      int end = (i + maxChunk > bytes.length)
          ? bytes.length
          : i + maxChunk;

      List<int> chunk = bytes.sublist(i, end);


      await _writeChar!.write(
        chunk,
        withoutResponse: false,
      );

      debugPrint("📤 Sent chunk: ${String.fromCharCodes(chunk)}");

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
  bool get isConnected {
    return _connectedDevice != null && _writeChar != null && _notifyChar != null;
  }
}