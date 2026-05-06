
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/cropAdvisory/view/CropDetailsScreen.dart';
import 'package:oro_drip_irrigation/cropAdvisory/widgets/AppTextField.dart';
import 'package:oro_drip_irrigation/cropAdvisory/widgets/ContinueButton.dart';
import 'package:oro_drip_irrigation/cropAdvisory/widgets/ProgressWidget.dart';
import 'package:oro_drip_irrigation/cropAdvisory/widgets/SectionCard.dart';

class Getuserinformationscreen extends StatefulWidget {
  const Getuserinformationscreen({super.key});

  @override
  State<Getuserinformationscreen> createState() => _GetuserinformationscreenState();
}

class _GetuserinformationscreenState extends State<Getuserinformationscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Crop Advisory"),),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "Let's get started",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Tell us a bit about you to set up your farm profile.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                // const SizedBox(height: 20),
                const ProgressWidget(current: 1),
                const SizedBox(height: 20),

                SectionCard(
                  title: 'Share Location',
                  icon: Icons.location_on_outlined,
                  child: const AppTextField(
                    hint: 'Search Or Use Current Location',
                    suffix: Icon(Icons.my_location),
                  ),
                ),

                SectionCard(
                  title: 'Area(acre/ hectare)',
                  icon: Icons.map_outlined,
                  child: const AppTextField(
                    hint: '10(acre)',
                    suffix: Icon(Icons.keyboard_arrow_down),
                  ),
                ),

                SectionCard(
                  title: 'Plot / farm ID',
                  icon: Icons.edit,
                  child: const AppTextField(
                    hint: 'Enter The Plot Or Farm ID',
                  ),
                ),

                const SizedBox(height: 30),

                CropContinueButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CropDetailsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}