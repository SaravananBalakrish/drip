import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Screens/Constant/main_valve_in_constant.dart';
import 'package:oro_drip_irrigation/Screens/Constant/main_valve_in_constant.dart';
import 'package:oro_drip_irrigation/Screens/Constant/main_valve_in_constant.dart';
import 'package:oro_drip_irrigation/Screens/Constant/main_valve_in_constant.dart';
import 'package:oro_drip_irrigation/Screens/Constant/main_valve_in_constant.dart';
import 'package:oro_drip_irrigation/Screens/Constant/main_valve_in_constant.dart';
import 'package:oro_drip_irrigation/modules/constant/model/object_in_constant_model.dart';

import '../../../Constants/dialog_boxes.dart';
import '../../../StateManagement/overall_use.dart';
import '../../../repository/repository.dart';
import '../../../services/http_service.dart';
import '../../../services/mqtt_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/environment.dart';
import '../state_management/constant_provider.dart';
import '../widget/find_suitable_widget.dart';

class FilterSiteInConstant extends StatefulWidget {
  final ConstantProvider constPvd;
  final OverAllUse overAllPvd;
  const FilterSiteInConstant({super.key, required this.constPvd, required this.overAllPvd});

  @override
  State<FilterSiteInConstant> createState() => _FilterSiteInConstantState();
}

class _FilterSiteInConstantState extends State<FilterSiteInConstant> {
  double cellWidth = 200;
  MqttService mqttService = MqttService();
  final Repository repository = Repository(HttpService());

