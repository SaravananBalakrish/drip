import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/customer/site_model.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../utils/constants.dart';
import '../../view_models/customer/customer_screen_controller_view_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key, required this.customerId, required this.controllerId});
  final int customerId, controllerId;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CustomerScreenControllerViewModel>(context);

    var onRefresh = Provider.of<MqttPayloadProvider>(context).onRefresh;

    final irrigationLine = viewModel.mySiteList.data[viewModel.sIndex].masterController[viewModel.mIndex].irrigationLine;


    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          onRefresh ? displayLinearProgressIndicator() : const SizedBox(),
          ...irrigationLine.map((line) => buildIrrigationLineCard(line)),
        ],
      ),
    );
  }

  Widget displayLinearProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 3, right: 3),
      child: LinearProgressIndicator(
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        backgroundColor: Colors.grey[200],
        minHeight: 4,
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }

  Widget buildIrrigationLineCard(IrrigationLineFinal line) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 5),
      child: Stack(
        children: [
          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildPumpsFromLine(line.lineWaterSources),
                  buildValveWidget(line.valveObjects),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 200,
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
              decoration: BoxDecoration(
                  color: Colors.green.shade200,
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                  border: Border.all(width: 0.5, color: Colors.grey)
              ),
              child: Text(line.name.toUpperCase(),  style: const TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Line Name: ${line.name}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            buildPumpsFromLine(line.lineWaterSources),
            buildValveWidget(line.valveObjects),
          ],
        ),
      ),
    );
  }

  Widget buildPumpsFromLine(List<WaterSourceModel> lineWaterSources) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lineWaterSources.map((source) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 70,
              child: Text(
                source.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: source.allPump.map((pump) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 70,
                      child: AppConstants.getAsset('pump', pump.status, ''),
                    ),
                  ],
                );
              }).toList(),
            )
          ],
        );
      }).toList(),
    );
  }

  Widget buildValveWidget(List<ConfigObject> valveObjects) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: valveObjects.map((valve) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 35,
              height: 35,
              child: AppConstants.getAsset('valve', valve.status, ''),
            ),
            const SizedBox(height: 4),
            Text(
              valve.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ],
        );
      }).toList(),
    );
  }

}