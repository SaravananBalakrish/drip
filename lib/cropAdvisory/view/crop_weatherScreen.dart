import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/crop_air_quality_card.dart';
import '../widgets/crop_hourly_weather_card.dart';
import '../widgets/crop_rainfall_card.dart';
import '../widgets/crop_weather_header.dart';
import '../widgets/crop_weather_info_card.dart';
import '../widgets/crop_wind_details_card.dart';

class CropWeatherscreen extends StatefulWidget {
  const CropWeatherscreen({super.key});

  @override
  State<CropWeatherscreen> createState() => _CropWeatherscreenState();
}

class _CropWeatherscreenState extends State<CropWeatherscreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
      
                const WeatherHeader(),
      
                const SizedBox(height: 20),
      
                const WeatherInfoCard(),
      
                const SizedBox(height: 20),
      
                const Row(
                  children: [
                    Text(
                      "Today",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
      
                    SizedBox(width: 20),
      
                    Text(
                      "Tomorrow",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),
      
                    SizedBox(width: 20),
      
                    Text(
                      "Next 7 Days",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
      
                const SizedBox(height: 20),
      
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      HourlyWeatherCard(
                        time: "10 am",
                        temp: "36°",
                      ),
                      HourlyWeatherCard(
                        time: "11 am",
                        temp: "27°",
                      ),
                      HourlyWeatherCard(
                        time: "12 pm",
                        temp: "38°",
                      ),
                      HourlyWeatherCard(
                        time: "01 pm",
                        temp: "39°",
                      ),
                    ],
                  ),
                ),
      
                const SizedBox(height: 20),
      
                const Row(
                  children: [
                    Expanded(child: AirQualityCard()),
                    SizedBox(width: 12),
                    Expanded(child: CropRainfallCard()),
                  ],
                ),
      
                const SizedBox(height: 20),
      
                const WindDetailsCard(),
              ],
            ),
          ),
        ),
    );


  }
}
