import 'dart:convert';
import 'package:flutter/material.dart';
import '../../Models/customer/site_model.dart';
import '../../utils/Theme/oro_theme.dart';
import '../../utils/constants.dart';

class FertilizationDashboard extends StatefulWidget {
  final List<FertilizerSite> fertilizerSite;
  const FertilizationDashboard({super.key, required this.fertilizerSite});

  @override
  State<FertilizationDashboard> createState() => _FertilizationDashboardState();
}

class _FertilizationDashboardState extends State<FertilizationDashboard> {
  late ThemeData themeData;
  late bool themeMode;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    themeData = Theme.of(context);
    themeMode = themeData.brightness == Brightness.light;
  }
  @override
  Widget build(BuildContext context) {
    return Container();
  }


}







