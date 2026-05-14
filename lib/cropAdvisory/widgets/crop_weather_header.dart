import 'package:flutter/material.dart';

class WeatherHeader extends StatelessWidget {
  const WeatherHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(
          'https://cdn-icons-png.flaticon.com/512/869/869869.png',
          height: 100,
        ),

        const SizedBox(height: 10),

        const Text(
          "32°",
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
          ),
        ),

        const Text(
          "Today is partly sunny day!",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}