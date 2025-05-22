import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oro_drip_irrigation/modules/bluetooth_low_energy/view/scan_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../state_management/ble_service.dart';
import '../utils/snackbar.dart';
import 'package:provider/provider.dart';

/// Represents the state of the BLE node connection page.


class NodeConnectionPage extends StatefulWidget {
  final Map<String, dynamic> masterData;
  const NodeConnectionPage({super.key, required this.masterData});

  @override
  State<NodeConnectionPage> createState() => _NodeConnectionPageState();
}

class _NodeConnectionPageState extends State<NodeConnectionPage> {
  late BleProvider bleService;

  @override
  void initState() {
    super.initState();
    bleService = Provider.of<BleProvider>(context, listen: false);
    if (mounted) {
      _checkRequirements();
    }
  }

  /// Checks the necessary conditions to start scanning:
  /// Bluetooth ON and Location enabled.
  Future<void> _checkRequirements() async {
    bool isBluetoothOn = await _isBluetoothEnabled();
    if (!isBluetoothOn) {
      setState(() => bleService.bleNodeState = BleNodeState.bluetoothOff);
      return;
    }

    bool isLocationOn = await _isLocationEnabled();
    if (!isLocationOn) {
      setState(() => bleService.bleNodeState = BleNodeState.locationOff);
      return;
    }
    if(bleService.bleNodeState != BleNodeState.deviceFound){
      bleService.autoScanAndFoundDevice(macAddressToConnect: widget.masterData['deviceId']);
    }
  }

  /// Checks whether Bluetooth is currently enabled.
  Future<bool> _isBluetoothEnabled() async {
    try {
      final adapterState = await FlutterBluePlus.adapterState.first;
      return adapterState == BluetoothAdapterState.on;
    } catch (e, backtrace) {
      // Snackbar.show(
      //   context,
      //   prettyException("Bluetooth check error:", e),
      //   success: false,
      // );
      if (kDebugMode) {
        print("Bluetooth check error: $e");
        print("Backtrace: $backtrace");
      }
      return false;
    }
  }

  /// Checks whether location services are enabled.
  Future<bool> _isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Widget build(BuildContext context) {
    bleService = Provider.of<BleProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.masterData['deviceName']}'),
      ),
      body: Center(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (bleService.bleNodeState) {
      case BleNodeState.bluetoothOff:
        return _bluetoothOffWidget();
      case BleNodeState.locationOff:
        return _locationOffWidget();
      case BleNodeState.idle:
        return _idleWidget();
      case BleNodeState.scanning:
        return _scanningWidget();
      case BleNodeState.deviceFound:
        return _deviceFound();
      case BleNodeState.deviceNotFound:
        return _deviceNotFound();
      case BleNodeState.connecting:
        return _deviceConnecting();
      case BleNodeState.connected:
        return _deviceConnected();
      case BleNodeState.disConnected:
        return _deviceNotConnected();
      default:
        return const Text('Unknown State');
    }
  }

  Widget _scanningWidget() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Scanning for devices...', style: TextStyle(fontSize: 16)),
        SizedBox(height: 16),
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(),
        ),
      ],
    );
  }

  Widget _deviceFound() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Device Found SuccessFully', style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _deviceConnected() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Device Connected SuccessFully', style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _deviceConnecting() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Please Wait Connecting......', style: TextStyle(fontSize: 16)),
        SizedBox(height: 16),
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(),
        ),
      ],
    );
  }

  Widget _deviceNotConnected() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Click to Not connect device', style: TextStyle(fontSize: 16)),
        SizedBox(height: 30,),
        ElevatedButton(
            onPressed: (){
              bleService.autoConnect();
            },
            child: const Text('Connect Again', style: TextStyle(color: Colors.white),)
        )
      ],
    );
  }


  Widget _deviceNotFound() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Device Not Found', style: TextStyle(fontSize: 16)),
        SizedBox(height: 30,),
        ElevatedButton(
            onPressed: (){
              bleService.autoScanAndFoundDevice(macAddressToConnect: widget.masterData['deviceId']);
            },
            child: const Text('Try Again', style: TextStyle(color: Colors.white),)
        )
      ],
    );
  }

  Widget _idleWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Ready to scan.', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            setState(() => bleService.bleNodeState = BleNodeState.scanning);
          },
          child: const Text('Start Scan'),
        ),
      ],
    );
  }

  Widget _bluetoothOffWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset('assets/Images/Svg/Oro/bluetooth_off.svg'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Bluetooth is off. Please enable it to continue.' ,style: TextStyle(color: Theme.of(context).primaryColorDark, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            try {
              if (!kIsWeb && Platform.isAndroid) {
                await FlutterBluePlus.turnOn();
              }
              await Future.delayed(const Duration(seconds: 2));
              _checkRequirements();
            } catch (e, backtrace) {
              // Snackbar.show(
              //   context,
              //   prettyException("Error Turning On Bluetooth:", e),
              //   success: false,
              // );
              if (kDebugMode) {
                print("Turn on Bluetooth error: $e");
                print("Backtrace: $backtrace");
              }
            }
          },
          child: const Text('Turn On Bluetooth', style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }

  Widget _locationOffWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset('assets/Images/Svg/Oro/location_off.svg'),
        const SizedBox(height: 16),
        Text('Location is off. Please enable it to continue.' ,style: TextStyle(color: Theme.of(context).primaryColorDark, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            bool openedSettings = await Geolocator.openLocationSettings();
            if (openedSettings) {
              await Future.delayed(const Duration(seconds: 2));
              _checkRequirements();
            }
          },
          child: const Text('Open Location Settings', style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }
}
