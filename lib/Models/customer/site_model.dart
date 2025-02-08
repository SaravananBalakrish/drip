class SiteModel {
  final List<Group> data;

  SiteModel({required this.data});

  factory SiteModel.fromJson(Map<String, dynamic> json) {
    return SiteModel(
      data: List<Group>.from(json['data'].map((x) => Group.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((x) => x.toJson()).toList(),
    };
  }
}

class Group {
  final int groupId;
  final String groupName;
  final List<Master> master;

  Group({required this.groupId, required this.groupName, required this.master});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      groupId: json['groupId'],
      groupName: json['groupName'],
      master: List<Master>.from(json['master'].map((x) => Master.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'master': master.map((x) => x.toJson()).toList(),
    };
  }
}

class Master {
  final int controllerId;
  final String deviceId;
  final String deviceName;
  final int categoryId;
  final String categoryName;
  final int modelId;
  final String modelName;
  final int conditionLibraryCount;
  final List<Unit> units;
  final Config config;
  final Live live;

  Master({
    required this.controllerId,
    required this.deviceId,
    required this.deviceName,
    required this.categoryId,
    required this.categoryName,
    required this.modelId,
    required this.modelName,
    required this.conditionLibraryCount,
    required this.units,
    required this.config,
    required this.live,
  });

  factory Master.fromJson(Map<String, dynamic> json) {
    return Master(
      controllerId: json['controllerId'],
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      modelId: json['modelId'],
      modelName: json['modelName'],
      conditionLibraryCount: json['conditionLibraryCount'],
      units: List<Unit>.from(json['units'].map((x) => Unit.fromJson(x))),
      config: Config.fromJson(json['config']),
      live: Live.fromJson(json['live']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'controllerId': controllerId,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'modelId': modelId,
      'modelName': modelName,
      'conditionLibraryCount': conditionLibraryCount,
      'units': units.map((x) => x.toJson()).toList(),
      'config': config,
      'live': live.toJson(),
    };
  }
}

class Unit {
  final int dealerDefinitionId;
  final String parameter;
  final String value;

  Unit({required this.dealerDefinitionId, required this.parameter, required this.value});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      dealerDefinitionId: json['dealerDefinitionId'],
      parameter: json['parameter'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dealerDefinitionId': dealerDefinitionId,
      'parameter': parameter,
      'value': value,
    };
  }
}

class Config {
  List<Site>? filterSite;
  List<Site>? fertilizerSite;
  List<WaterSource>? waterSource;
  List<Pump>? pump;
  List<MoistureSensor>? moistureSensor;
  List<IrrigationLineData>? lineData;

  Config({
    this.filterSite,
    this.fertilizerSite,
    this.waterSource,
    this.pump,
    this.moistureSensor,
    this.lineData,
  });

  factory Config.fromJson(Map<String, dynamic> json) => Config(
    filterSite: json["filterSite"] != null
        ? (json["filterSite"] as List).map((i) => Site.fromJson(i)).toList()
        : [],
    fertilizerSite: json["fertilizerSite"] != null
        ? (json["fertilizerSite"] as List).map((i) => Site.fromJson(i)).toList()
        : [],
    waterSource: json["waterSource"] != null
        ? (json["waterSource"] as List)
        .map((i) => WaterSource.fromJson(i))
        .toList()
        : [],
    pump: json["pump"] != null
        ? (json["pump"] as List).map((i) => Pump.fromJson(i)).toList()
        : [],
    moistureSensor: json["moistureSensor"] != null
        ? (json["moistureSensor"] as List)
        .map((i) => MoistureSensor.fromJson(i))
        .toList()
        : [],
    lineData: json["irrigationLine"] != null
        ? (json["irrigationLine"] as List)
        .map((i) => IrrigationLineData.fromJson(i))
        .toList()
        : [],
  );
}

class Site {
  int? objectId;
  double? sNo;
  String? name;
  int? siteMode;
  List<Item>? filters;
  Item? pressureIn;
  Item? pressureOut;
  List<Item>? channel;
  List<Item>? boosterPump;
  List<Item>? agitator;
  List<Item>? ec;
  List<Item>? ph;

  Site({
    this.objectId,
    this.sNo,
    this.name,
    this.siteMode,
    this.filters,
    this.pressureIn,
    this.pressureOut,
    this.channel,
    this.boosterPump,
    this.agitator,
    this.ec,
    this.ph,
  });

  factory Site.fromJson(Map<String, dynamic> json) => Site(
    objectId: json['objectId'],
    sNo: json['sNo'],
    name: json['name'],
    siteMode: json['siteMode'],
    filters: (json['filters'] as List?)?.map((i) => Item.fromJson(i)).toList(),
    pressureIn: json['pressureIn'] != null ? Item.fromJson(json['pressureIn']) : null,
    pressureOut: json['pressureOut'] != null ? Item.fromJson(json['pressureOut']) : null,
    channel: (json['channel'] as List?)?.map((i) => Item.fromJson(i)).toList(),
    boosterPump: (json['boosterPump'] as List?)?.map((i) => Item.fromJson(i)).toList(),
    agitator: (json['agitator'] as List?)?.map((i) => Item.fromJson(i)).toList(),
    ec: (json['ec'] as List?)?.map((i) => Item.fromJson(i)).toList(),
    ph: (json['ph'] as List?)?.map((i) => Item.fromJson(i)).toList(),
  );
}

class WaterSource {
  int? objectId;
  double? sNo;
  String? name;
  Level? level;
  List<Item>? inletPump;
  List<Item>? outletPump;
  List<Item>? valves;

  WaterSource({
    this.objectId,
    this.sNo,
    this.name,
    this.level,
    this.inletPump,
    this.outletPump,
    this.valves,
  });

  factory WaterSource.fromJson(Map<String, dynamic> json) => WaterSource(
    objectId: json['objectId'],
    sNo: json['sNo'],
    name: json['name'],
    level: (json['level'] != null && json['level'].isNotEmpty)
        ? Level.fromJson(json['level'])
        : null,
    inletPump: (json['inletPump'] as List?)?.map((i) => Item.fromJson(i)).toList(),
    outletPump: (json['outletPump'] as List?)?.map((i) => Item.fromJson(i)).toList(),
    valves: (json['valves'] as List?)?.map((i) => Item.fromJson(i)).toList(),
  );
}

class Level {
  int? objectId;
  double? sNo;
  String? name;
  String? percentage;
  String? connectionNo;
  String? controllerId;

  Level({
    this.objectId,
    this.sNo,
    this.name,
    this.percentage,
    this.connectionNo,
    this.controllerId,
  });

  factory Level.fromJson(Map<String, dynamic> json) => Level(
    objectId: json['objectId'],
    sNo: json['sNo'],
    name: json['name'],
    percentage: json['percentage'],
    connectionNo: json['connectionNo'],
    controllerId: json['controllerId'],
  );
}

class Pump {
  int? objectId;
  double? sNo;
  String? name;
  Item? waterMeter;
  Item? pumpType;

  Pump({this.objectId, this.sNo, this.name, this.waterMeter, this.pumpType});

  factory Pump.fromJson(Map<String, dynamic> json) => Pump(
    objectId: json['objectId'],
    sNo: json['sNo'],
    name: json['name'],
    waterMeter: (json['waterMeter'] != null && json['waterMeter'] is Map<String, dynamic> && json['waterMeter'].isNotEmpty)
        ? Item.fromJson(json['waterMeter'])
        : null,
    pumpType: (json['pumpType'] != null && json['pumpType'] is Map<String, dynamic> && json['pumpType'].isNotEmpty)
        ? Item.fromJson(json['pumpType'])
        : null,
  );
}

class MoistureSensor {
  int? objectId;
  double? sNo;
  String? name;
  List<Item>? valves;

  MoistureSensor({this.objectId, this.sNo, this.name, this.valves});

  factory MoistureSensor.fromJson(Map<String, dynamic> json) => MoistureSensor(
    objectId: json['objectId'],
    sNo: json['sNo'],
    name: json['name'],
    valves: (json['valves'] as List?)?.map((i) => Item.fromJson(i)).toList(),
  );
}

class IrrigationLineData {
  int? objectId;
  double? sNo;
  String? name;
  List<Item>? sourcePump;
  List<Item>? irrigationPump;
  //Item? centralFiltration;
  //Item? centralFertilization;
  List<Item>? valve;

  IrrigationLineData({
    this.objectId,
    this.sNo,
    this.name,
    this.sourcePump,
    this.irrigationPump,
    //this.centralFiltration,
    //this.centralFertilization,
    this.valve,
  });

  factory IrrigationLineData.fromJson(Map<String, dynamic> json) => IrrigationLineData(
    objectId: json['objectId'],
    sNo: json['sNo'],
    name: json['name'],
    sourcePump: (json['sourcePump'] as List?)?.map((i) => Item.fromJson(i)).toList(),
    irrigationPump: (json['irrigationPump'] as List?)?.map((i) => Item.fromJson(i)).toList(),
    //centralFiltration: json['centralFiltration'] != null ? Item.fromJson(json['centralFiltration']) : null,
    //centralFertilization: json['centralFertilization'] != null ? Item.fromJson(json['centralFertilization']) : null,
    valve: (json['valve'] as List?)?.map((i) => Item.fromJson(i)).toList(),
  );
}

class Item {
  int? objectId;
  double? sNo;
  String? name;
  int status;

  Item({this.objectId, this.sNo, this.name, this.status = 0});

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    objectId: json['objectId'],
    sNo: json['sNo'],
    name: json['name'],
  );

  Map<String, dynamic> toJson() => {
    "objectId": objectId,
    "sNo": sNo,
    "name": name,
    "status": status,
  };
}


class Live {
  final String cC;
  final String cD;
  final String cT;

  Live({required this.cC, required this.cD, required this.cT});

  factory Live.fromJson(Map<String, dynamic> json) {
    return Live(
      cC: json['cC'],
      cD: json['cD'],
      cT: json['cT'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cC': cC,
      'cD': cD,
      'cT': cT,
    };
  }
}