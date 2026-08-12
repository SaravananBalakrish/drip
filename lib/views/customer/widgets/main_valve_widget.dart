import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../models/customer/site_model.dart';
import '../../../utils/constants.dart';

class BuildMainValve extends StatelessWidget {
  final MainValveModel valve;
  final int customerId, controllerId, modelId;
  final bool isNarrow;

  const BuildMainValve({
    super.key,
    required this.valve,
    required this.customerId,
    required this.controllerId,
    required this.modelId,
    this.isNarrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<MqttPayloadProvider, String?>(
      selector: (_, provider) => provider.getValveOnOffStatus(
        [...AppConstants.ecoGemModelList].contains(modelId)
            ? double.parse(valve.sNo.toString()).toStringAsFixed(3)
            : valve.sNo.toString(),
      ),
      builder: (_, status, __) {
        final statusParts = status?.split(',') ?? [];
        if (statusParts.isNotEmpty) {
          valve.status = int.parse(statusParts[1]);

          if(statusParts.length > 2){
            valve.completePercent = int.parse(statusParts[2]);
          }else{
            valve.completePercent = 0;
          }
        }

        const width = 70.0;
        final height = isNarrow ? 70.0 : 100.0;
        final iconSize = isNarrow ? 43.0 : 70.0;

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: isNarrow ? Image.asset('assets/png/m_main_valve_gray.png',
                      color: valve.completePercent==100? Colors.blue.shade500 :
                      valve.status == 0 ? Colors.black54 : valve.status == 1 ? Colors.green
                          : valve.status == 1 ? Colors.orange : Colors.red,
                    ) : AppConstants.getAsset('main_valve', valve.status, '', valve.completePercent),
                  ),
                  Text(
                    valve.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}