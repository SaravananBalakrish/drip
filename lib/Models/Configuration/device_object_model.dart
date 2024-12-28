
import 'package:flutter/foundation.dart';

class DeviceObjectModel with DiagnosticableTreeMixin {
  final int objectId;
  int? sNo;
  String? name;
  String objectName;
  List<int>? location;
  final String type;
  String? deviceId;
  String? count;

  DeviceObjectModel({
    required this.objectId,
    this.sNo,
    this.name,
    required this.objectName,
    this.location,
    required this.type,
    this.deviceId,
    this.count,
  });

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('objectId', objectId));
    properties.add(IntProperty('sNo', sNo));
    properties.add(StringProperty('name', name));
    properties.add(StringProperty('objectName', objectName));
    properties.add(IterableProperty<int>('location', location));
    properties.add(StringProperty('type', type));
    properties.add(StringProperty('deviceId', deviceId));
    properties.add(StringProperty('count', count));
  }

  factory DeviceObjectModel.fromJson(data){
    return DeviceObjectModel(
        objectId : data['objectId'],
        sNo : data['sNo'],
        name : data['name'],
        objectName : data['objectName'],
        location : data['location'],
        type : data['type'],
        deviceId : data['deviceId'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'objectId' : objectId,
      'sNo' : sNo,
      'name' : name,
      'objectName' : objectName,
      'location' : location,
      'type' : type,
      'deviceId' : deviceId,
    };
  }
}


