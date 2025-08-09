import 'package:flutter/cupertino.dart';
import '../utils/enums.dart';
import '../utils/routes.dart';
import '../utils/shared_preferences_helper.dart';

class BaseHeaderViewModel extends ChangeNotifier {
  int selectedIndex = 0;
  int hoveredIndex = -1;
  final List<String> menuTitles;

  MainMenuSegment _segmentView = MainMenuSegment.dashboard;
  MainMenuSegment get mainMenuSegmentView => _segmentView;

  void updateMainMenuSegmentView(MainMenuSegment newView) {
    _segmentView = newView;
    selectedIndex = newView.index;
    notifyListeners();
  }

  BaseHeaderViewModel({required this.menuTitles}) {
    initState();
  }

  void initState() {
    selectedIndex = 0;
    notifyListeners();
  }

  void onDestinationSelectingChange(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void onHoverChange(int index) {
    hoveredIndex = index;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    await PreferenceHelper.clearAll();
    Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
  }
}