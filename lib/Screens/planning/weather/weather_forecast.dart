import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/weather_co2_card.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/weather_left_side_card.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/weather_rainfall_card.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/weather_wind_card.dart';

class WeatherForecastWebPage extends StatelessWidget {
  const WeatherForecastWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFEFF3F4),
      appBar: ForecastAppBar(),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LeftWeatherPanel(),
              SizedBox(width: 16),
              Expanded(child: RightDashboardPanel()),
            ],
          ),
        ),
      ),
    );
  }
}

class ForecastAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ForecastAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0E6F78),
      title: Row(
        children:  [
          IconButton(onPressed: (){}, icon: Icon(Icons.sync, size: 18)),
          SizedBox(width: 8),
          const Text(
            "Last sync - Yesterday at 06:48:14 PM",
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(width: 16),
          Text("Testing Farm"),
        ],
      ),
      actions: const [
        Icon(Icons.mic),
        SizedBox(width: 16),
        Icon(Icons.notifications),
        SizedBox(width: 16),
        CircleAvatar(child: Text("S")),
        SizedBox(width: 16),
      ],
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(60);
}
class LeftWeatherPanel extends StatelessWidget {
  const LeftWeatherPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(
        children: [
          weatherCardLeft(
            city: "Coimbatore",
             date: "04 Jan, 2025",
            temperature: "Sunny 30°",
            feelsLike: "Feels like 31°",
            weatherIcon: Icons.wb_sunny,
            wind: "12.0 km/h",
            humidity: "75 %",
          ),
          const SizedBox(height: 16),
          sunCard(),
        ],
      ),
    );
  }
}
class RightDashboardPanel extends StatelessWidget {
  const RightDashboardPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Sensors",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        sensorWrapGrid(count: 6),
        const SizedBox(height: 20),
        const Wrap(
          spacing: 12, // horizontal spacing between cards
          runSpacing: 12, // vertical spacing between rows
          children: [
            SizedBox(
              width: 300,
              height: 180,
              child: WindCard(
                windSpeed: "12 kph",
                gusts: "0 kph",
                directionText: "260° NE",
                directionAngle: 20,
              ),
            ),
            SizedBox(
              width: 250,
              height: 180,
              child: CO2Card(
                co2Value: 542,
                message: "Air quality is great!\nPerfect for outdoor activities.",
              ),
            ),
            SizedBox(
              width: 250,
              height: 180,
              child: RainfallCard(
                rainfallValue: "1.2 mm",
                forecastText: "Rainfall: 0.2 in expected",
                description: "Light rain expected.",
              ),
            ),
          ],
        )

      ],
    );
  }

  Widget sensorWrapGrid({required int count, double spacing = 12, double runSpacing = 12}) {
    return SingleChildScrollView(

      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: spacing,       // horizontal spacing
        runSpacing: runSpacing, // vertical spacing
        children: List.generate(count, (index) {
          return SizedBox(
            width: 280,  // Adjust width similar to grid column
            height: 180, // Adjust height
            child: const SensorTile(),
          );
        }),
      ),
    );
  }

}
class SensorTile extends StatelessWidget {
  const SensorTile({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        runSpacing: 8, // vertical spacing between elements
        spacing: 8,    // horizontal spacing if items wrap
        alignment: WrapAlignment.spaceBetween,
        children: [
          // Title + status
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.sunny_snowing),
              ),
              const Text(
                "Moisture Sensor",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Normal",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),

          // Value
           SizedBox(
             width: 280,
             child: Text(

              "8.0 CB",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                       ),
           ),
          // Min/Max info (short form)
          const Text(
            "↓Minimum:0",
            style: TextStyle(fontSize: 12),
          ),
          const Text(
            "↑Maximum:200 CB",
            style: TextStyle(fontSize: 12),
          ),
          const Text(
            "Average: 200 CB",
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

