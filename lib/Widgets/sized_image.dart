import 'package:flutter/material.dart';

class SizedImage extends StatelessWidget {
  final String imagePath;
  const SizedImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: Image.asset(imagePath),
    );
  }
}

class SizedImageMedium extends StatelessWidget {
  final String imagePath;
  const SizedImageMedium({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Image.asset(imagePath),
    );
  }
}

class SizedImageSmall extends StatelessWidget {
  final String imagePath;
  const SizedImageSmall({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Image.asset(imagePath),
    );
  }
}
