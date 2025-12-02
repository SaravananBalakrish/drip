import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../services/communication_service.dart';

class ProgramPreview extends StatefulWidget {
  final bool isMobile;
  final String prgSNo;
  final String prgName;

  const ProgramPreview({
    super.key,
    required this.isMobile,
    required this.prgSNo,
    required this.prgName,
  });

  @override
  State<ProgramPreview> createState() => _ProgramPreviewState();
}

class _ProgramPreviewState extends State<ProgramPreview> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final payload = jsonEncode({"sentSms": "ProgramView"});
      await context.read<CommunicationService>().sendCommand(
        serverMsg: '',
        payload: payload,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.prgName, style: const TextStyle(fontSize: 16)),
      ),

      body: Selector<MqttPayloadProvider, String?>(
        selector: (_, provider) => provider.getProgramPreview(widget.prgSNo),
        builder: (_, status, __) {
          if (status == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Text("Program preview data: $status");
        },
      ),
    );
  }
}