import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Models/customer/condition_library_model.dart';
import '../../repository/repository.dart';

class ConditionLibraryViewModel extends ChangeNotifier {

  final Repository repository;
  bool isLoading = false;
  String errorMessage = "";

  late ConditionLibraryModel conditionLibraryData;
  List<String> selectedCnType = [];
  List<String> selectedComponent = [];
  List<String> selectedParameter = [];
  List<String> selectedValue = [];
  List<String> selectedReason= [];
  List<String> selectedDelayTime= [];
  List<String> selectedMessage= [];
  List<bool> selectedSwitchState = [];

  List<String> sensorList = [];


  TimeOfDay selectedStartTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay selectedEndTime = const TimeOfDay(hour: 12, minute: 0);

  final TextEditingController controllerVT = TextEditingController();
  final TextEditingController controllerAM = TextEditingController();

  ConditionLibraryViewModel(this.repository);

  Future<void> getConditionLibraryData(int customerId, int controllerId) async
  {
    setLoading(true);
    try {
      var response = await repository.fetchConditionLibrary({"customerId": customerId,"controllerId": controllerId});
      if (response.statusCode == 200) {
        print(response.body);
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          conditionLibraryData = ConditionLibraryModel.fromJson(jsonData['data']);
          print("Parameter List: ${conditionLibraryData.defaultData.parameter}");
          print("sensors List: ${conditionLibraryData.defaultData.sensors}");

          sensorList = conditionLibraryData.defaultData.sensors;
          sensorList.insert(0, '--');

          selectedParameter = List.generate(conditionLibraryData.defaultData.parameter.length+1, (index) => '--');
          selectedCnType = List.generate(5, (index) => 'Sensor');
          selectedComponent = List.generate(7, (index) => '--');
          selectedValue = List.generate(7, (index) => '--');
          selectedReason = List.generate(11, (index) => '--');
          selectedDelayTime = List.generate(4, (index) => '--');
          selectedMessage = List.generate(5, (index) => '--');
          selectedSwitchState = List.generate(5, (index) => false);

        }
      }
    } catch (error) {
      debugPrint('Error fetching language list: $error');
    } finally {
      setLoading(false);
    }
  }

  void conTypeOnChange(String type, int index){
    selectedCnType[index] = type;
    notifyListeners();
  }

  void lvlSensorCountOnChange(String param, int index){
    selectedParameter[index] = param;
    notifyListeners();
  }

  void componentOnChange(String lvlSensor, int index){
    selectedComponent[index] = lvlSensor;
    notifyListeners();
  }

  void valueOnChange(String lvlSensor, int index){
    selectedValue[index] = lvlSensor;
    notifyListeners();
  }

  void reasonOnChange(String lvlSensor, int index){
    selectedReason[index] = lvlSensor;
    notifyListeners();
  }

  void delayTimeOnChange(String lvlSensor, int index){
    selectedDelayTime[index] = lvlSensor;
    notifyListeners();
  }

  void switchStateOnChange(bool state, int index){
    selectedSwitchState[index] = state;
    notifyListeners();
  }




  void messageOnChange(String lvlSensor, int index){
    selectedMessage[index] = lvlSensor;
    notifyListeners();
  }

  void clearCondition(int index){
    selectedParameter[index] = '--';
    selectedComponent[index] = '--';
    selectedValue[index] = '--';
    selectedReason[index] = '--';
    selectedDelayTime[index] = '--';
    selectedMessage[index] = '--';
    notifyListeners();
  }


  Future<void> selectStartTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedStartTime,
    );

    if (pickedTime != null && pickedTime != selectedStartTime) {
      selectedStartTime = pickedTime;
      notifyListeners();
    }
  }

  Future<void> selectEndTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedEndTime,
    );

    if (pickedTime != null && pickedTime != selectedEndTime) {
      selectedEndTime = pickedTime;
      notifyListeners();
    }
  }









  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

}