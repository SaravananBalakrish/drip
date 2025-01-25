import 'package:oro_drip_irrigation/Models/Configuration/device_object_model.dart';

class WeatherModel{
  DeviceObjectModel moisture1;
  bool moisture2;
  bool moisture3;
  bool moisture4;
  bool soilTemperature;
  bool humidity;
  bool temperature;
  bool atmosphericPressure;
  bool co2;
  bool ldr;
  bool lux;
  bool windDirection;
  bool windSpeed;
  bool rainFall;
  bool leafWetness;

  WeatherModel({
    required this.moisture1,
    required this.moisture2,
    required this.moisture3,
    required this.moisture4,
    required this.soilTemperature,
    required this.humidity,
    required this.temperature,
    required this.atmosphericPressure,
    required this.co2,
    required this.ldr,
    required this.lux,
    required this.windDirection,
    required this.windSpeed,
    required this.rainFall,
    required this.leafWetness,
  });

  factory WeatherModel.fromJson(data){
    return WeatherModel(
        moisture1: data['moisture1'],
        moisture2: data['moisture2'],
        moisture3: data['moisture3'],
        moisture4: data['moisture4'],
        soilTemperature: data['soilTemperature'],
        humidity: data['humidity'],
        temperature: data['temperature'],
        atmosphericPressure: data['atmosphericPressure'],
        co2: data['co2'],
        ldr: data['ldr'],
        lux: data['lux'],
        windDirection: data['windDirection'],
        windSpeed: data['windSpeed'],
        rainFall: data['rainFall'],
        leafWetness: data['leafWetness']
    );
  }

  dynamic toJson(){
    return {
      'moisture1' : moisture1,
      'moisture2' : moisture2,
      'moisture3' : moisture3,
      'moisture4' : moisture4,
      'soilTemperature' : soilTemperature,
      'humidity' : humidity,
      'temperature' : temperature,
      'atmosphericPressure' : atmosphericPressure,
      'co2' : co2,
      'ldr' : ldr,
      'lux' : lux,
      'windDirection' : windDirection,
      'windSpeed' : windSpeed,
      'rainFall' : rainFall,
      'leafWetness' : leafWetness,
    };
  }

}