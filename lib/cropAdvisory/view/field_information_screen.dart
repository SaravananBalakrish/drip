import 'package:flutter/material.dart';

import '../widgets/AppTextField.dart';
import '../widgets/ContinueButton.dart';
import '../widgets/ProgressWidget.dart';
import '../widgets/SectionCard.dart';

class FieldInformationScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String address;
  final String area;
  final String farmId;

  const FieldInformationScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.area,
    required this.farmId,
  });

  @override
  State<FieldInformationScreen> createState() => _FieldInformationScreenState();
}

class _FieldInformationScreenState extends State<FieldInformationScreen> {
  // Improved soilItem with uniform image sizing and proper fitting
  Widget soilItem(String title, [String? imagePath]) {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Fixed-size image area with ClipRRect for rounded corners
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100, // subtle background while loading
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imagePath != null
                  ? Image.asset(
                imagePath,
                fit: BoxFit.cover, // fills the box without distortion
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.grey,
                ),
              )
                  : const Icon(
                Icons.help_outline, // clear icon for "Others"
                size: 40,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Field Information',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Tell us what you’re growing and how it’s cultivated.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                const ProgressWidget(current: 3),
                const SizedBox(height: 20),

                if (widget.address.isNotEmpty)
                  SectionCard(
                    title: 'Selected Location',
                    icon: Icons.location_on,
                    child: Text(
                      widget.address,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                const SectionCard(
                  title: 'Mulching used',
                  icon: Icons.eco,
                  child: AppTextField(
                    hint: 'Yes',
                    suffix: Icon(Icons.keyboard_arrow_down),
                  ),
                ),

                SectionCard(
                  title: 'Soil type',
                  icon: Icons.landscape,
                  child: Wrap(
                    spacing: 19,
                    runSpacing: 20,
                    children: [
                      soilItem('Clay Soil', 'assets/Images/CropAdvisory/clay_soil.png'),
                      soilItem('Loam Soil', 'assets/Images/CropAdvisory/loam_soil.png'),
                      soilItem('Sandy Soil', 'assets/Images/CropAdvisory/sandy_soil.png'),
                      soilItem('Volcanic soil', 'assets/Images/CropAdvisory/Volcanic_soil.png'),
                      soilItem('Others'), // now shows a help icon
                    ],
                  ),
                ),

                const SectionCard(
                  title: 'Previous crop grown',
                  icon: Icons.energy_savings_leaf,
                  child: AppTextField(
                    hint: 'Search Or Select The Crop(Eg.Rice,etc..)',
                    suffix: Icon(Icons.keyboard_arrow_down),
                  ),
                ),

                const SizedBox(height: 30),

                CropContinueButton(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Completed Successfully\n'
                              'Location: ${widget.latitude}, ${widget.longitude}\n'
                              'Address: ${widget.address}\n'
                              'Area: ${widget.area}\n'
                              'Farm ID: ${widget.farmId}',
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}