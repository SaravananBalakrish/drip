import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Constants/constants.dart';
import 'package:oro_drip_irrigation/Models/Configuration/device_object_model.dart';
import 'package:oro_drip_irrigation/StateManagement/config_maker_provider.dart';
import 'package:provider/provider.dart';

import '../../Models/Configuration/device_model.dart';

class PayloadProcessing extends StatefulWidget {
  const PayloadProcessing({super.key});

  @override
  State<PayloadProcessing> createState() => _PayloadProcessingState();
}

class _PayloadProcessingState extends State<PayloadProcessing> {
  late Future<List<DeviceModel>> listOfDevices;

  @override
  void initState() {
    super.initState();
    listOfDevices = context.read<ConfigMakerProvider>().fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Payload Processing'),
            ElevatedButton(
              onPressed: () async {
                final Map<String, dynamic> deviceListPayload = {
                  "100": [
                    {"101": getDeviceListPayload()}
                  ]
                };
                final Map<String, dynamic> configMakerPayload = {
                  "200": [
                    {"201": getPumpPayload()},
                    {"202": getIrrigationLinePayload()},
                    {"203": getFertilizerPayload()},
                    {"204": getFilterPayload()},
                    {"205": getWeatherPayload()},
                    {"206": getObjectPayload()},
                    {"207": 0},
                    {"208": '1'}
                  ]
                };

                /*print("getIrrigationLinePayload ==> ${jsonEncode(configMakerPayload)}");
                print("deviceListPayload ==> ${jsonEncode(deviceListPayload)}");*/
                print("getOroPumpPayload ==> ${getOroPumpPayload()}");
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  String getPumpPayload() {
    final configPvd = context.read<ConfigMakerProvider>();
    List<String> pumpPayload = [];

    for (var i = 0; i < configPvd.pump.length; i++) {
      var pump = configPvd.pump[i];
      var actualPump = configPvd.listOfGeneratedObject.firstWhere((object) => object.sNo == pump.commonDetails.sNo);
      var controller = configPvd.listOfDeviceModel.firstWhere((e) => e.controllerId == actualPump.controllerId);
      var relatedSources = configPvd.source.where((e) => e.inletPump.contains(pump.commonDetails.sNo) || e.outletPump.contains(pump.commonDetails.sNo)).toList();
      var sump = configPvd.source.where((e) => ![1, 4].contains(e.sourceType));
      var tank = configPvd.source.where((e) => e.sourceType == 1);
      var irrigationLine = configPvd.line.where((line) => (pump.pumpType == 1 ? line.sourcePump : line.irrigationPump).contains(pump.commonDetails.sNo)).toList();

      Map<String, dynamic> payload = {
        "S_No": pump.commonDetails.sNo,
        "PumpCategory": pump.pumpType,
        "PumpNumber": i + 1,
        "WaterMeterAvailable": pump.waterMeter == 0.0 ? 0 : 1,
        "OroPumpPlus": (controller.categoryId == 2 && controller.modelId == 5) ? 1 : 0,
        "OroPump": (controller.categoryId == 2 && controller.modelId == 4) ? 1 : 0,
        "RelayCount": pump.commonDetails.connectionNo == 0.0 ? '' : pump.commonDetails.connectionNo,
        "LevelType": relatedSources.any((level) => level.level != 0.0) ? 1 : 0,
        "PressureSensorAvailable": pump.pressure == 0.0 ? 0 : 1,
        "TopTankHighAvailable": sump.any((src) => src.topFloat != 0.0) ? 1 : 0,
        "TopTankLowAvailable": sump.any((src) => src.bottomFloat != 0.0) ? 1 : 0,
        "SumpTankHighAvailable": tank.any((src) => src.topFloat != 0.0) ? 1 : 0,
        "SumpTankLowAvailable": tank.any((src) => src.bottomFloat != 0.0) ? 1 : 0,
        "IrrigationLine": irrigationLine.map((line) => line.commonDetails.sNo).join('_'),
        "WaterMeter": pump.waterMeter == 0.0 ? '' : pump.waterMeter,
        "Level": relatedSources.map((src) => src.level).join('_'),
        "PressureSensor": pump.pressure == 0.0 ? '' : pump.pressure,
        "TopTankHigh": sump.map((src) => src.topFloat).join('_'),
        "TopTankLow": sump.map((src) => src.bottomFloat).join('_'),
        "SumpTankHigh": tank.map((src) => src.topFloat).join('_'),
        "SumpTankLow": tank.map((src) => src.bottomFloat).join('_'),
        "LevelControlOnOff": 0
      };

      pumpPayload.add(payload.entries.map((e) => e.value).join(","));
    }

    return pumpPayload.join(";");
  }

  String getDeviceListPayload() {
    final configPvd = context.read<ConfigMakerProvider>();
    List<dynamic> devicePayload = [];

    for (var i = 0; i < configPvd.listOfDeviceModel.length; i++) {
      var device = configPvd.listOfDeviceModel[i];
      if (device.masterId != null) {
        devicePayload.add({
          "S_No": device.serialNumber,
          "DeviceTypeNumber": device.categoryId,
          "DeviceRunningNumber": i + 1,
          "DeviceId": device.deviceId,
          "InterfaceType": device.interfaceTypeId,
          "ExtendNode": device.extendDeviceId,
        }.entries.map((e) => e.value).join(","));
      }
    }

    return devicePayload.join(";");
  }

  String getFilterPayload() {
    final configPvd = context.read<ConfigMakerProvider>();
    List<dynamic> filterPayload = [];
    var centralFiltration = configPvd.filtration.where((filtration) => filtration.siteMode == 1).toList();
    var localFiltration = configPvd.filtration.where((filtration) => filtration.siteMode == 2).toList();
    for(var filtration in [centralFiltration, localFiltration]){
      for(var i = 0;i < filtration.length;i++){
        var filter = filtration[i];
        filterPayload.add({
          "S_No": filter.commonDetails.sNo,
          "FilterSiteNumber": "${filter.siteMode}.${i + 1}",
          "FilterCount": filter.filters.length,
          "DownstreamValve": filter.backWashValve,
          "PressureIn": filter.pressureIn,
          "PressureOut": filter.pressureOut,
          "PressureSwitch": 0,
          "DifferentialPressureSensor": 0,
          "IrrigationLine": configPvd.line.where((line) => line.source.contains(filter.commonDetails.sNo)).map((line) => line.commonDetails.sNo).join('_'),
        }.entries.map((e) => e.value).join(","));
      }
    }



    return filterPayload.join(";");
  }

  String getFertilizerPayload() {
    final configPvd = context.read<ConfigMakerProvider>();

    List<dynamic> fertilizerPayload = [];
    var centralFiltration = configPvd.fertilization.where((filtration) => filtration.siteMode == 1).toList();
    var localFiltration = configPvd.fertilization.where((filtration) => filtration.siteMode == 2).toList();
    for(var fertilization in [centralFiltration, localFiltration]){
      for(var i = 0;i < fertilization.length;i++){
        var fertilizer = fertilization[i];
        var selectedBoosterPumps = configPvd.fertilization.where((e) => e.boosterPump.contains(fertilizer.commonDetails.sNo)).map((boosterPump) => boosterPump.commonDetails.sNo).toList().join('_');
        // var relatedSources = configPvd.source.where((e) => e.inletPump.contains(fertilizer.commonDetails.sNo)).toList();
        var irrigationLine = configPvd.line.where((line) => (fertilizer.siteMode == 1 ? line.centralFertilization : line.localFertilization) == fertilizer.commonDetails.sNo).toList().join('_');
        fertilizerPayload.add({
          "S_No": fertilizer.commonDetails.sNo,
          "FertilizerSiteNumber": "${fertilizer.siteMode}.${i + 1}",
          "BoosterCount": fertilizer.boosterPump.length,
          "EcSensorCount": fertilizer.ec.length,
          "PhSensorCount": fertilizer.ph.length,
          "PressureSwitch": 0,
          "FertilizerChannel": 0,
          "FertilizationMeter": 0,
          "LevelSensor": 0,
          "InjectorType": 1,
          "BoosterSelection": selectedBoosterPumps,
          "IrrigationLine": irrigationLine,
          "Agitator": fertilizer.agitator.join('_'),
        }.entries.map((e) => e.value).join(","));
      }
    }



    return fertilizerPayload.join(";");
  }

  String getObjectPayload() {
    final configPvd = context.read<ConfigMakerProvider>();
    List<dynamic> objectPayload = [];

    for (var i = 0; i < configPvd.listOfGeneratedObject.length; i++) {
      var object = configPvd.listOfGeneratedObject[i];
      if(object.connectionNo != 0){
        var controller = configPvd.listOfDeviceModel.firstWhere((e) => e.controllerId == object.controllerId);
        objectPayload.add({
          "S_No": object.sNo,
          "Name": '',
          "DeviceTypeNumber": controller.categoryId,
          "DeviceRunningNumber": 0,
          "Output_InputNumber": object.connectionNo,
          "IO_Mode": getObjectTypeCodeToHardware(object.type),
        }.entries.map((e) => e.value).join(","));
      }
    }

    return objectPayload.join(";");
  }

  String getWeatherPayload() {
    final configPvd = context.read<ConfigMakerProvider>();
    List<dynamic> weatherPayload = [];

    final weatherControllersList = configPvd.listOfDeviceModel.where((e) => e.categoryId == 4).toList();
    for (var i = 0; i < weatherControllersList.length; i++) {
      var weather = weatherControllersList[i];
      // var irrigationLine = configPvd.line.map((line) => weather.serialNumber).contains(pump.commonDetails.sNo)).toList();
      var soilMoistureSensor = configPvd.listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 25).toList();
      var soilTemperatureSensor = configPvd.listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 30).toList();
      var humiditySensor = configPvd.listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 36).toList();
      var temperatureSensor = configPvd.listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 29).toList();
      var atmosphericSensor = configPvd.listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 39).toList();
      var co2Sensor = configPvd.listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 33).toList();
      var ldrSensor = configPvd.listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 35).toList();
      var luxSensor = configPvd.listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 34).toList();
      var windDirectionSensor = configPvd.listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 31).toList();
      var windSpeedSensor = configPvd.listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 32).toList();
      var rainFallSensor = configPvd.listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 38).toList();
      var leafWetnessSensor = configPvd.listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 37).toList();
      if (weather.masterId != null) {
        weatherPayload.add(weatherSensorPayload(weather, soilMoistureSensor.isNotEmpty ? soilMoistureSensor[0] : null, 1));
        weatherPayload.add(weatherSensorPayload(weather, soilMoistureSensor.length > 1 ? soilMoistureSensor[1] : null, 2));
        weatherPayload.add(weatherSensorPayload(weather, soilMoistureSensor.length > 2 ? soilMoistureSensor[2] : null, 3));
        weatherPayload.add(weatherSensorPayload(weather, soilMoistureSensor.length > 3 ? soilMoistureSensor[3] : null, 4));
        weatherPayload.add(weatherSensorPayload(weather, soilTemperatureSensor.isNotEmpty ? soilTemperatureSensor[0] : null, 5));
        weatherPayload.add(weatherSensorPayload(weather, humiditySensor.isNotEmpty ? humiditySensor[0] : null, 6));
        weatherPayload.add(weatherSensorPayload(weather, temperatureSensor.isNotEmpty ? temperatureSensor[0] : null, 7));
        weatherPayload.add(weatherSensorPayload(weather, atmosphericSensor.isNotEmpty ? atmosphericSensor[0] : null, 8));
        weatherPayload.add(weatherSensorPayload(weather, co2Sensor.isNotEmpty ? co2Sensor[0] : null, 9));
        weatherPayload.add(weatherSensorPayload(weather, ldrSensor.isNotEmpty ? ldrSensor[0] : null, 10));
        weatherPayload.add(weatherSensorPayload(weather, luxSensor.isNotEmpty ? luxSensor[0] : null, 11));
        weatherPayload.add(weatherSensorPayload(weather, windDirectionSensor.isNotEmpty ? windDirectionSensor[0] : null, 12));
        weatherPayload.add(weatherSensorPayload(weather, windSpeedSensor.isNotEmpty ? windSpeedSensor[0] : null, 13));
        weatherPayload.add(weatherSensorPayload(weather, rainFallSensor.isNotEmpty ? rainFallSensor[0] : null, 14));
        weatherPayload.add(weatherSensorPayload(weather, leafWetnessSensor.isNotEmpty ? leafWetnessSensor[0] : null, 15));
      }
    }

    return weatherPayload.join(";");
  }

  String weatherSensorPayload(DeviceModel weather, DeviceObjectModel? sensor, int sensorId){
    return {
      "S_No": sensor != null ? sensor.sNo : '',
      "OroWeatherRunningNumber": 0,
      "Sensor": sensorId,
      "Enable": sensor != null ? 1 : 0,
      "IrrigationLine": 2.001,
    }.entries.map((e) => e.value).join(", ");
  }

  String getIrrigationLinePayload() {
    final configPvd = context.read<ConfigMakerProvider>();
    List<String> irrigationLinePayload = [];

    for (var i = 0; i < configPvd.line.length; i++) {
      var line = configPvd.line[i];
      irrigationLinePayload.add({
        "S_No": line.commonDetails.sNo,
        "Name": '',
        "ValveCount": line.valve.toList().join('_'),
        "MainValveCount": line.mainValve.toList().join('_'),
        "MoistureSensorCount": line.moisture.toList().join('_'),
        "LevelSensorCount": '',
        "FoggerCount": line.fogger.toList().join('_'),
        "FanCount": line.fan.toList().join('_'),
        "CentralFertSiteNumber": line.centralFertilization != 0.0 ? line.centralFertilization : '',
        "CentralFilterSiteNumber": line.centralFiltration != 0.0 ? line.centralFiltration : '',
        "LocalFertSite": line.localFertilization != 0.0 ? line.localFertilization : '',
        "LocalFilterSite": line.localFiltration != 0.0 ? line.localFiltration : '',
        "PressureIn": line.pressureIn != 0.0 ? line.pressureIn : '',
        "PressureOut":line.pressureOut != 0.0 ? line.pressureOut : '',
        "IrrigationPump": line.irrigationPump.toList().join('_'),
        "WaterMeter": line.waterMeter != 0.0 ? line.waterMeter : '',
        "NoPowerSupplyInput": line.powerSupply != 0.0 ? line.powerSupply : '',
        "PressureSwitch": line.pressureSwitch != 0.0 ? line.pressureSwitch : '',
        "LevelSensor": '',
        "Agitator": ''
      }.entries.map((e) => e.value).toList().join('_'));
    }

    return irrigationLinePayload.join(";");
  }

  int getObjectTypeCodeToHardware(String code) {
    switch(code) {
      case '1,2':
        return 1;
      case '3':
        return 2;
      case '4':
        return 3;
      case '5':
        return 7;
      case '6':
        return 4;
      case '7':
        return 6;
      default:
        return 1;
    }
  }

  String getOroPumpPayload() {
    final configPvd = context.read<ConfigMakerProvider>();
    List<dynamic> oroPumpPayload = [];

    final oroPumpControllersList = configPvd.listOfDeviceModel.where((e) => e.categoryId == 2 && e.modelId == 1).toList();
    for(var i = 0; i < configPvd.pump.length; i++) {
      var pump = configPvd.pump[i];
      var actualPump = configPvd.listOfGeneratedObject.firstWhere((object) => object.sNo == pump.commonDetails.sNo);
      var controller = configPvd.listOfDeviceModel.firstWhere((e) => e.controllerId == actualPump.controllerId);
      var relatedSources = configPvd.source.where((e) => e.inletPump.contains(pump.commonDetails.sNo) || e.outletPump.contains(pump.commonDetails.sNo)).toList();
      var sump = configPvd.source.where((e) => ![1, 4].contains(e.sourceType));
      var tank = configPvd.source.where((e) => e.sourceType == 1);
    }
    print(oroPumpControllersList.map((e) => e.toJson()));
    return '';
  }
}
