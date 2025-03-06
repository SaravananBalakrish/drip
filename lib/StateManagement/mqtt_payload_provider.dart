import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Constants/data_convertion.dart';
import '../Models/customer/site_model.dart';


enum MQTTConnectionState { connected, disconnected, connecting }

class MqttPayloadProvider with ChangeNotifier {
  MQTTConnectionState _appConnectionState = MQTTConnectionState.disconnected;
  // SiteModel dashboardLiveInstance = SiteModel(data: data);
  SiteModel? _dashboardLiveInstance;
  SiteModel? get dashboardLiveInstance => _dashboardLiveInstance;
  dynamic spa = '';
  String dashBoardPayload = '', schedulePayload = '';

  Map<String, dynamic> pumpControllerPayload = {};
  Map<String, dynamic> preferencePayload = {};
  List viewSettingsList = [];
  // bool isCommunicatable = false;
  // bool isWaiting = false;
  int dataFetchingStatus = 2;
  List<dynamic> unitList = [];

  //Todo : Dashboard start
  int tryingToGetPayload = 0;
  dynamic wifiStrength = '';
  String version = '';
  int powerSupply = 0;
  dynamic listOfSite = [];
  dynamic listOfSharedUser = {};
  bool httpError = false;
  String selectedSiteString = '';
  int selectedSite = 0;
  int selectedMaster = 0;
  int selectedLine = 0;
  List<dynamic> nodeDetails = [];
  dynamic messageFromHw;
  List<dynamic> currentSchedule = [];
  List<dynamic> PrsIn = [];
  List<dynamic> PrsOut = [];
  List<dynamic> nextSchedule = [];
  List<dynamic> upcomingProgram = [];
  // List<Filters> filtersCentral = [];
  // List<Filters> filtersLocal = [];
  // List<Pump> irrigationPump = [];
  // List<Pump> sourcePump = [];
  // List<WaterSource> sourcetype = [];
  // List<FertilizerSite> fertilizerCentral = [];
  // List<FertilizerSite> fertilizersdashboard = [];
  // List<FertilizerSite> fertilizerLocal = [];

  List<WaterSource> waterSourceMobDash = [];
  List<FilterSite> filterSiteMobDash = [];
  List<FertilizerSite> fertilizerSiteMobDash = [];
  List<IrrigationLineData>? irrLineDataMobDash = [];
  List<dynamic> flowMeter = [];
  List<dynamic> alarmList = [];
  List<dynamic> waterMeter = [];
  List<dynamic> sensorInLines = [];
  List<dynamic> lineData = [];
  String subscribeTopic = '';
  String publishTopic = '';
  String publishMessage= '';
  bool loading = false;
  int active = 1;
  Timer? timerForIrrigationPump;
  List<dynamic> sensorLogData = [];
  Timer? timerForSourcePump;
  Timer? timerForCentralFiltration;
  Timer? timerForLocalFiltration;
  Timer? timerForCentralFertigation;
  Timer? timerForLocalFertigation;
  Timer? timerForCurrentSchedule;
  int selectedCurrentSchedule = 0;
  int selectedNextSchedule = 0;
  int selectedProgram = 0;
  DateTime lastUpdate = DateTime.now();
  String sheduleLog = '';
  String uardLog = '';
  String uard0Log = '';
  String uard4Log = '';
  List<dynamic> userPermission = [];
  List<dynamic> units = [];


  void editSensorLogData(data){
    sensorLogData = data;
    notifyListeners();
  }

  void editLoading(bool value){
    loading = value;
    notifyListeners();
  }

  void editPublishMessage(String message){
    publishMessage = message;
    notifyListeners();
  }

  void editSubscribeTopic(String topic){
    subscribeTopic = topic;
    notifyListeners();
  }

  void editPublishTopic(String topic){
    publishTopic = topic;
    notifyListeners();
  }

  void editLineData(dynamic data){
    // // print('editLineData : ${data}');
    lineData = [];
    for(var i in data){
      lineData.add(i);
    }
    lineData.insert(0,{'id' : 'All','location' : '','mode' : 0,'name' : 'All line','mainValve' : [],'valve' : []});
    for(var i in lineData){
      i['mode'] = 0;
    }
    notifyListeners();
  }






