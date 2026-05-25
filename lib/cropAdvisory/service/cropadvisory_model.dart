import 'package:flutter/material.dart';

class CropAdvisoryModel extends ChangeNotifier {
  static final CropAdvisoryModel instance = CropAdvisoryModel._internal();

  factory CropAdvisoryModel() {
    return instance;
  }

  CropAdvisoryModel._internal();

  // User Information
  String? latitude;
  String? longitude;
  String? address;
  String? area;
  String? farmId;
  // Crop Details
  String? cropName;
  String? variety;
  String? plantingMethod;
  String? plantingDate;
  String? expectedHarvestDate;
  String? cropDuration;
  String? plantArrangement;
  String? cropType;
  // Field Information
  String? mulchingUsed;
  String? soilType;
  String? previousCrop;

  void updateLocation({String? lat, String? lng, String? addr}) {
    latitude = lat;
    longitude = lng;
    address = addr;
    notifyListeners();
  }

  void reset() {
    latitude = null;
    longitude = null;
    address = null;
    area = null;
    farmId = null;
    cropName = null;
    variety = null;
    plantingMethod = null;
    plantingDate = null;
    expectedHarvestDate = null;
    cropDuration = null;
    plantArrangement = null;
    cropType = null;
    mulchingUsed = null;
    soilType = null;
    previousCrop = null;
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'area': area,
      'farmId': farmId,
      'cropName': cropName,
      'variety': variety,
      'plantingMethod': plantingMethod,
      'plantingDate': plantingDate,
      'expectedHarvestDate': expectedHarvestDate,
      'cropDuration': cropDuration,
      'plantArrangement': plantArrangement,
      'cropType': cropType,
      'mulchingUsed': mulchingUsed,
      'soilType': soilType,
      'previousCrop': previousCrop,
    };
  }

  void fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
    address = json['address'];
    area = json['area'];
    farmId = json['farmId'];
    cropName = json['cropName'];
    variety = json['variety'];
    plantingMethod = json['plantingMethod'];
    plantingDate = json['plantingDate'];
    expectedHarvestDate = json['expectedHarvestDate'];
    cropDuration = json['cropDuration'];
    plantArrangement = json['plantArrangement'];
    cropType = json['cropType'];
    mulchingUsed = json['mulchingUsed'];
    soilType = json['soilType'];
    previousCrop = json['previousCrop'];
    notifyListeners();
  }
}
