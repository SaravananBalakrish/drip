import 'package:flutter/material.dart';

Widget buildValveStatusLegend() {

  Widget legendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.grey.shade400, width: 0.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(
        top: BorderSide(color: Colors.grey.shade300),
        bottom: BorderSide(color: Colors.grey.shade300),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Valve Status",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(height: 20, width: 1, color: Colors.black26),
        ),
        Expanded(
          child: Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              legendItem(Colors.black54, "Default"),
              legendItem(Colors.blue, "Running"),
              legendItem(Colors.green, "Completed"),
              legendItem(Colors.yellow, "Pending"),
              legendItem(Colors.orange, "Not Open"),
              legendItem(Colors.red, "Not Closed"),
            ],
          ),
        ),
      ],
    ),
  );
}