  void clearData() {
    listOfSite = [];
    listOfSharedUser = {};
    currentSchedule = [];
    PrsIn = [];
    PrsOut = [];
    nextSchedule = [];
    selectedLine = 0;
    selectedSite = 0;
    selectedMaster = 0;
    upcomingProgram = [];
    // filtersCentral = [];
    // filtersLocal = [];
    // irrigationPump = [];
    // sourcePump = [];
    // fertilizerCentral = [];
    // fertilizerLocal = [];
    flowMeter = [];
    alarmList = [];
    waterMeter = [];
    sensorInLines = [];
    lineData = [];
    loading = false;
    active = 1;
    if(timerForIrrigationPump != null){
      timerForIrrigationPump!.cancel();
      timerForSourcePump!.cancel();
      timerForCentralFiltration!.cancel();
      timerForLocalFiltration!.cancel();
      timerForCentralFertigation!.cancel();
      timerForLocalFertigation!.cancel();
      timerForCurrentSchedule!.cancel();
    }

    selectedCurrentSchedule = 0;
    selectedNextSchedule = 0;
    selectedProgram = 0;
    // pumpControllerData = null;
    lastUpdate = DateTime.now();
    notifyListeners();
  }


  void updateReceivedPayload2(String payload,bool dataFromHttp) async{
    print('payload ::: $payload');

  }

