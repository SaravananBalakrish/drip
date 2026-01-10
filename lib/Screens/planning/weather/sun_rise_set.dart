
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SunInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;

  const SunInfo({
    super.key,
    required this.icon,
    required this.label,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.orangeAccent, size: 18),
        const SizedBox(width: 6),
        Text(
          "$label $time",
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
