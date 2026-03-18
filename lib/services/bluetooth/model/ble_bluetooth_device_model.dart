import 'package:flutter_blue_plus/flutter_blue_plus.dart' as ble;
import '../../../utils/enums.dart';

class BleBluetoothDeviceModel {
  final ble.BluetoothDevice device;
  BlueConnectionState connectionState;

  BleBluetoothDeviceModel({
    required this.device,
    this.connectionState = BlueConnectionState.disconnected,
  });

  String get name =>
      device.platformName.isNotEmpty
          ? device.platformName
          : "Unknown BLE Device";

  String get id => device.remoteId.str;

  bool get isConnected => connectionState == BlueConnectionState.connected;
  bool get isConnecting => connectionState == BlueConnectionState.connecting;
  bool get isDisconnected => connectionState == BlueConnectionState.disconnected;
}