  void updateReceivedPayload(String payload,bool dataFromHttp) async{
    if(!dataFromHttp) {
      dataFetchingStatus = 1;
    } else {
      dataFetchingStatus = 3;
    }
    try {
      // Todo : Dashboard payload start
      Map<String, dynamic> data = jsonDecode(payload);
      if(data['liveSyncDate'] != null){
        String dateStr = data['liveSyncDate'];
        String timeStr = data['liveSyncTime'];
        // Parse date string
        List<String> dateParts = dateStr.split("-");
        int year = int.parse(dateParts[0]);
        int month = int.parse(dateParts[1]);
        int day = int.parse(dateParts[2]);

        // Parse time string
        List<String> timeParts = timeStr.split(":");
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        int second = int.parse(timeParts[2]);
        lastUpdate = DateTime(year, month, day, hour, minute, second);
      }else if(data.containsKey('2400') && data['2400'].isNotEmpty){
        if(data['2400'][0].containsKey('SentTime') && data['2400'][0]['SentTime'].isNotEmpty){
          lastUpdate = DateTime.parse(data['2400'][0]['SentTime']);
        }
      }
      if(data.containsKey('4200')){
        //conformation message form gem or gem+ to every customer action
        messageFromHw = data['4200'][0]['4201'];
      }
      if(data.containsKey('cM')){
        messageFromHw = data;
      }
      if(data.containsKey('6600')){
        if(data['6600'].containsKey('6601')){
          if(!sheduleLog.contains(data['6600']['6601'])) {
            sheduleLog += "\n";
            sheduleLog += data['6600']['6601'];
          }
        }
        if(data['6600'].containsKey('6602')){
          if(!uardLog.contains(data['6600']['6602'])){
            uardLog += "\n";
            uardLog += data['6600']['6602'];
          }
        }
        if(data['6600'].containsKey('6603')){
          if(!uard0Log.contains(data['6600']['6603'])){
            uard0Log += "\n";
            uard0Log += data['6600']['6603'];
          }
        }
        if(data['6600'].containsKey('6604')){
          if(!uard4Log.contains(data['6600']['6604'])){
            uard4Log += "\n";
            uard4Log += data['6600']['6604'];
          }
        }
      }
      if (data.containsKey('2400') && data['2400'] != null && data['2400'].isNotEmpty) {
        dashBoardPayload = payload;
        if (data['2400'][0].containsKey('2401')) {
          nodeDetails = data['2400'][0]['2401'];
          for(var node in nodeDetails){
            if(dataFromHttp){
              for(var obj in node['RlyStatus']){
                obj['Status'] = 0;
              }
            }
          }
        }
        if(dataFromHttp){
          if(data.containsKey('userPermission')){
            userPermission = data['userPermission'];
          }
          if(data.containsKey('units')){
            units = data['units'];
          }
        }
        if(dataFromHttp == false){
          if (data['2400'][0].containsKey('2402')) {
            currentSchedule = data['2400'][0]['2402'];
            if(currentSchedule.length == 0){
              active = 1;
            }
            selectedCurrentSchedule = 0;
            if(currentSchedule.isNotEmpty && currentSchedule[0].containsKey('PrsIn')){
              PrsIn = currentSchedule[0]['PrsIn'];
              PrsOut = currentSchedule[0]['PrsOut'];
            }
          }
          if (data['2400'][0].containsKey('2403')) {
            nextSchedule = data['2400'][0]['2403'];
            selectedNextSchedule = 0;
            // // print('nextSchedule : $nextSchedule');
          }
        }
        if (data['2400'][0].containsKey('2404')) {
          upcomingProgram = data['2400'][0]['2404'];
          if(dataFromHttp){
            for(var program in upcomingProgram){
              program['ProgOnOff'] = 0;
              program['ProgPauseResume'] = 1;
            }
          }
          selectedProgram = 0;
          // // print('upcomingProgram : $upcomingProgram');
        }
        // if (data['2400'][0].containsKey('2405')) {
        //   List<dynamic> filtersJson = data['2400'][0]['2405'];
        //   filtersCentral = [];
        //   filtersLocal = [];
        //
        //   for (var filter in filtersJson) {
        //     if (filter['Type'] == 1) {
        //       filtersCentral.add(filter);
        //     } else if (filter['Type'] == 2) {
        //       filtersLocal.add(filter);
        //     }
        //   }
        // }
        //
        // if (data['2400'][0].containsKey('2406')) {
        //   List<dynamic> fertilizerJson = data['2400'][0]['2406'];
        //   fertilizerCentral = [];
        //   fertilizerLocal = [];
        //
        //   for (var fertilizer in fertilizerJson) {
        //     if (fertilizer['Type'] == 1) {
        //       for(var channel in fertilizer['Fertilizer']){
        //         channel['proportionalStatus'] = channel['Status'];
        //       }
        //       fertilizerCentral.add(fertilizer);
        //     } else if (fertilizer['Type'] == 2) {
        //       for(var channel in fertilizer['Fertilizer']){
        //         channel['proportionalStatus'] = channel['Status'];
        //       }
        //       fertilizerLocal.add(fertilizer);
        //     }
        //   }
        // }


        if (data['2400'][0].containsKey('2409')) {
          alarmList = data['2400'][0]['2409'];
          // // print('alarmList ==> $alarmList');
        }
        if (data['2400'][0].containsKey('WifiStrength')) {
          wifiStrength = data['2400'][0]['WifiStrength'];
        }
        if (data['2400'][0].containsKey('Version')) {
          version = data['2400'][0]['Version'];
        }

        if (data['2400'][0].containsKey('PowerSupply')) {
          powerSupply = data['2400'][0]['PowerSupply'];
        }
        if (data['2400'][0].containsKey('2410')) {
          waterMeter = data['2400'][0]['2410'];
        }
        // Todo : Dashboard pauload stop

        // if (data['2400'][0].containsKey('2401')) {
        //   final rawData = data['2400'][0]['2401'] as List;
        //   // print("rawData ==> $rawData");
        //
        //   if (dataFromHttp) {
        //     nodeData = rawData.map((item) => NodeModel.fromJson(item)).toList();
        //   } else {
        //     nodeData = nodeData.map((node) {
        //       var updatedData = rawData.firstWhere(
        //               (item) {
        //             return item['SNo'] == node.serialNumber;
        //           },
        //           orElse: () => {
        //             'Status': node.status,
        //             'RlyStatus': node.rlyStatus.map((r) => r.toJson()).toList()
        //           }
        //       );
        //       var updatedStatus = updatedData['Status'];
        //       var rawRlyStatus = updatedData['RlyStatus'] as List;
        //       List<RelayStatus> updatedRlyStatus = rawRlyStatus.map((r) => RelayStatus.fromJson(r)).toList();
        //       return node.updateStatusAndRlyStatus(updatedStatus, updatedRlyStatus);
        //     }).toList();
        //   }
        // }
      }
      else if(data.containsKey('3600') && data['3600'] != null && data['3600'].isNotEmpty){
        // mySchedule.dataFromMqttConversion(payload);
        schedulePayload = payload;
      }
      else if(data['mC'] != null && data['mC'].contains("SMS")) {
        preferencePayload = data;
      }
      else if(data['mC'] != null && data['mC'].contains("LD01")) {
        // pumpControllerData = PumpControllerData.fromJson(data, "cM");
        if(dataFetchingStatus == 1) {
          lastUpdate = DateTime.parse("${data['cD']} ${data['cT']}");
        }
        // print("pumpControllerData data from provider ==> ${pumpControllerData}");
      }
      else if(data['mC'] != null && data["mC"].contains("VIEW")) {
        if (!viewSettingsList.contains(jsonEncode(data['cM']))) {
          viewSettingsList.add(jsonEncode(data["cM"]));
          // print("viewSettingsList ==> $viewSettingsList");
        }
      }
      else if(data.containsKey('5100') && data['5100'] != null && data['5100'].isNotEmpty){
        // weatherModelinstance = WeatherModel.fromJson(data);
      }
    } catch (e, stackTrace) {
      print('Error parsing JSON: $e');
      print('Stacktrace while parsing json : $stackTrace');
    }
    // if(irrigationPump.isEmpty){
    //   loading = true;
    // }else{
    //   loading = false;
    // }
    tryingToGetPayload = 0;
    notifyListeners();



    // updateCurrentSchedule();
    notifyListeners();
  }

