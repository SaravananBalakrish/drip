import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:oro_drip_irrigation/modules/bluetooth_low_energy/utils/extra.dart';
import '../utils/snackbar.dart';
import '../view/node_connection_page.dart';

enum BleNodeState {
  bluetoothOff,
  locationOff,
  idle,
  scanning,
  deviceFound,
  deviceNotFound,
  connecting,
  connected,
  disConnected,
}

class BleProvider extends ChangeNotifier {
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;
  BleNodeState bleNodeState = BleNodeState.bluetoothOff;
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;


  // after found device
  BluetoothDevice? device;
  int? _rssi;
  int? _mtuSize;
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;
  List<BluetoothService> _services = [];
  bool _isDiscoveringServices = false;
  bool _isConnecting = false;
  bool _isDisconnecting = false;

  late StreamSubscription<BluetoothConnectionState> _connectionStateSubscription;
  late StreamSubscription<bool> _isConnectingSubscription;
  late StreamSubscription<bool> _isDisconnectingSubscription;
  late StreamSubscription<int> _mtuSubscription;


  void autoScanAndFoundDevice({required String macAddressToConnect}) async{
    bleNodeState = BleNodeState.scanning;
    notifyListeners();
    startListeningDevice();
    startScan();
    outerLoop : for(var scanLoop = 0;scanLoop < 15;scanLoop++){
      await Future.delayed(const Duration(seconds: 1));
      print("_isScanning :: $_isScanning");
      for(var result in _scanResults){
        var adv = result.advertisementData;
        print("${adv.advName} ----------------- ${result.device.remoteId}");
        String upComingMacAddress = result.device.remoteId.toString().split(':').join('');
        if(macAddressToConnect == upComingMacAddress){
          device = result.device;
          bleNodeState = BleNodeState.deviceFound;
          notifyListeners();
          print("device is found ...............................................");
          await Future.delayed(const Duration(seconds: 2));
          break outerLoop;
        }
      }
    }
    if(bleNodeState != BleNodeState.deviceFound){
      bleNodeState = BleNodeState.deviceNotFound;
      notifyListeners();
    }
    stopScan();
    clearListOfScanDevice();
    if(bleNodeState == BleNodeState.deviceFound){
      autoConnect();
    }
  }

  Future startScan() async {
    try {
      // `withServices` is required on iOS for privacy purposes, ignored on android.
      var withServices = [Guid("180f")]; // Battery Level Service
      _systemDevices = await FlutterBluePlus.systemDevices(withServices);
    } catch (e, backtrace) {
      Snackbar.show(ABC.b, prettyException("System Devices Error:", e), success: false);
      print(e);
      print("backtrace: $backtrace");
    }
    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        withServices: [
          // Guid("180f"), // battery
          // Guid("180a"), // device info
          // Guid("1800"), // generic access
          // Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e"), // Nordic UART
        ],
        webOptionalServices: [
          Guid("180f"), // battery
          Guid("180a"), // device info
          Guid("1800"), // generic access
          Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e"), // Nordic UART
        ],
      );
    } catch (e, backtrace) {
      Snackbar.show(ABC.b, prettyException("Start Scan Error:", e), success: false);
      print(e);
      print("backtrace: $backtrace");
    }
  }

  Future stopScan() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e, backtrace) {
      Snackbar.show(ABC.b, prettyException("Stop Scan Error:", e), success: false);
      print(e);
      print("backtrace: $backtrace");
    }
  }

  void startListeningDevice(){
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
    }, onError: (e) {
      Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
    });
  }

  void clearListOfScanDevice(){
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    _scanResults.clear();
    _systemDevices.clear();
  }

  void autoConnect()async{
    bleNodeState = BleNodeState.connecting;
    notifyListeners();
    listeningConnectionState();
    for(var connectLoop = 0;connectLoop < 30;connectLoop++){
      await Future.delayed(const Duration(seconds: 1));
      print("connecting seconds :: ${connectLoop+1}");
      if(_connectionState == BluetoothConnectionState.connected){
        bleNodeState = BleNodeState.connected;
        notifyListeners();
        break;
      }
    }
    if(bleNodeState != BleNodeState.connected){
      bleNodeState = BleNodeState.disConnected;
      notifyListeners();
    }
  }

  void listeningConnectionState(){
    onConnect();
    _connectionStateSubscription = device!.connectionState.listen((state) async {
      print("connection state :: $state");
      _connectionState = state;
      notifyListeners();
      if (state == BluetoothConnectionState.connected) {
        _services = []; // must rediscover services
      }
      if (state == BluetoothConnectionState.connected && _rssi == null) {
        _rssi = await device!.readRssi();
      }
    });

    _mtuSubscription = device!.mtu.listen((value) {
      _mtuSize = value;
    });

    _isConnectingSubscription = device!.isConnecting.listen((value) {
      _isConnecting = value;
    });

    _isDisconnectingSubscription = device!.isDisconnecting.listen((value) {
      _isDisconnecting = value;
    });
  }

  Future onConnect() async {
    try {
      await device!.connectAndUpdateStream();
      // Snackbar.show(ABC.c, "Connect: Success", success: true);
    } catch (e, backtrace) {
      if (e is FlutterBluePlusException && e.code == FbpErrorCode.connectionCanceled.index) {
        // ignore connections canceled by the user
      } else {
        // Snackbar.show(ABC.c, prettyException("Connect Error:", e), success: false);
        print(e);
        print("backtrace: $backtrace");
      }
    }
  }

  Future onCancel() async {
    try {
      await device!.disconnectAndUpdateStream(queue: false);
      // Snackbar.show(ABC.c, "Cancel: Success", success: true);
    } catch (e, backtrace) {
      // Snackbar.show(ABC.c, prettyException("Cancel Error:", e), success: false);
      print("$e");
      print("backtrace: $backtrace");
    }
  }

  Future onDisconnect() async {
    try {
      await device!.disconnectAndUpdateStream();
      // Snackbar.show(ABC.c, "Disconnect: Success", success: true);
    } catch (e, backtrace) {
      // Snackbar.show(ABC.c, prettyException("Disconnect Error:", e), success: false);
      print("$e backtrace: $backtrace");
    }
  }

  void clearBluetoothDeviceState(){
    _connectionStateSubscription.cancel();
    _mtuSubscription.cancel();
    _isConnectingSubscription.cancel();
    _isDisconnectingSubscription.cancel();
    _rssi;
    _mtuSize;
  }
}