import 'package:flutter/material.dart';
import '../../Models/customer/site_model.dart';

class IrrigationLineViewModel extends ChangeNotifier {
  final List<IrrigationLineData>? lineData;
  final double screenWidth;

  int crossAxisCount = 0;
  double gridHeight = 0;
  List<Widget> valveWidgets = [];

  IrrigationLineViewModel(BuildContext context, this.lineData, this.screenWidth) {
    _initialize(context);
  }

  void _initialize(context) {
    if (lineData == null || lineData!.isEmpty) return;

  }


}

