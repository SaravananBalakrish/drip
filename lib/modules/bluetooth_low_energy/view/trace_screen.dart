import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Widgets/custom_buttons.dart';
import 'package:provider/provider.dart';

import '../state_management/ble_service.dart';

class TraceScreen extends StatefulWidget {
  final Map<String, dynamic> nodeData;

  const TraceScreen({super.key, required this.nodeData});

  @override
  State<TraceScreen> createState() => _TraceScreenState();
}

class _TraceScreenState extends State<TraceScreen> {
  late BleProvider bleService;

  @override
  void dispose() {
    bleService.traceScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    bleService = Provider.of<BleProvider>(context, listen: false);
    bleService.sendTraceCommand();
  }

  @override
  Widget build(BuildContext context) {
    bleService = Provider.of<BleProvider>(context, listen: true);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) async{
        print("didPop : $didPop");
        print("result : $result");
        if (bleService.traceMode == TraceMode.traceOn) {
          bool shouldLeave = await showDialog(
            context: context,
            builder: (alertBoxContext) => AlertDialog(
              title: const Text("Alert", style: TextStyle(fontSize: 16, color: Colors.red)),
              content: const Text("Do you really want to leave?", style: TextStyle(fontSize: 14),),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(alertBoxContext).pop(false);
                  }, // Stay on page
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    bleService.sendTraceCommand();
                    Navigator.of(alertBoxContext).pop(true);
                  },
                  child: const Text("Trace off and leave"),
                ),
              ],
            ),
          );
          if(shouldLeave){
            Navigator.of(context).pop(result);
          }
        }
        else{
          Navigator.of(context).pop(result);
        }
      },
      child: Scaffold(
        appBar: AppBar(
            title: const Text('Trace')
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.file_copy),
              label: Text(bleService.traceMode == TraceMode.traceOn ? 'Trace Off' : 'Trace On'),
              onPressed: (){
                bleService.sendTraceCommand();
              },
              style: FilledButton.styleFrom(
                backgroundColor: bleService.traceMode == TraceMode.traceOn ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text('Upload'),
              onPressed: (){
                bleService.uploadTraceFile(deviceId: widget.nodeData['deviceId']);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: Scrollbar(
          thumbVisibility: true,
          child: ListView.builder(
            controller: bleService.traceScrollController,
            itemCount: bleService.traceData.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                child: Text(bleService.traceData[index]),
              );
            },
          ),
        ),
      ),
    );
  }
}