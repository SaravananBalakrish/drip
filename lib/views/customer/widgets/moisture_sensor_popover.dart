import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../models/customer/sensor_hourly_data_model.dart';
import '../../../models/customer/site_model.dart';
import '../../../repository/repository.dart';
import '../../../services/http_service.dart';
import '../../../utils/my_function.dart';

class MoistureSensorPopover extends StatefulWidget {
  final ValveModel valve;
  final int customerId, controllerId;

  const MoistureSensorPopover({
    super.key,
    required this.valve,
    required this.customerId,
    required this.controllerId,
  });

  @override
  State<MoistureSensorPopover> createState() => _MoistureSensorPopoverState();
}

class _MoistureSensorPopoverState extends State<MoistureSensorPopover> {
  final ScrollController _scrollController = ScrollController();
  DateTime selectedDate = DateTime.now();
  List<SensorHourlyDataModel> sensors = [];

  @override
  void initState() {
    super.initState();
    fetchSensorData(selectedDate, selectedDate);
  }

  @override
  Widget build(BuildContext context) {

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: widget.valve.moistureSensors.map((sensor) {

            final sensorDataList = getSensorDataById(sensor.sNo.toString(), sensors);

            final List<CartesianSeries<dynamic, String>> series = [
              LineSeries<SensorHourlyData, String>(
                dataSource: sensorDataList,
                xValueMapper: (data, _) => data.hour,
                yValueMapper: (data, _) {
                  try { return double.parse(data.value); }
                  catch (_) { return 0.0; }
                },
                markerSettings: const MarkerSettings(isVisible: true),
                color: Colors.blueAccent,
                name: sensor.name,
              ),
            ];

            return Selector<MqttPayloadProvider, String?>(
              selector: (_, provider) => provider.getSensorUpdatedValve(sensor.sNo.toString()),
              builder: (_, status, __) {
                final statusParts = status?.split(',') ?? [];
                if (statusParts.isNotEmpty) {
                  sensor.value = statusParts[1];
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 10, bottom: 6),
                      child: Text(
                        sensor.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        /// Moisture Gauge
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: SfRadialGauge(
                            axes: [
                              RadialAxis(
                                minimum: 0,
                                maximum: 200,
                                pointers: <GaugePointer>[
                                  NeedlePointer(
                                      value: double.tryParse(sensor.value.toString()) ?? 0.0,
                                      needleEndWidth: 3, needleColor: Colors.black54),
                                  const RangePointer(
                                    value: 200.0,
                                    width: 0.30,
                                    sizeUnit: GaugeSizeUnit.factor,
                                    color: Color(0xFF494CA2),
                                    animationDuration: 1000,
                                    gradient: SweepGradient(
                                      colors:
                                      <Color>[
                                        Colors.tealAccent,
                                        Colors.orangeAccent,
                                        Colors.redAccent,
                                        Colors.redAccent
                                      ],
                                      stops: <double>[0.15, 0.50, 0.70, 1.00],
                                    ),
                                    enableAnimation: true,
                                  ),
                                ],
                                showFirstLabel: false,
                                annotations: [
                                  GaugeAnnotation(
                                    widget: Text(
                                      MyFunction().getUnitByParameter(context, "Moisture Sensor", sensor.value.toString()) ?? '',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                    angle: 90,
                                    positionFactor: 0.8,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(width: 1, height: 110, color: Colors.black12),
                        ),
                        SizedBox(
                          width: 415,
                          height: 132,
                          child: buildCommonCalendar(context),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 550,
                      height: 175,
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(
                          title: AxisTitle(
                            text: sensor.name,
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: series,
                      ),
                    ),
                    const Divider(),
                  ],
                );
              },
            );

          }).toList(),
        ),
      ),
    );
  }

  Widget buildCommonCalendar(BuildContext context) {
    return TableCalendar(
      focusedDay: selectedDate,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      calendarFormat: CalendarFormat.week,
      availableCalendarFormats: const {
        CalendarFormat.week: 'Week',
      },
      selectedDayPredicate: (day) => isSameDate(day, selectedDate),
      onDaySelected: (selectedDay, focusedDay) {
        selectedDate = selectedDay;
        fetchSensorData(selectedDate, selectedDate);
      },
      enabledDayPredicate: (day) => !day.isAfter(DateTime.now()),
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(color: Colors.white),
        todayTextStyle: const TextStyle(color: Colors.black),
      ),
    );
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<List<SensorHourlyDataModel>> fetchSensorData(
      DateTime fromDate, DateTime toDate) async {
    try {
      final from = DateFormat('yyyy-MM-dd').format(fromDate);
      final to = DateFormat('yyyy-MM-dd').format(toDate);

      final body = {
        "userId": widget.customerId,
        "controllerId": widget.controllerId,
        "fromDate": from,
        "toDate": to,
      };

      final response =
      await Repository(HttpService()).fetchSensorHourlyData(body);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          sensors = (jsonData['data'] as List).map((item) {
            final dateStr = item['date'];
            final Map<String, List<SensorHourlyData>> hourlyDataMap = {};

            item.forEach((key, value) {
              if (key == 'date') return;
              if (value is String && value.isNotEmpty) {
                final entries = value.split(';');
                hourlyDataMap[key] = entries
                    .map((entry) =>
                    SensorHourlyData.fromCsv(entry, key, dateStr))
                    .toList();
              } else {
                hourlyDataMap[key] = [];
              }
            });

            return SensorHourlyDataModel(
              date: item['date'],
              data: hourlyDataMap,
            );
          }).toList();
        }
      }
    } catch (error) {
      debugPrint('Error fetching sensor hourly data: $error');
    }

    setState(() {});

    return sensors;
  }

  List<SensorHourlyData> getSensorDataById(String sensorId, List<SensorHourlyDataModel> sensorData) {
    final result = <SensorHourlyData>[];
    for (final model in sensorData) {
      model.data.forEach((hour, sensorList) {
        result.addAll(sensorList.where((sensor) => sensor.sensorId == sensorId));
      });
    }
    return result;
  }

}