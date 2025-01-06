import 'device_object_model.dart';

class FertilizationModel{
  DeviceObjectModel commonDetails;
  List<double> channel;
  List<double> boosterPump;
  List<double> agitator;
  List<double> selector;
  List<double> ec;
  List<double> ph;

  FertilizationModel({
    required this.commonDetails,
    required this.channel,
    required this.boosterPump,
    required this.agitator,
    required this.selector,
    required this.ec,
    required this.ph,
  });

  factory FertilizationModel.fromJson(data){
    DeviceObjectModel deviceObjectModel = DeviceObjectModel.fromJson(data);
    print('from json in fertilization');
    return FertilizationModel(
        commonDetails: deviceObjectModel,
        channel: (data['channel'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        boosterPump: (data['boosterPump'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        agitator: (data['agitator'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        selector: (data['selector'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        ec: (data['ec'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        ph: (data['ph'] as List<dynamic>).map((sNo) => sNo as double).toList(),
    );
  }

  Map<String, dynamic> toJson(){
    var commonInfo = commonDetails.toJson();
    commonInfo.addAll({
      'channel' : channel,
      'boosterPump' : boosterPump,
      'agitator' : agitator,
      'selector' : selector,
      'ec' : ec,
      'ph' : ph,
    });
    return commonInfo;
  }
}