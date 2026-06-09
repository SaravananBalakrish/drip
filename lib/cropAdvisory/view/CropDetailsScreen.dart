import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/cropAdvisory/view/field_information_screen.dart';
import 'package:path_provider/path_provider.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../helper/image_compressor.dart';
import '../model/cropadvisory_model.dart';
import 'package:http/http.dart' as http;

import '../widgets/AppTextField.dart';
import '../widgets/ContinueButton.dart';
import '../widgets/ProgressWidget.dart';
import '../widgets/SectionCard.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CropDetailsScreen extends StatefulWidget {
  const CropDetailsScreen({super.key, required this.cropId, required this.edit} );
  final cropId;
  final bool edit;
  @override
  State<CropDetailsScreen> createState() => _CropDetailsScreenState();
}

class _CropDetailsScreenState extends State<CropDetailsScreen> {
  final TextEditingController _cropNameController = TextEditingController();
  final TextEditingController _varietyController = TextEditingController();
  final TextEditingController _plantingDateController = TextEditingController();
  final TextEditingController _harvestDateController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _arrangementController = TextEditingController();
  final TextEditingController _cropTypeController = TextEditingController();

  String _plantingMethod = 'Sowing';
  final CropAdvisoryModel _model = CropAdvisoryModel.instance;
  File? cropImage;
  final ImagePicker _picker = ImagePicker();
  Uint8List? webImage;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields from singleton instance if they have values
    _cropNameController.text = _model.cropName ?? '';
    _varietyController.text = _model.cropVariety ?? '';
    _plantingDateController.text = _model.plantingDate ?? '';
    _harvestDateController.text = _model.expectedHarvestDate ?? '';
    _durationController.text = _model.cropDuration ?? '';
    _arrangementController.text = _model.plantArrangement ?? '';
    _cropTypeController.text = _model.cropType ?? '';
    if (_model.plantingMethod != null) {
      _plantingMethod = _model.plantingMethod!;
    }
  }

  @override
  void dispose() {
    _cropNameController.dispose();
    _varietyController.dispose();
    _plantingDateController.dispose();
    _harvestDateController.dispose();
    _durationController.dispose();
    _arrangementController.dispose();
    _cropTypeController.dispose();
    super.dispose();
  }

  Widget buildMethodButton(String title) {
    bool isSelected = _plantingMethod == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _plantingMethod = title;
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

  Future<void> openCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );

    if (image == null) return;

    final Uint8List bytes = await image.readAsBytes();

    final originalSize = bytes.lengthInBytes / 1024;

    print("Original Size : ${originalSize.toStringAsFixed(2)} KB");

    if (kIsWeb) {
      setState(() {
        webImage = bytes;
      });
      return;
    }

    // MOBILE ONLY BELOW
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/cropImage.jpg');
    await file.writeAsBytes(bytes);

    final compressedFile = await ImageCompressHelper.compressImage(file);

    if (compressedFile != null) {
      final compressedSize = await compressedFile.length() / 1024;

      print("Compressed Size : ${compressedSize.toStringAsFixed(2)} KB");

      setState(() {
        cropImage = compressedFile;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.now();
    if (controller.text.isNotEmpty) {
      final parsed = DateTime.tryParse(controller.text);
      if (parsed != null) {
        initialDate = parsed;
      }
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
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
                if (_model.areaName?.isNotEmpty ?? false)
                  SectionCard(
                    title: 'Selected Area',
                    icon: Icons.square_foot,
                    child: Text(
                      _model.areaName!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                SectionCard(
                  title: 'Crop Name',
                  icon: Icons.energy_savings_leaf,
                  child: AppTextField(
                    controller: _cropNameController,
                    hint: 'Search Or Select The Crop(Eg.Rice,etc..)',
                    suffix: const Icon(Icons.keyboard_arrow_down),
                  ),
                ),
                SectionCard(
                  title: 'Variety or Hybrid (Seed Type)',
                  icon: Icons.spa,
                  child: AppTextField(
                    controller: _varietyController,
                    hint: 'Search Or Select Variety Or Hybrid',
                    suffix: const Icon(Icons.keyboard_arrow_down),
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
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Planting Date',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                AppTextField(
                                  controller: _plantingDateController,
                                  hint: 'Select Date',
                                  readOnly: true,
                                  onTap: () => _selectDate(context, _plantingDateController),
                                  suffix: const Icon(Icons.calendar_month),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Expected Harvest Date',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                AppTextField(
                                  controller: _harvestDateController,
                                  hint: 'Select Date',
                                  readOnly: true,
                                  onTap: () => _selectDate(context, _harvestDateController),
                                  suffix: const Icon(Icons.calendar_month),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SectionCard(
                  title: 'Crop Duration',
                  icon: Icons.agriculture,
                  child: AppTextField(
                    controller: _durationController,
                    hint: 'Select The growth period',
                    suffix: const Icon(Icons.keyboard_arrow_down),
                  ),
                ),
                SectionCard(
                  title: 'Plant Arrangement',
                  icon: Icons.grid_view,
                  child: AppTextField(
                    controller: _arrangementController,
                    hint: 'Select The Plant Arrangement',
                    suffix: const Icon(Icons.keyboard_arrow_down),
                  ),
                ),
                SectionCard(
                  title: 'Crop type',
                  icon: Icons.park,
                  child: AppTextField(
                    controller: _cropTypeController,
                    hint: 'Select The Type Of Cultivation Environment',
                    suffix: const Icon(Icons.keyboard_arrow_down),
                  ),
                ),
                SectionCard(
                  title: 'Crop Image',
                  icon: Icons.photo,
                  child: GestureDetector(
                    onTap: openCamera,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: (cropImage == null && webImage == null)
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Capture Crop Image',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Icon(Icons.camera_alt),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: kIsWeb
                                    ? (webImage != null
                                        ? Image.memory(
                                            webImage!,
                                            height: 180,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                        : const SizedBox())
                                    : (cropImage != null
                                        ? Image.file(
                                            cropImage!,
                                            height: 180,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                        : const SizedBox()),
                              ),
                            ),
                    ),
                  ),
                ),
                CropContinueButton(
                  onTap: () async {
                     // Update singleton instance with data from this screen
                    _model.cropName = _cropNameController.text;
                    _model.cropVariety = _varietyController.text;
                    _model.plantingMethod = _plantingMethod;
                    _model.plantingDate = _plantingDateController.text;
                    _model.expectedHarvestDate = _harvestDateController.text;
                    _model.cropDuration = _durationController.text;
                    _model.plantArrangement = _arrangementController.text;
                    _model.cropType = _cropTypeController.text;
                    _model.cropImage = kIsWeb ? '' : cropImage?.path;
                    _model.cropImageBytes = kIsWeb ? webImage : null;

                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => FieldInformationScreen(
                          cropId: widget.cropId, edit: widget.edit,
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
