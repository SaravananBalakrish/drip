import 'package:flutter/material.dart';

class RainfallCard extends StatelessWidget {
  final String title;
  final String rainfallValue;
  final String forecastText;
  final String description;
  final Color backgroundColor;

  const RainfallCard({
    super.key,
    this.title = "Rainfall",
    required this.rainfallValue,
    required this.forecastText,
    required this.description,
    this.backgroundColor = const Color(0xFF3C4B6C),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       Text(
         title,
         style: const TextStyle(color: Colors.black),
       ),
       const SizedBox(height: 12),
       Text(
         '$rainfallValue mm',
         style: const TextStyle(
           color: Colors.black,
           fontSize: 24,
           fontWeight: FontWeight.bold,
         ),
       ),
       const SizedBox(height: 6),
       Text(
         forecastText,
         style: const TextStyle(color: Colors.black),
       ),
       const SizedBox(height: 12),
       Text(
         description,
         style: const TextStyle(color: Colors.black),
       ),
     ],
          );
  }
}
