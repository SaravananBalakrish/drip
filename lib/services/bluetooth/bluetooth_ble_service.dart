import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

import '../../StateManagement/mqtt_payload_provider.dart';
import '../../utils/enums.dart';
import '../communication_service.dart';
import 'model/ble_bluetooth_device_model.dart';

class BluetoothBleService {

  /// ---------------- VARIABLES ----------------
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;

  final List<BleBluetoothDeviceModel> _devices = [];

  MqttPayloadProvider? providerState;
  Function()? onDeviceFound;
  bool _isScanning = false;

  bool get isConnected => providerState?.connectedDeviceBle != null;


  BluetoothCharacteristic? _writeChar;
  BluetoothCharacteristic? _notifyChar;

  /// ---------------- INIT ----------------
  Future<void> initializeBleService({required MqttPayloadProvider state}) async {
    providerState = state;

    // Listen Bluetooth state
    _adapterSubscription =
        FlutterBluePlus.adapterState.listen((state) {
          debugPrint("Bluetooth State: $state");
        });
  }

  /// ---------------- PERMISSIONS ----------------
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      final permissions = [
        if (sdkInt >= 31) ...[
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.bluetoothAdvertise,
        ] else ...[
          Permission.bluetooth,
        ],
        Permission.location,
      ];

      final result = await permissions.request();

      if (result.values.any(
              (status) => status.isDenied || status.isPermanentlyDenied)) {
        debugPrint("Permissions not granted");
        return false;
      }
    }
    return true;
  }

  /// ---------------- LOCATION CHECK ----------------
  Future<bool> checkLocationService() async {
    final enabled = await Geolocator.isLocationServiceEnabled();

    if (!enabled) {
      debugPrint("Location service OFF");
      return false;
    }
    return true;
  }

  /// ---------------- BLUETOOTH CHECK ----------------
  Future<bool> checkBluetooth() async {
    if (!await FlutterBluePlus.isSupported) {
      debugPrint("Bluetooth not supported");
      return false;
    }

    final state = await FlutterBluePlus.adapterState.first;

    if (state != BluetoothAdapterState.on) {
      debugPrint("Bluetooth OFF");
      return false;
    }

    return true;
  }

  /// ---------------- START SCAN ----------------
  Future<void> startScan({String? deviceNameFilter}) async {
    if (_isScanning) return;

    final hasPermission = await requestPermissions();
    final locationOn = await checkLocationService();
    final bluetoothOn = await checkBluetooth();

    if (!hasPermission || !locationOn || !bluetoothOn) return;

    _devices.clear();
    providerState?.updateBlePairedDevices([]);

    await stopScan();

    _isScanning = true;

    debugPrint("BLE Scan Started");

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (var r in results) {
        final device = r.device;

        final name = device.platformName;

        debugPrint("Found: $name | ${device.remoteId}");

        /// OPTIONAL FILTER
        if (deviceNameFilter != null &&
            !name.toLowerCase().contains(deviceNameFilter.toLowerCase())) {
          continue;
        }

        final exists = _devices.any((d) => d.device.remoteId.str == device.remoteId.str);

        if (!exists) {
          final newDevice = BleBluetoothDeviceModel(
            device: device,
            connectionState: BlueConnectionState.disconnected,
          );

          _devices.add(newDevice);

          debugPrint("Device Added (${_devices.length})");

          providerState?.updateBlePairedDevices(List.from(_devices));

          onDeviceFound?.call();
        }
      }
    });

    /// Auto stop handled by timeout
    await Future.delayed(const Duration(seconds: 10));

    await stopScan();
  }

  /// ---------------- STOP SCAN ----------------
  Future<void> stopScan() async {
    if (!_isScanning) return;

    debugPrint("BLE Scan Stopped");

    _isScanning = false;

    await _scanSubscription?.cancel();
    _scanSubscription = null;

    await FlutterBluePlus.stopScan();
  }

  /// ---------------- CONNECT ----------------

  Future<void> connectToDevice(BleBluetoothDeviceModel d) async {
    try {
      await requestPermissions();

      providerState?.updateBleDeviceStatus(
        d.device.remoteId.str,
        BlueConnectionState.connecting.index,
      );

      await FlutterBluePlus.stopScan();
      await Future.delayed(const Duration(milliseconds: 500));

      await d.device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );

      // LISTEN TO REAL CONNECTION STATE
      d.device.connectionState.listen((state) async {
        debugPrint("BLE STATE: $state");

        if (state == BluetoothConnectionState.connected) {
          providerState?.updateBleDeviceStatus(
            d.device.remoteId.str,
            BlueConnectionState.connected.index,
          );

          providerState?.updateBleConnectedDeviceStatus(d);

          // ADD DISCOVER SERVICES HERE
          await Future.delayed(const Duration(milliseconds: 300));

          List<BluetoothService> services = await d.device.discoverServices();

          for (var service in services) {
            if (service.uuid.toString() == "12345678-1234-5678-1234-56789abcdef0") {
              for (var char in service.characteristics) {
                if (char.uuid.toString() == "12345678-1234-5678-1234-56789abcdef1") {
                  _writeChar = char;
                }
                if (char.uuid.toString() ==
                    "12345678-1234-5678-1234-56789abcdef2") {
                  _notifyChar = char;

                  await _notifyChar?.setNotifyValue(true);

                  _notifyChar?.value.listen((value) {
                    debugPrint("RAW: $value");

                    try {
                      final response = String.fromCharCodes(value);
                      debugPrint("DEVICE RESPONSE: $response");
                    } catch (e) {
                      debugPrint("Decode error: $e");
                    }
                  });
                }
              }
            }
          }
        }

        else if (state == BluetoothConnectionState.disconnected) {
          providerState?.updateBleDeviceStatus(
            d.device.remoteId.str,
            BlueConnectionState.disconnected.index,
          );

          providerState?.updateBleConnectedDeviceStatus(null);
        }
      });

      await d.device.requestMtu(247);

    } catch (e) {
      debugPrint("BLE Connection Failed: $e");

      providerState?.updateBleDeviceStatus(
        d.device.remoteId.str,
        BlueConnectionState.disconnected.index,
      );
    }
  }

  /// ---------------- WRITE ----------------
  Future<void> write(String data) async {
    if (_writeChar == null) {
      debugPrint("BLE Write characteristic not ready");
      return;
    }

    try {
      await _writeChar!.write(
        data.codeUnits,
        withoutResponse: true,
      );

      debugPrint("BLE Sent: $data");

    } catch (e) {
      debugPrint("BLE Write Error: $e");
    }
  }

  /// ---------------- DISCONNECT ----------------
  Future<void> disconnect(BleBluetoothDeviceModel d) async {
    await d.device.disconnect();

    updateDeviceState(d, BlueConnectionState.disconnected);

    debugPrint("Disconnected: ${d.device.remoteId}");
  }

  /// ---------------- UPDATE STATE ----------------
  void updateDeviceState(
      BleBluetoothDeviceModel device, BlueConnectionState state) {
    device.connectionState = state;

    providerState?.updateBlePairedDevices(List.from(_devices));
  }

  /// ---------------- DISPOSE ----------------
  Future<void> dispose() async {
    await stopScan();
    await _adapterSubscription?.cancel();
  }

  /// ---------------- GET DEVICES ----------------
  List<BleBluetoothDeviceModel> get devices => _devices;
}