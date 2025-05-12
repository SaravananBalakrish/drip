import 'dart:typed_data';
import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/material.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import '../Models/customer/blu_device.dart';

class CustomDevice {
  final Device device;
  int status;

  CustomDevice({required this.device, this.status = BluDevice.disconnected});

  bool get isConnected => status == BluDevice.connected;
  bool get isConnecting => status == BluDevice.connecting;
}

class BluetoothManager with ChangeNotifier {
  final _bluetoothClassicPlugin = BluetoothClassic();

  List<CustomDevice> _devices = [];
  Uint8List _data = Uint8List.fromList([]);
  String? _connectedAddress;

  List<CustomDevice> get pairedDevices => _devices;
  Uint8List get receivedData => _data;

  BluetoothManager() {
    _listenToEvents();
  }

  void _listenToEvents() {
    initPermissions();
    _bluetoothClassicPlugin.onDeviceStatusChanged().listen((status) {
      for (var d in _devices) {
        d.status = (d.device.address == _connectedAddress) ? status : BluDevice.disconnected;
      }
      notifyListeners();
    });

    _bluetoothClassicPlugin.onDeviceDataReceived().listen((event) {
      _data = Uint8List.fromList([..._data, ...event]);
      notifyListeners();
    });
  }

  Future<void> initPermissions() async {
    await _bluetoothClassicPlugin.initPermissions();
  }

  Future<void> getDevices() async {
    var res = await _bluetoothClassicPlugin.getPairedDevices();
    _devices = res.map((e) => CustomDevice(device: e)).toList();
    notifyListeners();
  }

  Future<void> connectToDevice(CustomDevice customDevice) async {
    try {
      _connectedAddress = customDevice.device.address;
      customDevice.status = Device.connecting;
      notifyListeners();

      try {
        await _bluetoothClassicPlugin
            .connect(customDevice.device.address, "00001101-0000-1000-8000-00805f9b34fb")
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        customDevice.status = BluDevice.disconnected;
        notifyListeners();
        debugPrint("Connection error: $e");
      }
    } catch (e) {
      customDevice.status = Device.disconnected;
      notifyListeners();
      print("Connection failed: $e");
    }
  }

  Future<void> write(String data) async {
    await _bluetoothClassicPlugin.write(data);
  }

  void clearData() {
    _data = Uint8List.fromList([]);
    notifyListeners();
  }
}