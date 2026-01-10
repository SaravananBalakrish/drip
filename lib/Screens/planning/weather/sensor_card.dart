import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SensorCard extends StatelessWidget {
  final String title;
  final String value;

  const SensorCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: kTextGrey)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
const kPrimary = Color(0xFF0E6F78);
const kSecondary = Color(0xFF0A8F9C);
const kCardBg = Colors.white;
const kTextGrey = Color(0xFF6B7280);
