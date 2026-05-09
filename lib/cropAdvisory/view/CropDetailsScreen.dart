import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/cropAdvisory/view/field_information_screen.dart';

import '../widgets/AppTextField.dart';
import '../widgets/ContinueButton.dart';
import '../widgets/ProgressWidget.dart';
import '../widgets/SectionCard.dart';

class CropDetailsScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String address;
  final String area;
  final String farmId;

  const CropDetailsScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.area,
    required this.farmId,
  });

  @override
  State<CropDetailsScreen> createState() => _CropDetailsScreenState();
}

class _CropDetailsScreenState extends State<CropDetailsScreen> {
  // You can use these to display or just hold the received data
  double? get latitude => widget.latitude;
  double? get longitude => widget.longitude;
  String get address => widget.address;
  String get area => widget.area;
  String get farmId => widget.farmId;

  Widget buildMethodButton(String title) {
    return Expanded(
      child: Container(
        height: 55,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Flexible(
                      child: Center(
                        child: Text(
                          'Crop Details',
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
                const ProgressWidget(current: 2),
                const SizedBox(height: 20),

                if (address.isNotEmpty)
                  SectionCard(
                    title: 'Selected Location',
                    icon: Icons.location_on,
                    child: Text(
                      address,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                if (area.isNotEmpty)
                  SectionCard(
                    title: 'Selected Area',
                    icon: Icons.square_foot,
                    child: Text(
                      area,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

               const SectionCard(
                  title: 'Crop Name',
                  icon: Icons.energy_savings_leaf,
                  child:  AppTextField(
                    hint: 'Search Or Select The Crop(Eg.Rice,etc..)',
                    suffix: Icon(Icons.keyboard_arrow_down),
                  ),
                ),

               const SectionCard(
                  title: 'Variety or Hybrid (Seed Type)',
                  icon: Icons.spa,
                  child:  AppTextField(
                    hint: 'Search Or Select Variety Or Hybrid',
                    suffix: Icon(Icons.keyboard_arrow_down),
                  ),
                ),

                SectionCard(
                  title: 'Planting Details',
                  icon: Icons.grass,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Method',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          buildMethodButton('Sowing'),
                          const SizedBox(width: 12),
                          buildMethodButton('Transplanting'),
                        ],
                      ),
                       const SizedBox(height: 18),
                      const Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 Text(
                                  'Planting Date',
                                  style: TextStyle(fontSize: 16),
                                ),
                                 SizedBox(height: 8),
                                 AppTextField(
                                  hint: 'Select Date',
                                  suffix: Icon(Icons.calendar_month),
                                ),
                              ],
                            ),
                          ),
                           SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 Text(
                                  'Expected Harvest Date',
                                  style: TextStyle(fontSize: 16),
                                ),
                                 SizedBox(height: 8),
                                 AppTextField(
                                  hint: 'Auto-Calculate',
                                  suffix: Icon(Icons.calendar_month),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SectionCard(
                  title: 'Crop Duration',
                  icon: Icons.agriculture,
                  child:  AppTextField(
                    hint: 'Select The growth period',
                    suffix: Icon(Icons.keyboard_arrow_down),
                  ),
                ),

               const SectionCard(
                  title: 'Plant Arrangement',
                  icon: Icons.grid_view,
                  child:  AppTextField(
                    hint: 'Select The Plant Arrangement',
                    suffix: Icon(Icons.keyboard_arrow_down),
                  ),
                ),

                const SectionCard(
                  title: 'Crop type',
                  icon: Icons.park,
                  child:  AppTextField(
                    hint: 'Select The Type Of Cultivation Environment',
                    suffix: Icon(Icons.keyboard_arrow_down),
                  ),
                ),

                CropContinueButton(
                  onTap: () {
                    // Pass all collected data (including from this screen if needed) to the next
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FieldInformationScreen(
                          latitude: latitude,
                          longitude: longitude,
                          address: address,
                          area: area,
                          farmId: farmId,
                          // Add future data captured here if you plan to collect it
                        ),
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