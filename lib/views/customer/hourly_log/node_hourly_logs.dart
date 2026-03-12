import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../models/customer/site_model.dart';
import '../../../repository/repository.dart';
import '../../../services/http_service.dart';
import '../../../view_models/customer/node_hourly_logs_vm.dart';


class NodeHourlyLogs extends StatelessWidget {
  const NodeHourlyLogs({
    super.key,
    required this.userId,
    required this.controllerId,
    required this.nodes,
  });

  final int userId, controllerId;
  final List<NodeListModel> nodes;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NodeHourlyLogsVm(Repository(HttpService()), userId, controllerId, nodes,)..getNodeLogs(),
      child: const _NodeHourlyLogsView(),
    );
  }
}


class _NodeHourlyLogsView extends StatelessWidget {
  const _NodeHourlyLogsView();

  @override
  Widget build(BuildContext context) {
    return Consumer<NodeHourlyLogsVm>(
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Hourly power logs'),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    "${viewModel.selectedDate.toLocal()}".split(' ')[0],
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => viewModel.selectDate(context),
              ),
            ],
          ),
          body: viewModel.nodeDataMap.isEmpty
              ? const Center(child: Text('Node hourly log not found'))
              : ListView.builder(
            itemCount: viewModel.nodeDataMap.length,
            itemBuilder: (context, index) {
              final entry =
              viewModel.nodeDataMap.entries.elementAt(index);

              final String nodeId = entry.key;
              final List<ChartDataLog> chartData = entry.value;

              if (chartData.isEmpty) {
                return const SizedBox();
              }

              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  height: 350,
                  child: SfCartesianChart(
                    key: ValueKey(nodeId),
                    enableAxisAnimation: false,
                    primaryXAxis: const CategoryAxis(),
                    primaryYAxis: const NumericAxis(
                      title: AxisTitle(text: 'Voltage'),
                    ),
                    title: ChartTitle(
                      text:
                      'Device: ${chartData.first.deviceName} - ID: $nodeId',
                    ),
                    legend: const Legend(isVisible: true),
                    tooltipBehavior:
                    TooltipBehavior(enable: true),
                    series: <LineSeries<ChartDataLog, String>>[
                      LineSeries<ChartDataLog, String>(
                        animationDuration: 0,
                        dataSource: chartData,
                        xValueMapper: (data, _) => data.hour,
                        yValueMapper: (data, _) =>
                        data.batteryVoltage,
                        name: 'Battery Voltage',
                        dataLabelSettings:
                        const DataLabelSettings(isVisible: true),
                      ),
                      LineSeries<ChartDataLog, String>(
                        animationDuration: 0,
                        dataSource: chartData,
                        xValueMapper: (data, _) => data.hour,
                        yValueMapper: (data, _) =>
                        data.solarVoltage,
                        name: 'Solar Voltage',
                        dataLabelSettings:
                        const DataLabelSettings(isVisible: true),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}


class ChartDataLog {
  final String deviceName;
  final String hour;
  final double batteryVoltage;
  final double solarVoltage;

  ChartDataLog(
      this.deviceName,
      this.hour,
      this.batteryVoltage,
      this.solarVoltage,
      );
}
