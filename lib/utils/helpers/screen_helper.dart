import '../enums.dart';

const int mobileBreakpoint = 600;
const int tabletBreakpoint = 900;
const int desktopBreakpoint = 1200;

class ScreenHelper {
  static DeviceScreenType getDeviceType(double width) {
    if (width >= desktopBreakpoint) return DeviceScreenType.web;
    if (width >= tabletBreakpoint) return DeviceScreenType.desktop;
    if (width >= mobileBreakpoint) return DeviceScreenType.tablet;
    return DeviceScreenType.mobile;
  }
}