import 'package:flutter/cupertino.dart';

import '../utils/routes.dart';
import '../utils/shared_preferences_helper.dart';

class NavRailViewModel extends ChangeNotifier {
  late int selectedIndex;

  NavRailViewModel(){
    initState();
  }

  void initState() {
    selectedIndex = 0;
    notifyListeners();
  }

  void onDestinationSelectingChange(int index){
    selectedIndex = index;
    notifyListeners();
  }

  Future<void> logout(context) async {
    await PreferenceHelper.clearAll();
    Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false,);
  }

}