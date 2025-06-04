import 'package:flutter/material.dart';
import 'dart:io';

import '../model/plant_disease_identification.dart';

class DiseaseIdentificationStep extends StatefulWidget {
  final String cropType;
  final File? cropImage;
  final Function(Map<String, dynamic>) onDiseaseIdentified;

  const DiseaseIdentificationStep({
    super.key,
    required this.cropType,
    this.cropImage,
    required this.onDiseaseIdentified,
  });

  @override
  State<DiseaseIdentificationStep> createState() => _DiseaseIdentificationStepState();
}

class _DiseaseIdentificationStepState extends State<DiseaseIdentificationStep> {
  final List<String> _selectedSymptoms = [];
  String _affectedArea = 'leaves';
  String _additionalNotes = '';
  Map<String, dynamic>? _diseaseResult;
  bool _isAnalyzing = false;

  final List<String> _commonSymptoms = [
    'Yellow spots',
    'Brown spots',
    'White powder',
    'Black spots',
    'Rust colored',
    'Wilting',
    'Curling leaves',
    'Holes in leaves',
    'Stunted growth',
    'Discolored veins',
    'Moldy appearance',
    'Water-soaked spots',
    'Concentric rings',
    'Orange pustules'
  ];

  final List<String> _affectedAreas = [
    'leaves',
    'stem',
    'roots',
    'fruits',
    'whole plant'
  ];

  void _analyzeDisease() {
    setState(() {
      _isAnalyzing = true;
    });

    // Simulate analysis delay
    Future.delayed(const Duration(seconds: 3), () {
      Map<String, dynamic>? imageAnalysis;

      if (widget.cropImage != null) {
        // Simulate image analysis
        imageAnalysis = {
          'hasImage': true,
          'imagePath': widget.cropImage!.path,
          'analysisTimestamp': DateTime.now().millisecondsSinceEpoch,
        };
      }

      final result = DiseaseIdentificationModel.identifyDisease(
        cropType: widget.cropType,
        symptoms: _selectedSymptoms,
        affectedArea: _affectedArea,
        imageAnalysis: imageAnalysis,
      );

      setState(() {
        _diseaseResult = result;
        _isAnalyzing = false;
      });

      widget.onDiseaseIdentified(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Disease Identification',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Help us identify potential diseases affecting your ${widget.cropType}',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 24),

          // Image Analysis Status Card
          if (widget.cropImage != null) _buildImageAnalysisCard(),
          if (widget.cropImage != null) const SizedBox(height: 16),

          _buildInfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Symptoms',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildSymptomSelection(),
                const SizedBox(height: 24),

                const Text(
                  'Affected Area',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _buildAffectedAreaSelection(),
                const SizedBox(height: 20),

                TextField(
                  decoration: InputDecoration(
                    labelText: 'Additional Notes (Optional)',
                    hintText: 'Describe any other observations...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                  onChanged: (value) => _additionalNotes = value,
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : _analyzeDisease,
                    icon: _isAnalyzing
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Icon(Icons.biotech),
                    label: Text(_isAnalyzing ? 'Analyzing...' : 'Identify Disease'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_diseaseResult != null) _buildDiseaseResultCard(),
        ],
      ),
    );
  }

  Widget _buildImageAnalysisCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                widget.cropImage!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.camera_alt, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Image Analysis Ready',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'AI will analyze your crop image for disease indicators',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomSelection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _commonSymptoms.map((symptom) {
        final isSelected = _selectedSymptoms.contains(symptom);
        return FilterChip(
          label: Text(symptom),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedSymptoms.add(symptom);
              } else {
                _selectedSymptoms.remove(symptom);
              }
            });
          },
          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
          checkmarkColor: Theme.of(context).primaryColor,
        );
      }).toList(),
    );
  }

  Widget _buildAffectedAreaSelection() {
    return Wrap(
      spacing: 8,
      children: _affectedAreas.map((area) {
        return ChoiceChip(
          label: Text(area.toUpperCase()),
          selected: _affectedArea == area,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _affectedArea = area;
              });
            }
          },
          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        );
      }).toList(),
    );
  }

  Widget _buildDiseaseResultCard() {
    final result = _diseaseResult!;
    final confidence = result['confidence'] as double;
    final severity = result['severity'] as String;

    Color severityColor = Colors.green;
    if (severity == 'Medium') severityColor = Colors.orange;
    if (severity == 'High') severityColor = Colors.red;
    if (severity == 'Very High') severityColor = Colors.red[900]!;

    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: _buildInfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_hospital, color: severityColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result['diseaseName'],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: severityColor),
                  ),
                  child: Text(
                    '$severity Risk',
                    style: TextStyle(
                      color: severityColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Confidence: ${confidence.toStringAsFixed(1)}%',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (widget.cropImage != null) ...[
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image, size: 12, color: Colors.blue[700]),
                        const SizedBox(width: 4),
                        Text(
                          'Image Enhanced',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              result['description'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            _buildSolutionSection('Immediate Solutions', result['solutions'], Icons.medical_services),
            const SizedBox(height: 16),
            _buildSolutionSection('Prevention Tips', result['prevention'], Icons.shield),
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionSection(String title, List<dynamic> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 28, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(child: Text(item.toString())),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}