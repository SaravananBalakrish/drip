import 'package:flutter/material.dart';

class WindDetailsCard extends StatelessWidget {
  const WindDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Wind Speed"),
                    Text("12 kph"),
                  ],
                ),

                Divider(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Gusts"),
                    Text("0 kph"),
                  ],
                ),

                Divider(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Wind Direction"),
                    Text("260°NE"),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 20),

          CircleAvatar(
            radius: 40,
            child: Text("260°"),
          ),
        ],
      ),
    );
  }
}