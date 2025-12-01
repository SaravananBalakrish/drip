import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../StateManagement/mqtt_payload_provider.dart';

class ProgramPreview extends StatelessWidget {
  final bool isMobile;
  final String prgSNo;
  const ProgramPreview({super.key, required this.isMobile, required this.prgSNo});

  @override
  Widget build(BuildContext context) {
    return Selector<MqttPayloadProvider, String?>(
      selector: (_, provider) => provider.getProgramPreview(prgSNo),
      builder: (_, status, __) {

        final statusParts = status?.split(',') ?? [];
        if(statusParts.isNotEmpty){
          //fertilizerSite.boosterPump[0].status = int.parse(statusParts[1]);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
          ],
        );
      },
    );
  }
}