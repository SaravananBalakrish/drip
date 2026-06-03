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
  final ScrollController _scrollController = ScrollController();

  final double cardWidth = 90;

  late int currentHour;
  void _scrollToCurrentHour() {
    final screenWidth = MediaQuery.of(context).size.width;

    final offset =
        (currentHour * cardWidth) - (screenWidth / 2) + (cardWidth / 2);

    _scrollController.animateTo(
      offset.clamp(
        0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  String formatHour(int hour) {
    final period = hour >= 12 ? "PM" : "AM";
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return "$displayHour $period";
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentHour = DateTime.now().hour;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentHour();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                height: 120,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: 24,
                  itemBuilder: (context, index) {
                    final isCurrentHour = index == currentHour;

                    return SizedBox(
                      width: cardWidth,
                      child: HourlyWeatherCard(
                        time: formatHour(index),
                        temp: "${25 + index % 10}°",
                        isSelected: isCurrentHour,
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
