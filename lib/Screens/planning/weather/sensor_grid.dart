import 'package:flutter/cupertino.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/sensor_card.dart';

class SensorGrid extends StatelessWidget {
  const SensorGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          SensorCard(title: "Moisture", value: "70%"),
          SensorCard(title: "Soil Temp", value: "21.4°C"),
          SensorCard(title: "LUX Level", value: "63,800"),
          SensorCard(title: "Leaf Wetness", value: "1014 hPa"),
        ],
      ),
    );
  }
}
