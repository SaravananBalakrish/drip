import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'dashboard_screen.dart';
import 'crop_weatherScreen.dart';
import 'irrigation_fertigation_screen.dart';
import 'report_screen.dart';

class CropAdvisoryMainScreen extends StatefulWidget {
  final int initialIndex,userId,controllerId;
  const CropAdvisoryMainScreen({super.key, this.initialIndex = 0, required this.userId, required this.controllerId});

  @override
  State<CropAdvisoryMainScreen> createState() => _CropAdvisoryMainScreenState();
}

class _CropAdvisoryMainScreenState extends State<CropAdvisoryMainScreen> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: widget.initialIndex);
  }

  List<Widget> _buildScreens() {
    return [
      DashboardScreen(isInsideMain: true, userID: widget.userId, controllerId: widget.controllerId),
      CropWeatherscreen(userId: widget.userId, controllerId: widget.controllerId),
      const IrrigationFertigationScreen(isInsideMain: true),
      const Center(child: Text('Disease Screen (Coming Soon)')),
      const ReportScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    const activeColor = Color(0xFF1B7F8A);
    const inactiveColor = Colors.grey;
    
    return [
      PersistentBottomNavBarItem(
        icon: Image.asset('assets/Images/CropAdvisory/home_icon_active.png', width: 24, height: 24, color: activeColor),
        inactiveIcon: Image.asset('assets/Images/CropAdvisory/home_icon_active.png', width: 24, height: 24, color: inactiveColor),
        title: ("Home"),
        activeColorPrimary: activeColor,
        inactiveColorPrimary: inactiveColor,
      ),
      PersistentBottomNavBarItem(
        icon: Image.asset('assets/Images/CropAdvisory/weather.png', width: 24, height: 24, color: activeColor),
        inactiveIcon: Image.asset('assets/Images/CropAdvisory/weather.png', width: 24, height: 24, color: inactiveColor),
        title: ("Weather"),
        activeColorPrimary: activeColor,
        inactiveColorPrimary: inactiveColor,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.water_drop, size: 24, color: activeColor),
        inactiveIcon: const Icon(Icons.water_drop_outlined, size: 24, color: inactiveColor),
        title: ("Irrigation"),
        activeColorPrimary: activeColor,
        inactiveColorPrimary: inactiveColor,
      ),
      PersistentBottomNavBarItem(
        icon: Image.asset('assets/Images/CropAdvisory/disease.png', width: 24, height: 24, color: activeColor),
        inactiveIcon: Image.asset('assets/Images/CropAdvisory/disease.png', width: 24, height: 24, color: inactiveColor),
        title: ("Disease"),
        activeColorPrimary: activeColor,
        inactiveColorPrimary: inactiveColor,
      ),
      PersistentBottomNavBarItem(
        icon: Image.asset('assets/Images/CropAdvisory/report.png', width: 24, height: 24, color: activeColor),
        inactiveIcon: Image.asset('assets/Images/CropAdvisory/report.png', width: 24, height: 24, color: inactiveColor),
        title: ("Report"),
        activeColorPrimary: activeColor,
        inactiveColorPrimary: inactiveColor,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineToSafeArea: true,
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      decoration: NavBarDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        colorBehindNavBar: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      navBarStyle: NavBarStyle.style1, // Style 1 shows text for all buttons
    );
  }
}
