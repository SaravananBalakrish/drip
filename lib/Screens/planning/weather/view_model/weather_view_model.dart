import 'dart:convert';
import 'package:flutter/cupertino.dart';

import '../../../../repository/repository.dart';
import '../model/weather_model.dart';

class WeatherViewModel extends ChangeNotifier {
  final Repository repository;

  WeatherModelNew? weatherModel;

  /// irrigation → stations → sensors tree
  List<IrrigationLineExpanded> irrigationTree = [];

  bool isLoadingWeather = false;
  int? selectedSerialNumber;

  /// parsed live cache (serial → sensor list)
  Map<int, List<LiveSensorValue>> liveCache = {};

  /// fast config lookup
  Map<String, ConfigObjectNew> configIndex = {};

  WeatherViewModel(this.repository);

  Future<void> fetchWeatherData(int userId, int controllerId) async {
    print("Call fetchWeatherData call ");
     isLoadingWeather = true;
    notifyListeners();

    try {
      final body = {
        "userId": userId,
        "controllerId": controllerId,
      };

      final response = await repository.getweather(body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('data:$data');

        if (data["code"] == 200) {


          weatherModel = WeatherModelNew.fromJson(data["data"]);

           liveCache = weatherModel!.parseLive5101();

           _buildConfigIndex();

           irrigationTree = weatherModel!.buildIrrigationLineTree();

           if (weatherModel!.deviceList.isNotEmpty) {
            selectedSerialNumber =
                weatherModel!.deviceList.first.serialNumber;
          }
        }
      }
    } catch (e, st) {
      debugPrint("Weather error: $e\n$st");
    }

    isLoadingWeather = false;
    notifyListeners();
  }


  Future<void> fetchWeatherDataGsm(int userId, int controllerId,Map<String,dynamic> data) async {
    print("call fetchWeatherDataGsm");
      isLoadingWeather = true;
    notifyListeners();

    try {
          print('data:$data');
          weatherModel = WeatherModelNew.fromJson(data["data"]);
           liveCache = weatherModel!.parseLive5101();
           _buildConfigIndex();
           irrigationTree = weatherModel!.buildIrrigationLineTree();
           if (weatherModel!.deviceList.isNotEmpty) {
            selectedSerialNumber =
                weatherModel!.deviceList.first.serialNumber;
        }

    } catch (e, st) {
      debugPrint("Weather error: $e\n$st");
    }
    isLoadingWeather = false;
    notifyListeners();
  }


  void _buildConfigIndex() {
    if (weatherModel == null) return;

    configIndex = {
      for (final c in weatherModel!.configObject)
        "${c.controllerId}_${c.objectName}": c
    };
  }


  bool get hasAnyWeatherStation {
    if (weatherModel == null) return false;

    return weatherModel!.deviceList.any(
          (d) => d.deviceName.toLowerCase().contains('weather'),
    );
  }


  WeatherDeviceList? get selectedDevice {
    if (weatherModel == null || selectedSerialNumber == null) return null;

    return weatherModel!.deviceList.firstWhere(
          (d) => d.serialNumber == selectedSerialNumber,
      orElse: () => weatherModel!.deviceList.first,
    );
  }

  void selectDevice(int serial) {
    selectedSerialNumber = serial;
    notifyListeners();
  }


  LiveSensorValue? getSensorLiveByName({
    required String objectName,
    required int controllerId,
  }) {
    if (selectedSerialNumber == null) return null;

    final config = configIndex["${controllerId}_$objectName"];
    if (config == null) return null;

    final list = liveCache[selectedSerialNumber!];
    if (list == null) return null;

    return list.firstWhere(
          (e) => e.sNo.toInt() == config.sNo.toInt(),
      orElse: () => LiveSensorValue(
        sNo: 0,
        value: 0,
        status: -1,
        min: 0,
        max: 0,
        avg: 0,
      ),
    );
  }

  /// helper → get formatted value string
  String getSensorValueText({
    required String objectName,
    required int controllerId,
  }) {
    final s = getSensorLiveByName(
      objectName: objectName,
      controllerId: controllerId,
    );

    if (s == null || s.status == -1) return "No Data";

    return s.value.toStringAsFixed(1);
  }

  LiveSensorValue? getSensorLiveBySerial({
    required int serial,
    required String objectName,
    required int controllerId,
    double? objectSno,
  })
  {
     final config = configIndex["${controllerId}_$objectName"];
    if (config == null) return null;

    final list = liveCache[serial];
    if (list == null) return null;

    return list.firstWhere(
          (e) {
         if (objectSno != null) {
          return e.sNo == objectSno;
        } else {
          return e.sNo == config.sNo;
        }
      },
      orElse: () => LiveSensorValue(
        sNo: 0,
        value: 0,
        status: -1,
        min: 0,
        max: 0,
        avg: 0,
      ),
    );
  }

}