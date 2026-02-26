import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/widgets/sensor_tile_new.dart';

import '../model/weather_model.dart';
import '../view_model/weather_view_model.dart';

class SensorChip extends StatelessWidget {
  final ConfigObjectNew sensor;
  final WeatherViewModel vm;
  final WeatherDeviceList device;
  final bool isNarrow;

  const SensorChip({super.key,
    required this.sensor,
    required this.vm,
    required this.device,
    required this.isNarrow,
  });

  @override
  Widget build(BuildContext context) {
    final live = vm.getSensorLiveBySerial(
      serial: device.serialNumber,
      objectName: sensor.objectName,
      controllerId: device.controllerId,
    );

    if (live == null) return const SizedBox.shrink();

    return Container(
      width: isNarrow ? double.infinity : 230,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SensorTileNew(
        icon: Icons.sensors,
        title: sensor.name,
        statusCode: live.status,
        value: live.value,
        unit: unit(sensor.objectName),
        minValue: live.min,
        maxValue: live.max,
        otherValue: "${live.avg}",
      ),
    );
  }

  String unit(String type) {
    type = type.toLowerCase();
    if (type.contains('temperature')) return '°C';
    if (type.contains('humidity')) return '%';
    if (type.contains('co2')) return 'ppm';
    // if (type.contains('Wind Direction')) return '°';
    if (type.contains('Wind')) return 'km/h';
    if (type.contains('rain')) return 'mm';
    return '';
  }
}