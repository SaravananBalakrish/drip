import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as classic;
import '../../../utils/enums.dart';

class ClassicBluetoothDeviceModel {

  final classic.BluetoothDevice device;
  BlueConnectionState connectionState;

  ClassicBluetoothDeviceModel({
    required this.device,
    this.connectionState = BlueConnectionState.disconnected,
  });

  String get name => device.name ?? "Unknown Device";
  String get address => device.address;

  bool get isConnected => connectionState == BlueConnectionState.connected;
  bool get isConnecting => connectionState == BlueConnectionState.connecting;
  bool get isDisconnected => connectionState == BlueConnectionState.disconnected;
}