  //Todo : Dashboard stop

  // void editMySchedule(ScheduleViewProvider instance){
  //   mySchedule = instance;
  //   notifyListeners();
  // }
  //
  //
  // void updatehttpweather(Map<String, dynamic> payload) {
  //   weatherModelinstance = WeatherModel.fromJson(payload);
  //   notifyListeners();
  // }

  //assets/mob_dashboard/sump.svg

  Future<void> updateDashboardPayload(Map<String, dynamic> payload) async{




     _dashboardLiveInstance = SiteModel.fromJson(payload);

     waterSourceMobDash = _dashboardLiveInstance!.data[0].master[0].config.waterSource;
     filterSiteMobDash = _dashboardLiveInstance!.data[0].master[0].config.filterSite;
     fertilizerSiteMobDash = _dashboardLiveInstance!.data[0].master[0].config.fertilizerSite;
     irrLineDataMobDash = _dashboardLiveInstance!.data[0].master[0].config.lineData;

     // sourcePump = _dashboardLiveInstance!.data[0].master[0].config.pump.where((e) => e.type == 1).toList().map((element) => element).toList();
     // irrigationPump = _dashboardLiveInstance!.data[0].master[0].config.pump.where((e) => e.type == 2).toList().map((element) => element).toList();
     // sourcetype = _dashboardLiveInstance!.data[0].master[0].config.waterSource.map((element) => element).toList();
     // fertilizerCentral = _dashboardLiveInstance!.data[0].master[0].config.fertilizerSite.where((e) => e.siteMode == 1).toList().map((element) => element).toList();
     // fertilizerLocal = _dashboardLiveInstance!.data[0].master[0].config.fertilizerSite.where((e) => e.siteMode == 2).toList().map((element) => element).toList();
     // fertilizersdashboard = _dashboardLiveInstance!.data[0].master[0].config.fertilizerSite;
     // // filtersCentral = _dashboardLiveInstance!.data[0].master[0].config.filterSite.where((e) => e.siteMode == 1).toList().map((element) => element.filters.map((ele) => ele.toJson())).toList();
     // filtersCentral = _dashboardLiveInstance!.data[0].master[0].config.filterSite.where((e) => e.siteMode == 1).toList().expand((element) => element.filters.map((ele) => ele)).toList();
     // filtersLocal = _dashboardLiveInstance!.data[0].master[0].config.filterSite.where((e) => e.siteMode == 2).toList().expand((element) => element.filters.map((ele) => ele)).toList();

      // lineData = _dashboardLiveInstance!.data[0].master[0].config.lineData.map((element) => element).toList();
     //  print("filtersCentral :::: $filtersCentral");
     // filtersCentral.forEach((element) {
     //   print(element);
     // });
     notifyListeners();
  }

  Timer? _timerForPumpController;

  void updatePumpController(){
    if(_timerForPumpController != null){
      _timerForPumpController!.cancel();
    }
    _timerForPumpController = Timer.periodic(const Duration(seconds: 1), (Timer timer){
      // // print('seconds');
      // for(var i in pumpControllerData!.pumps){
      //   // // print('pumps => ${i}');
      //   if(i.status == 0){
      //     if(i.onDelayComplete != '00:00:00' && i.onDelayLeft != '00:00:00'){
      //
      //       int onDelay = DataConvert().parseTimeString(i.onDelayTimer);
      //       int onDelayCompleted = DataConvert().parseTimeString(i.onDelayComplete);
      //       int leftDelay = onDelay - onDelayCompleted;
      //       i.onDelayLeft = DataConvert().formatTime(leftDelay);
      //       if(leftDelay > 0){
      //         onDelayCompleted += 1;
      //         i.onDelayComplete = DataConvert().formatTime(onDelayCompleted);
      //       }else{
      //         i.onDelayComplete = '00:00:00';
      //       }
      //     }
      //   }
      // }
      // if(pumpControllerData!.pumps.every((element) => element.onDelayComplete == '00:00:00')){
      //   _timerForPumpController!.cancel();
      // }
    });
  }

  void saveUnits(List<dynamic> units) {
    unitList = units;
  }

  void setAppConnectionState(MQTTConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  String get receivedDashboardPayload => dashBoardPayload;
  String get receivedSchedulePayload => schedulePayload;
  MQTTConnectionState get getAppConnectionState => _appConnectionState;
}