import 'package:flutter/material.dart';

class WeatherInfoCard extends StatelessWidget {
  const WeatherInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                "77%",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("Humidity"),
            ],
          ),

          Column(
            children: [
              Text(
                "NO",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("Rain Fall"),
            ],
          ),

          Column(
            children: [
              Text(
                "6 mph/s",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("Wind Speed"),
            ],
          ),
        ],
      ),
    );
  }
}