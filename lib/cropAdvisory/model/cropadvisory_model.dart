import 'dart:typed_data';
import 'package:flutter/material.dart';

class CropAdvisoryModel extends ChangeNotifier {
  static final CropAdvisoryModel instance = CropAdvisoryModel._internal();

  factory CropAdvisoryModel() {
    return instance;
  }

  factory CropAdvisoryModel.fromJson(Map<String, dynamic> json) {
    return CropAdvisoryModel()
      ..cropId = json['cropId']
      ..userId = json['userId']
      ..controllerId = json['controllerId']
      ..latitude = json['latitude']
      ..longitude = json['longitude']
      ..address = json['address']
      ..areaName = json['areaName']
      ..cropName = json['cropName']
      ..cropVariety = json['cropVariety']
      ..plantingMethod = json['plantingMethod']
      ..plantingDate = json['plantingDate']
      ..expectedHarvestDate = json['expectedHarvestDate']
      ..cropDuration = json['cropDuration']
      ..plantArrangement = json['plantArrangement']
      ..cropType = json['cropType']
      ..mulchingUsed = json['mulchingUsed']?.toString()
      ..soilType = json['soilType']?.toString()
      ..previousCrop = json['previousCrop']?.toString()
      ..farmName = json['farmName']?.toString()
      ..cropImage = json['cropImage'];
  }
  CropAdvisoryModel._internal();

  // User Information
  int? cropId;
  int? userId;
  int? controllerId;
  String? latitude;
  String? longitude;
  String? address;
  String? areaName;

   // Crop Details
  String? cropName;
  String? cropVariety;
  String? plantingMethod;
  String? plantingDate;
  String? expectedHarvestDate;
  String? cropDuration;
  String? plantArrangement;
  String? cropType;
  String? farmName;

  // Field Information
  String? mulchingUsed;
  String? soilType;
  String get soilTypeName {
    switch (soilType) {
      case '1':
        return 'Clay Soil';
      case '2':
        return 'Loam Soil';
      case '3':
        return 'Sandy Soil';
      case '4':
        return 'Volcanic soil';
      case '5':
        return 'Others';
      default:
        return soilType ?? 'Loam';
    }
  }
  String? previousCrop;
  String? cropImage;
  Uint8List? cropImageBytes;

  void updateLocation({String? lat, String? lng, String? addr}) {
    latitude = lat;
    longitude = lng;
    address = addr;
    notifyListeners();
  }

  void reset() {
    cropId = null;
    userId = null;
    controllerId = null;
    latitude = null;
    longitude = null;
    address = null;
    areaName = null;
    cropName = null;
    cropVariety = null;
    plantingMethod = null;
    plantingDate = null;
    expectedHarvestDate = null;
    cropDuration = null;
    plantArrangement = null;
    cropType = null;
    mulchingUsed = null;
    soilType = null;
    previousCrop = null;
    cropImage = null;
    cropImageBytes = null;
    farmName = null;
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'cropId': cropId,
      'userId': userId,
      'controllerId': controllerId,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'areaName': areaName,
      'cropName': cropName,
      'cropVariety': cropVariety,
      'plantingMethod': plantingMethod,
      'plantingDate': plantingDate,
      'expectedHarvestDate': expectedHarvestDate,
      'cropDuration': cropDuration,
      'plantArrangement': plantArrangement,
      'cropType': cropType,
      'mulchingUsed': mulchingUsed,
      'soilType': soilType,
      'previousCrop': previousCrop,
      'cropImage': cropImage,
      'farmName': farmName,
    };
  }

  void fromJson(Map<String, dynamic> json) {
    cropId = json['cropId'];
    userId = json['userId'];
    controllerId = json['controllerId'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    address = json['address'];
    areaName = json['areaName'];
    cropName = json['cropName'];
    cropVariety = json['cropVariety'];
    plantingMethod = json['plantingMethod'];
    plantingDate = json['plantingDate'];
    expectedHarvestDate = json['expectedHarvestDate'];
    cropDuration = json['cropDuration'];
    plantArrangement = json['plantArrangement'];
    cropType = json['cropType'];
    mulchingUsed = json['mulchingUsed'];
    soilType = json['soilType'];
    previousCrop = json['previousCrop'];
    cropImage = json['cropImage'];
    farmName = json['farmName'];
    notifyListeners();
  }
}
