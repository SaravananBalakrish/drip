import 'package:flutter/material.dart';

class HourlyWeatherCard extends StatelessWidget {
  final String time;
  final String temp;

  const HourlyWeatherCard({
    super.key,
    required this.time,
    required this.temp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(time),

          const Icon(Icons.cloud_outlined),

          Text(
            temp,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}