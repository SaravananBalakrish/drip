import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Constants/theme.dart';
import 'package:oro_drip_irrigation/StateManagement/config_maker_provider.dart';
import 'package:provider/provider.dart';
import 'Constants/env_setup.dart';
import 'Screens/ConfigMaker/config_base_page.dart';
import 'Screens/ConfigMaker/config_web_view.dart';

void main() {
  GlobalConfig.setEnvironment(Environment.development);
  String? dataFromSession = readFromSessionStorage('configData');
  Map<String, dynamic> data = jsonDecode(dataFromSession!);
  // print("data : $data");
  // print(data.keys);
  var dataFormation = {};
  for(var globalKey in data.keys){
    print('globalKey : $globalKey');
    if(['filtration', 'fertilization', 'source', 'pump', 'moisture', 'line'].contains(globalKey)){
      dataFormation[globalKey] = [];
      for(var itemData in data[globalKey]){
        var itemFormation = {};
        for(var parameter in itemData.keys){
          itemFormation[parameter] = itemData[parameter] is List<dynamic> ? (itemData[parameter] as List<dynamic>).map((element) => (data['listOfGeneratedObject'] as List<dynamic>).firstWhere((object) => object['sNo'] == element)).toList() : (data['listOfGeneratedObject'] as List<dynamic>).firstWhere((object) => object['sNo'] == itemData[parameter], orElse: ()=> 0.0);
          dataFormation[globalKey].add(itemFormation);
        }
      }
    }
  }
  print('dataFormation : ${dataFormation['line']}');
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ConfigMakerProvider()),
          // Provider<Logger>(
          //   create: (_) => GlobalConfig.getService<Logger>(),
          // ),
        ],
        child: const MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppThemes.lightTheme,
      home: const ConfigBasePage(),
    );
  }
}

