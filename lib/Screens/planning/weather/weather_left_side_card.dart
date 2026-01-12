
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget weatherCardLeft({
  required String city,
   required String date,
  required String temperature,
  required String feelsLike,
  required IconData weatherIcon,
  required String wind,
  required String humidity,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.location_solid),
              const SizedBox(width: 6),
              Text(city),
            ],
          ),
          const SizedBox(height: 12),

          Text(date),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    temperature,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text("Feel Like $feelsLike °C"),
                ],
              ),
              const SizedBox(width: 20),
              Icon(weatherIcon, size: 100, color: Colors.orange),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoBox(
                  CupertinoIcons.wind,
                  "Wind Status",
                  wind,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoBox(
                  CupertinoIcons.drop_fill,
                  "Humidity",
                  humidity,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget sunCard() {
  return Row(
    children: const [
      Expanded(child: _SunTimeCard("Sunrise", "4:50 AM",'assets/Images/sunrise.png')),
      SizedBox(width: 12),
      Expanded(child: _SunTimeCard("Sunset", "6:45 PM",'assets/Images/sunset.png')),
    ],
  );
}

class _SunTimeCard extends StatelessWidget {
  final String title;
  final String time;
  final String image;

  const _SunTimeCard(this.title, this.time,this.image);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2F8F7A),
        borderRadius: BorderRadius.circular(14),
      ),
      child:
      Row(
        children: [
          Image.asset(image,
            width: 50.0,
            height: 50.0,
            fit: BoxFit.cover,
          ),
          SizedBox(width: 5,),
          Column(
            children: [
              Text(title, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 6),
              Text(
                time,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),

    );
  }
}


class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoBox( this.icon,this.title, this.value,);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon),
              Text(title),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}