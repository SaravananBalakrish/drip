import 'package:flutter/material.dart';

import '../view/weather_screen_new.dart';

class SensorTileNew extends StatelessWidget {
  final IconData icon;
  final String title;
  final int statusCode;
  final double value;
  final String unit;
  final double minValue;
  final double maxValue;
  final String otherValue;

  const SensorTileNew({
    super.key,
    required this.icon,
    required this.title,
    required this.statusCode,
    required this.value,
    required this.unit,
    required this.minValue,
    required this.maxValue,
    required this.otherValue,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: sensorStatusColor(statusCode),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusCode == 255 ? "Normal" : "Alert",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "${value.toStringAsFixed(2)} $unit",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text("↓ Min: $minValue     ↑ Max: $maxValue"),
        if (otherValue.isNotEmpty)
          Text("x̄ Average: $otherValue"),
      ],
    );
  }
}