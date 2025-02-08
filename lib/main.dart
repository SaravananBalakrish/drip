import 'package:oro_drip_irrigation/Constants/mqtt_manager_mobile.dart'
if (dart.library.html) 'package:oro_drip_irrigation/Constants/mqtt_manager_web.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/StateManagement/config_maker_provider.dart';
import 'package:oro_drip_irrigation/utils/network_utils.dart';
import 'package:provider/provider.dart';
import 'Constants/env_setup.dart';
import 'app/app.dart';

void main() {
  NetworkUtils.initialize();
  GlobalConfig.setEnvironment(Environment.development);
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ConfigMakerProvider()),
        ],
        child: const MyApp(),
      )
  );
}
