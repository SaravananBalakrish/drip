import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/weather_info.dart';

class WeatherHeader extends StatelessWidget {
  const WeatherHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 320,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0E6F78), Color(0xFF1BA6B2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          bottom: -1,
          left: 0,
          right: 0,
          child: ClipPath(
            clipper: CurveClipper(),
            child: Container(height: 60, color: Colors.white),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text(
                "Testing Farm",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    "34°C",
                    style: TextStyle(
                      fontSize: 48,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    children: const [
                      Icon(Icons.wb_sunny, color: Colors.orange, size: 48),
                      Text("Sunny", style: TextStyle(color: Colors.white)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  WeatherInfo(
                    icon: Icons.water,
                    value: "41",
                    unit: "%",
                  ),
                  SizedBox(width: 24),

                  WeatherInfo(
                    icon: Icons.air,
                    value: "125",
                    unit: "km/h",
                  ),
                  SizedBox(width: 24),

                  WeatherInfo(
                    icon: Icons.thermostat,
                    value: "4997",
                    unit: "hPa",
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.quadraticBezierTo(
      size.width / 2,
      40,
      size.width,
      0,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
