import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/AppTextField.dart';
import '../widgets/ContinueButton.dart';
import '../widgets/ProgressWidget.dart';
import '../widgets/SectionCard.dart';
class FieldInformationScreen extends StatefulWidget {
  const FieldInformationScreen({super.key});

  @override
  State<FieldInformationScreen> createState() => _FieldInformationScreenState();
}

class _FieldInformationScreenState extends State<FieldInformationScreen> {
  Widget soilItem(String title) {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                ),
              ),
              const SizedBox(height: 20),
              const ProgressWidget(current: 3),
              const SizedBox(height: 20),

              SectionCard(
                title: 'Mulching used',
                icon: Icons.eco,
                child: const AppTextField(
                  hint: 'Yes',
                  suffix: Icon(Icons.keyboard_arrow_down),
                ),
              ),

              SectionCard(
                title: 'Soil type',
                icon: Icons.landscape,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    soilItem('Loam'),
                    soilItem('Sandy Soil'),
                    soilItem('Clay Soil'),
                    soilItem('Manual'),
                    soilItem('Others'),
                  ],
                ),
              ),

              SectionCard(
                title: 'Previous crop grown',
                icon: Icons.energy_savings_leaf,
                child: const AppTextField(
                  hint: 'Search Or Select The Crop(Eg.Rice,etc..)',
                  suffix: Icon(Icons.keyboard_arrow_down),
                ),
              ),

              const Spacer(),

              CropContinueButton(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Completed Successfully'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
