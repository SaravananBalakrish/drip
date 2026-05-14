import 'package:flutter/material.dart';

class AirQualityCard extends StatelessWidget {
  const AirQualityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffDCE6FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "CO₂ Level: 542ppm",
            style: TextStyle(fontSize: 18),
          ),

          SizedBox(height: 20),

          LinearProgressIndicator(
            value: 0.3,
          ),

          Spacer(),

          Text(
            "\"Air quality is great!\nPerfect for outdoor activities.\"",
          ),
        ],
      ),
    );
  }
}