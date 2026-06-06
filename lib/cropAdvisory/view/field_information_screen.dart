import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/repository/repository.dart';
import 'package:oro_drip_irrigation/services/http_service.dart';
import '../model/cropadvisory_model.dart';

import '../widgets/AppTextField.dart';
import '../widgets/ContinueButton.dart';
import '../widgets/ProgressWidget.dart';
import '../widgets/SectionCard.dart';
import 'crop_advisory_main_screen.dart';
import 'dashboard_screen.dart';

class FieldInformationScreen extends StatefulWidget {
  const FieldInformationScreen({super.key, required this.cropId});
  final int cropId;

  @override
  State<FieldInformationScreen> createState() => _FieldInformationScreenState();
}

class _FieldInformationScreenState extends State<FieldInformationScreen> {
  final TextEditingController _mulchingController = TextEditingController(text: 'Yes');
  final TextEditingController _previousCropController = TextEditingController();
  String? _selectedSoilType;
  final CropAdvisoryModel _model = CropAdvisoryModel.instance;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields for editing
    _mulchingController.text = _model.mulchingUsed ?? 'Yes';
    _previousCropController.text = _model.previousCrop ?? '';
    _selectedSoilType = _model.soilType;
  }

  @override
  void dispose() {
    _mulchingController.dispose();
    _previousCropController.dispose();
    super.dispose();
  }

  // Improved soilItem with uniform image sizing and proper fitting
  Widget soilItem(String title, [String? imagePath]) {
    bool isSelected = _selectedSoilType == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSoilType = title;
        });
      },
      child: Container(
        width: 100,
        height: 120,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff0E8797).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? const Color(0xff0E8797) : Colors.grey.shade300, width: isSelected ? 2 : 1),
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
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xff0E8797) : Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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

                if (_model.address?.isNotEmpty ?? false)
                  SectionCard(
                    title: 'Selected Location',
                    icon: Icons.location_on,
                    child: Text(
                      _model.address!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                SectionCard(
                  title: 'Mulching used',
                  icon: Icons.eco,
                  child: AppTextField(
                    controller: _mulchingController,
                    hint: 'Yes',
                    suffix: const Icon(Icons.keyboard_arrow_down),
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

                SectionCard(
                  title: 'Previous crop grown',
                  icon: Icons.energy_savings_leaf,
                  child: AppTextField(
                    controller: _previousCropController,
                    hint: 'Search Or Select The Crop(Eg.Rice,etc..)',
                    suffix: const Icon(Icons.keyboard_arrow_down),
                  ),
                ),

                const SizedBox(height: 30),

                CropContinueButton(
                  onTap: () async {
                    // Final update to the model singleton
                    _model.mulchingUsed = _mulchingController.text;
                    _model.soilType = _selectedSoilType;
                    _model.previousCrop = _previousCropController.text;
                    _model.cropId = widget.cropId;

                    // Printing all data for verification
                    debugPrint('Sending Data: ${_model.toJson()}');

                    try {
                      final repository = Repository(HttpService());
                      // Assuming createCropList handles both create and update
                      final response = await repository.createCropList(_model.toJson());
                      
                      if (response.statusCode == 200) {
                        // Navigate to Dashboard and clear the stack to restrict access back to setup
                        Navigator.pushAndRemoveUntil(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const CropAdvisoryMainScreen(),
                          ),
                          (route) => false,
                        );
                      } else {
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to save crop: ${response.body}')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
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
