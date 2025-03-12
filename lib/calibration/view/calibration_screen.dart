import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oro_drip_irrigation/Widgets/sized_image.dart';
import 'package:oro_drip_irrigation/calibration/repository/calibration_repository.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import '../../Constants/properties.dart';
import '../../utils/constants.dart';
import '../model/sensor_category_model.dart';

class CalibrationScreen extends StatefulWidget {
  final int userId;
  final int controllerId;
  const CalibrationScreen({super.key, required this.userId, required this.controllerId});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  Map<String, dynamic> data = {
    "calibration": [
      {
        "objectTypeId": 24,
        "object": "Pressure Sensor",
        "objectList": [
          {
            "objectId": 24,
            "sNo": 24.001,
            "name": "Pressure Sensor 1",
            "objectName": "Pressure Sensor",
            "getData1": "",
            "getData2": "",
            "getData3": "",
            "calibrationFactor": "1.0",
            "maximumValue": "1.0"
          },
          {
            "objectId": 24,
            "sNo": 24.002,
            "name": "Pressure Sensor 2",
            "objectName": "Pressure Sensor",
            "getData1": "",
            "getData2": "",
            "getData3": "",
            "calibrationFactor": "1.0",
            "maximumValue": "1.0"
          }
        ]
      },
      {
        "objectTypeId": 26,
        "object": "Level Sensor",
        "objectList": [
          {
            "objectId": 26,
            "sNo": 26.001,
            "name": "Level Sensor 1",
            "objectName": "Level Sensor",
            "getData1": "",
            "getData2": "",
            "getData3": "",
            "calibrationFactor": "1.0",
            "maximumValue": "1.0"
          },
          {
            "objectId": 26,
            "sNo": 26.002,
            "name": "Level Sensor 2",
            "objectName": "Level Sensor",
            "getData1": "",
            "getData2": "",
            "getData3": "",
            "calibrationFactor": "1.0",
            "maximumValue": "1.0"
          }
        ]
      },
      {
        "objectTypeId": 27,
        "object": "EC Sensor",
        "objectList": [
          {
            "objectId": 27,
            "sNo": 27.001,
            "name": "EC Sensor 1",
            "objectName": "EC Sensor",
            "getData1": "",
            "getData2": "",
            "getData3": "",
            "calibrationFactor": "1.0",
            "maximumValue": "1.0"
          }
        ]
      },
      {
        "objectTypeId": 28,
        "object": "PH Sensor",
        "objectList": [
          {
            "objectId": 28,
            "sNo": 28.001,
            "name": "PH Sensor 1",
            "objectName": "PH Sensor",
            "getData1": "",
            "getData2": "",
            "getData3": "",
            "calibrationFactor": "1.0",
            "maximumValue": "1.0"
          }
        ]
      },
      {
        "objectTypeId": 30,
        "object": "Soil Temperature Sensor",
        "objectList": [
          {
            "objectId": 30,
            "sNo": 30.001,
            "name": "Soil Temperature Sensor 1",
            "objectName": "Soil Temperature Sensor",
            "getData1": "",
            "getData2": "",
            "getData3": "",
            "calibrationFactor": "1.0",
            "maximumValue": "1.0"
          }
        ]
      },
      {
        "objectTypeId": 22,
        "object": "Water Meter",
        "objectList": [
          {
            "objectId": 22,
            "sNo": 22.001,
            "name": "Water Meter 1",
            "objectName": "Water Meter",
            "getData1": "",
            "getData2": "",
            "getData3": "",
            "calibrationFactor": "1.0",
            "maximumValue": "1.0"
          }
        ]
      }
    ],
    "default": {
      "maximum": "24,26",
      "factor": "22,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39",
      "objects": [
        {
          "objectId": 24,
          "unit": "bar",
          "subtitle": "4-20 mA"
        },
        {
          "objectId": 26,
          "unit": "m",
          "subtitle": "4-20 mA"
        }
      ]
    }
  };
  late Future<List<SensorCategoryModel>> listOfSensorCategoryModel;
  late Map<String, dynamic> defaultData;
  Set<int> selectedTab = {0};


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listOfSensorCategoryModel = getCalibration(userId: widget.userId, controllerId: widget.controllerId);
  }

  Future<List<SensorCategoryModel>> getCalibration({required int userId, required int controllerId}) async {
    List<SensorCategoryModel> calibrationData = [];
    try {
      var body = {
        "userId": userId,
        "controllerId": controllerId,
      };
      var response = await CalibrationRepository().getUserCalibration(body);
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      calibrationData = (jsonData['data']['calibration'] as List<dynamic>).map((element){
        return SensorCategoryModel.fromJson(element);
      }).toList();
      setState(() {
        defaultData = jsonData['data']['default'];
      });

    } catch (e, stackTrace) {
      print('error :: $e');
      print('stackTrace :: $stackTrace');
      rethrow;
    }
    return calibrationData;
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SensorCategoryModel>>(
        future: listOfSensorCategoryModel,
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Loading state
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // Error state
          } else if (snapshot.hasData) {
            return Material(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20,),
                    getCalibrationCategory(),
                    const SizedBox(height: 20,),
                    ...getFilterByMaximumAndFactor(snapshot.data!),
                  ],
                ),
              ),
            );
          } else {
            return const Text('No data'); // Shouldn't reach here normally
          }

        }
    );
  }

  List<Widget> getFilterByMaximumAndFactor(List<SensorCategoryModel> data){
    return [
      for(var sensorCategory in data)
        Column(
          spacing: 10,
          children: [
            sensorCategoryWidget(sensorCategory),
            ResponsiveGridList(
              horizontalGridMargin: 20,
              verticalGridMargin: 10,
              minItemWidth: 150,
              shrinkWrap: true,
              listViewBuilderOptions: ListViewBuilderOptions(
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: sensorCategory.calibrationObject.map((object){
                return Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).cardColor,
                      boxShadow: AppProperties.customBoxShadowLiteTheme
                  ),
                  width: 300,
                );
              }).toList()
            )
          ],
        )
    ];
  }

  Widget sensorCategoryWidget(SensorCategoryModel sensorCategory){
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xffF5F5F5),
          border: Border.all(width: 0.1)
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        spacing: 10,
        children: [
          CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).primaryColorDark,
              child: SizedImage(imagePath: '${AppConstants.svgObjectPath}objectId_${sensorCategory.objectTypeId}.svg')
          ),
          Text(sensorCategory.object, style: Theme.of(context).textTheme.bodyLarge,),
        ],
      ),
    );
  }

  Widget getCalibrationCategory(){
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(value: 0, label: Text("Calibration")),
        ButtonSegment(value: 1, label: Text("Factor")),
      ],
      selected: selectedTab, // Must be a Set<int>
      onSelectionChanged: (Set<int> newSelection) {
        setState(() {
          selectedTab = newSelection;
        });
      },
    );
  }
}



