
class DiseaseIdentificationModel {
  static Map<String, dynamic> identifyDisease({
    required String cropType,
    required List<String> symptoms,
    required String affectedArea,
    Map<String, dynamic>? imageAnalysis,
  }) {
    // This is a simplified rule-based system
    // In a real implementation, you'd use ML models or API calls

    Map<String, dynamic> diseaseInfo = {
      'diseaseName': 'Unknown',
      'confidence': 0.0,
      'description': '',
      'symptoms': <String>[],
      'causes': <String>[],
      'solutions': <String>[],
      'prevention': <String>[],
      'severity': 'Low',
    };

    // Common diseases by crop type
    Map<String, List<Map<String, dynamic>>> cropDiseases = {
      'Wheat': [
        {
          'name': 'Wheat Rust',
          'symptoms': ['yellow spots', 'rust colored', 'leaf spots', 'orange pustules'],
          'areas': ['leaves', 'stem'],
          'description': 'A fungal disease causing rust-colored pustules on wheat plants',
          'solutions': [
            'Apply fungicide containing triazole compounds',
            'Remove infected plant debris',
            'Use resistant wheat varieties',
            'Ensure proper field drainage'
          ],
          'prevention': [
            'Plant resistant varieties',
            'Crop rotation with non-host crops',
            'Monitor weather conditions',
            'Avoid overhead irrigation'
          ],
          'severity': 'High',
          'imageMarkers': ['rust_spots', 'orange_pustules', 'leaf_discoloration']
        },
        {
          'name': 'Powdery Mildew',
          'symptoms': ['white powder', 'powdery coating', 'white spots'],
          'areas': ['leaves', 'stem'],
          'description': 'Fungal disease appearing as white powdery coating on leaves',
          'solutions': [
            'Apply sulfur-based fungicides',
            'Improve air circulation',
            'Remove affected leaves',
            'Use neem oil spray'
          ],
          'prevention': [
            'Avoid overcrowding plants',
            'Ensure good air circulation',
            'Water at soil level',
            'Apply preventive fungicide sprays'
          ],
          'severity': 'Medium',
          'imageMarkers': ['white_coating', 'powdery_texture', 'leaf_whitening']
        }
      ],
      'Rice': [
        {
          'name': 'Rice Blast',
          'symptoms': ['brown spots', 'lesions', 'diamond shaped spots'],
          'areas': ['leaves', 'stem'],
          'description': 'Fungal disease causing diamond-shaped lesions on rice leaves',
          'solutions': [
            'Apply tricyclazole fungicide',
            'Improve field drainage',
            'Reduce nitrogen fertilizer',
            'Remove infected plant debris'
          ],
          'prevention': [
            'Use resistant varieties',
            'Balanced fertilization',
            'Proper water management',
            'Crop rotation'
          ],
          'severity': 'High',
          'imageMarkers': ['diamond_lesions', 'brown_spots', 'leaf_burn']
        }
      ],
      'Tomato': [
        {
          'name': 'Early Blight',
          'symptoms': ['dark spots', 'concentric rings', 'yellowing'],
          'areas': ['leaves', 'fruits'],
          'description': 'Fungal disease causing dark spots with concentric rings',
          'solutions': [
            'Apply copper-based fungicides',
            'Remove infected leaves',
            'Improve air circulation',
            'Mulch around plants'
          ],
          'prevention': [
            'Crop rotation',
            'Avoid overhead watering',
            'Space plants properly',
            'Remove plant debris'
          ],
          'severity': 'Medium',
          'imageMarkers': ['concentric_rings', 'dark_spots', 'yellowing_leaves']
        },
        {
          'name': 'Late Blight',
          'symptoms': ['water soaked spots', 'brown patches', 'white mold'],
          'areas': ['leaves', 'fruits', 'stem'],
          'description': 'Serious fungal disease that can destroy entire crops',
          'solutions': [
            'Apply systemic fungicides immediately',
            'Remove all infected plants',
            'Improve drainage',
            'Apply copper sprays'
          ],
          'prevention': [
            'Use resistant varieties',
            'Avoid wet foliage',
            'Ensure good drainage',
            'Monitor weather conditions'
          ],
          'severity': 'Very High',
          'imageMarkers': ['water_soaked_spots', 'brown_patches', 'white_mold']
        }
      ]
    };

    List<Map<String, dynamic>> possibleDiseases = cropDiseases[cropType] ?? [];

    // Enhanced matching algorithm with image analysis
    double bestMatch = 0.0;
    Map<String, dynamic>? bestDisease;

    for (var disease in possibleDiseases) {
      double matchScore = 0.0;
      int totalChecks = 0;

      // Check symptom matches
      for (String symptom in symptoms) {
        totalChecks++;
        for (String diseaseSymptom in disease['symptoms']) {
          if (symptom.toLowerCase().contains(diseaseSymptom.toLowerCase()) ||
              diseaseSymptom.toLowerCase().contains(symptom.toLowerCase())) {
            matchScore += 1.0;
            break;
          }
        }
      }

      // Check affected area match
      totalChecks++;
      for (String area in disease['areas']) {
        if (area.toLowerCase() == affectedArea.toLowerCase()) {
          matchScore += 1.0;
          break;
        }
      }

      // Image-based analysis boost
      if (imageAnalysis != null && imageAnalysis['hasImage'] == true) {
        totalChecks += 2; // Give more weight to image analysis

        // Simulate image analysis results
        List<String> detectedFeatures = _simulateImageAnalysis(imageAnalysis);

        for (String feature in detectedFeatures) {
          if (disease['imageMarkers'] != null) {
            for (String marker in disease['imageMarkers']) {
              if (feature.toLowerCase().contains(marker.toLowerCase()) ||
                  marker.toLowerCase().contains(feature.toLowerCase())) {
                matchScore += 2.0; // Higher weight for image matches
                break;
              }
            }
          }
        }
      }

      double confidence = totalChecks > 0 ? (matchScore / totalChecks) * 100 : 0.0;

      if (confidence > bestMatch) {
        bestMatch = confidence;
        bestDisease = disease;
      }
    }

    if (bestDisease != null && bestMatch > 25) {
      diseaseInfo = {
        'diseaseName': bestDisease['name'],
        'confidence': bestMatch,
        'description': bestDisease['description'],
        'symptoms': bestDisease['symptoms'],
        'causes': ['Fungal infection', 'Environmental factors', 'Poor management'],
        'solutions': bestDisease['solutions'],
        'prevention': bestDisease['prevention'],
        'severity': bestDisease['severity'],
      };
    }

    return diseaseInfo;
  }

  static List<String> _simulateImageAnalysis(Map<String, dynamic> imageData) {
    // Simulate AI image analysis results
    // In a real implementation, this would call an ML model
    List<String> detectedFeatures = [];

    // Simulate common disease indicators that might be detected in images
    if (imageData['hasImage'] == true) {
      // Random simulation of detected features
      List<String> possibleFeatures = [
        'rust_spots',
        'white_coating',
        'brown_spots',
        'yellowing_leaves',
        'dark_spots',
        'concentric_rings',
        'water_soaked_spots',
        'leaf_discoloration',
        'powdery_texture',
        'diamond_lesions'
      ];

      // Simulate detection of 1-3 features
      for (int i = 0; i < 2; i++) {
        if (possibleFeatures.isNotEmpty) {
          detectedFeatures.add(possibleFeatures[i]);
        }
      }
    }

    return detectedFeatures;
  }
}