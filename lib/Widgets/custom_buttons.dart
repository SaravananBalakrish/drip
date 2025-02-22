import 'package:flutter/material.dart';

class CustomMaterialButton extends StatelessWidget {
  void Function()? onPressed;
  String? title;
  CustomMaterialButton({super.key, this.onPressed, this.title});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
      onPressed: onPressed ?? () {
        Navigator.of(context).pop(); // Dismiss the alert
      },
      child: Text(
        title ?? "OK",
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

