import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/repository/repository.dart';
import 'package:oro_drip_irrigation/services/http_service.dart';
import '../../utils/constants.dart';
import '../model/cropadvisory_model.dart';
import 'package:http/http.dart' as http;
import '../widgets/AppTextField.dart';
import '../widgets/ContinueButton.dart';
import '../widgets/ProgressWidget.dart';
import '../widgets/SectionCard.dart';
import 'crop_advisory_main_screen.dart';
import 'dashboard_screen.dart';

class FieldInformationScreen extends StatefulWidget {
  const FieldInformationScreen({super.key, required this.cropId,required this.edit});
  final int cropId;
  final bool edit;
  @override
  State<FieldInformationScreen> createState() => _FieldInformationScreenState();
}

class _FieldInformationScreenState extends State<FieldInformationScreen> {
  bool _mulchingValue = true;
  final TextEditingController _previousCropController = TextEditingController();
  String? _selectedSoilType;
  final CropAdvisoryModel _model = CropAdvisoryModel.instance;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields for editing
    String rawMulching = _model.mulchingUsed ?? 'true';
    if (rawMulching.toLowerCase() == 'true' || rawMulching.toLowerCase() == 'yes') {
      _mulchingValue = true;
    } else {
      _mulchingValue = false;
    }
    _previousCropController.text = _model.previousCrop ?? '';
    
    // Select option soilType if null or empty first one select ('1')
    String rawSoilType = _model.soilType ?? '';
    if (rawSoilType.isEmpty) {
      _selectedSoilType = '1';
    } else {
      if (['1', '2', '3', '4', '5'].contains(rawSoilType)) {
        _selectedSoilType = rawSoilType;
      } else {
        switch (rawSoilType) {
          case 'Clay Soil':
            _selectedSoilType = '1';
            break;
          case 'Loam Soil':
            _selectedSoilType = '2';
            break;
          case 'Sandy Soil':
            _selectedSoilType = '3';
            break;
          case 'Volcanic soil':
            _selectedSoilType = '4';
            break;
          case 'Others':
          default:
            _selectedSoilType = '5';
            break;
        }
      }
    }
  }

  @override
  void dispose() {
    _previousCropController.dispose();
    super.dispose();
  }

  Widget buildMulchingButton(String title) {
    bool isSelected = (title == 'Yes') ? _mulchingValue : !_mulchingValue;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _mulchingValue = (title == 'Yes');
          });
        },
        child: Container(
          height: 55,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xff0E8797).withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isSelected
                    ? const Color(0xff0E8797)
                    : Colors.grey.shade300),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? const Color(0xff0E8797) : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Improved soilItem with uniform image sizing and proper fitting
  Widget soilItem(String id, String title, [String? imagePath]) {
    bool isSelected = _selectedSoilType == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSoilType = id;
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
                  child: Row(
                    children: [
                      buildMulchingButton('Yes'),
                      const SizedBox(width: 12),
                      buildMulchingButton('No'),
                    ],
                  ),
                ),

                SectionCard(
                  title: 'Soil type',
                  icon: Icons.landscape,
                  child: Wrap(
                    spacing: 19,
                    runSpacing: 20,
                    children: [
                      soilItem('1', 'Clay Soil', 'assets/Images/CropAdvisory/clay_soil.png'),
                      soilItem('2', 'Loam Soil', 'assets/Images/CropAdvisory/loam_soil.png'),
                      soilItem('3', 'Sandy Soil', 'assets/Images/CropAdvisory/sandy_soil.png'),
                      soilItem('4', 'Volcanic soil', 'assets/Images/CropAdvisory/Volcanic_soil.png'),
                      soilItem('5', 'Others'), // now shows a help icon
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
                    _model.mulchingUsed = _mulchingValue.toString();
                    _model.soilType = _selectedSoilType;
                    _model.previousCrop = _previousCropController.text;
                    _model.cropId = widget.cropId;

                    print("Image Path : ${_model.cropImage}");

                    try {
                      var request = http.MultipartRequest(
                        'POST',
                        Uri.parse(
                          '${AppConstants.apiUrl}/user/cropAdvisoryInfo/create',
                        ),
                      );

                      // All data as form-data
                      request.fields.addAll({
                        'cropId': _model.cropId.toString(),
                        'userId': _model.userId.toString(),
                        'controllerId': _model.controllerId.toString(),
                        'latitude': _model.latitude.toString(),
                        'longitude': _model.longitude.toString(),
                        'address': _model.address ?? '',
                        'areaName': _model.areaName ?? '',
                        'cropName': _model.cropName ?? '',
                        'cropVariety': _model.cropVariety ?? '',
                        'plantingMethod': _model.plantingMethod ?? '',
                        'plantingDate': _model.plantingDate ?? '',
                        'expectedHarvestDate': _model.expectedHarvestDate ?? '',
                        'cropDuration': _model.cropDuration?.toString() ?? '',
                        'plantArrangement': _model.plantArrangement ?? '',
                        'cropType': _model.cropType ?? '',
                        'mulchingUsed': _model.mulchingUsed ?? '',
                        'soilType': _model.soilType ?? '',
                        'previousCrop': _model.previousCrop ?? '',
                        'deleteImageUrl': widget.edit ? _model.cropImage ?? '' : '',
                      });

                      // Image as file
                      if (_model.cropImage != null &&
                          _model.cropImage!.isNotEmpty) {
                        request.files.add(
                          await http.MultipartFile.fromPath(
                            'cropImage',
                            _model.cropImage!,
                          ),
                        );
                      }
                      print("Files Count : ${request.files.length}");
                      print("Fields : ${request.fields}");


                      for (var file in request.files) {
                        print("File Name : ${file.filename}");
                        print("Field Name : ${file.field}");
                      }

                      final response = await request.send();
                      final responseBody =
                      await response.stream.bytesToString();

                      print("Status Code : ${response.statusCode}");
                      print("Response : $responseBody");

                      if (response.statusCode == 200) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          CupertinoPageRoute(
                            builder: (context) =>
                            const CropAdvisoryMainScreen(),
                          ),
                              (route) => false,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to save crop: $responseBody',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      print("Error : $e");

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                        ),
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
