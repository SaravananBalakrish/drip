import 'package:flutter/material.dart';
import '../../../view_models/customer/customer_screen_controller_view_model.dart';

class BluetoothScanTile extends StatefulWidget {
  final CustomerScreenControllerViewModel vm;

  const BluetoothScanTile({super.key, required this.vm});

  @override
  State<BluetoothScanTile> createState() => _BluetoothScanTileState();
}

class _BluetoothScanTileState extends State<BluetoothScanTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _rotationAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    // Stop scan when device is found
    widget.vm.bluetoothClassicService.onDeviceFound = stopScan;
  }

  Future<void> startScan() async {
    if (isScanning) return;

    setState(() => isScanning = true);
    _controller.repeat();

    // Use try/finally to ensure scan stops even if an error occurs
    try {
      final deviceId = widget.vm
          .mySiteList.data[widget.vm.sIndex].master[widget.vm.mIndex].deviceId;

      await widget.vm.bluetoothClassicService.scanDevices(deviceId);
    } finally {
      stopScan();
    }
  }

  void stopScan() {
    if (!mounted) return;

    setState(() => isScanning = false);
    _controller.stop();
  }

  @override
  void dispose() {
    widget.vm.bluetoothClassicService.onDeviceFound = null;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      title: const Text(
        "Scan for Bluetooth Devices and Connect",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      trailing: RotationTransition(
        turns: _rotationAnimation,
        child: IconButton(
          icon: Icon(
            Icons.refresh_outlined,
            color: isScanning ? Colors.blue : Colors.black,
          ),
          onPressed: startScan,
        ),
      ),
    );
  }
}