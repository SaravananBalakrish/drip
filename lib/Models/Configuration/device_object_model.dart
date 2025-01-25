
import 'package:flutter/foundation.dart';

class DeviceObjectModel with DiagnosticableTreeMixin {
  final int objectId;
  double? sNo;
  String? name;
  String objectName;
  int? connectionNo;
  List<int>? location;
  final String type;
  int? controllerId;
  String? count;

  DeviceObjectModel({
    required this.objectId,
    this.sNo,
    this.name,
    this.connectionNo,
    required this.objectName,
    this.location,
    required this.type,
    this.controllerId,
    this.count,
  });

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('objectId', objectId));
    // properties.add(IntProperty('sNo', sNo));
    properties.add(StringProperty('name', name));
    properties.add(StringProperty('objectName', objectName));
    properties.add(IterableProperty<int>('location', location));
    properties.add(StringProperty('type', type));
    // properties.add(StringProperty('deviceId', deviceId));
    properties.add(StringProperty('count', count));
  }

  factory DeviceObjectModel.fromJson(data){
    return DeviceObjectModel(
        objectId : data['objectId'],
        sNo : data['sNo'],
        name : data['name'],
        connectionNo : data['connectionNo'] ?? 0,
        objectName : data['objectName'],
        location : data['location'] != null ? (data['location'] as List<dynamic>).map((sNo) => sNo as int).toList() : [],
        type : data['type'],
        controllerId : data['controllerId'],
        count: data['count']
    );
  }

  dynamic toJson(){
    return {
      'objectId' : objectId,
      'sNo' : sNo,
      'name' : name,
      'connectionNo' : connectionNo,
      'objectName' : objectName,
      'location' : location,
      'type' : type,
      'controllerId' : controllerId,
      'count' : count
    };
  }
}


