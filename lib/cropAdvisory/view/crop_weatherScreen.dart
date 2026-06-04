import 'dart:math';

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

  final ScrollController _controller = ScrollController();
  static const double itemWidth = 110;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;

      final offset =
          (DateTime.now().hour * itemWidth) -
              (screenWidth / 2) +
              (itemWidth / 2);

      _controller.jumpTo(
        offset.clamp(0.0, _controller.position.maxScrollExtent),
      );
    });
  }

  double getTemperature(int hour) {
    // Peak around 2 PM (14:00)
    const minTemp = 22;
    const maxTemp = 33;

    final radians = ((hour - 2) / 24) * 2 * pi;

    return minTemp +
        ((sin(radians - pi / 2) + 1) / 2) *
            (maxTemp - minTemp);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return  Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
      
                const WeatherHeader(temp: '32',),
      
                const SizedBox(height: 20),
      
                const WeatherInfoCard(humm: '23', rain: 'No', wind: '13',),
      
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
                  height: 100,
                  child: ListView.builder(
                    controller: _controller,
                    scrollDirection: Axis.horizontal,
                    itemCount: 24,
                    itemBuilder: (context, index) {
                      final temp = getTemperature(index).round();

                      final hourTime = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        index,
                      );

                      final isCurrentHour = index == now.hour;

                      final time =
                          "${hourTime.hour % 12 == 0 ? 12 : hourTime.hour % 12} "
                          "${hourTime.hour >= 12 ? "pm" : "am"}";

                      return SizedBox(
                        width: 110,
                        child: HourlyWeatherCard(
                          time: time,
                          temp: '$temp°',
                          isHour: isCurrentHour,
                        ),
                      );
                    },
                  ),
                ),
      
                const SizedBox(height: 20),
      
                 const Row(
                  children: [
                    Expanded(child: AirQualityCard(co2: '558',)),
                    SizedBox(width: 12),
                    Expanded(child: CropRainfallCard(rainfall: '1',)),
                  ],
                ),
      
                const SizedBox(height: 20),
      
                const WindDetailsCard(direction: '260', speed: '13', gust: '4',),
              ],
            ),
          ),
        ),
    );


  }
}
