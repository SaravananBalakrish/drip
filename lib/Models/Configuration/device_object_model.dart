
class DeviceObjectModel {
  final int objectId;
  double? sNo;
  String? name;
  String objectName;
  int? connectionNo;
  List<int>? location;
  final String type;
  String? deviceId;
  String? count;

  DeviceObjectModel({
    required this.objectId,
    this.sNo,
    this.name,
    this.connectionNo,
    required this.objectName,
    this.location,
    required this.type,
    this.deviceId,
    this.count,
});

  factory DeviceObjectModel.fromJson(data){
    return DeviceObjectModel(
        objectId : data['objectId'],
        sNo : data['sNo'],
        name : data['name'],
        connectionNo : data['connectionNo'] ?? 0,
        objectName : data['objectName'],
        location : data['location'] != null ? (data['location'] as List<dynamic>).map((sNo) => sNo as int).toList() : [],
        type : data['type'],
        deviceId : data['deviceId'] ?? '',
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
      'deviceId' : deviceId,
      'count' : count
    };
  }
}


