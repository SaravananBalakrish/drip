import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../utils/enums.dart';
import '../utils/helpers/screen_helper.dart';
import '../views/admin/desktop/admin_desktop.dart';
import '../views/admin/mobile/admin_mobile.dart';
import '../views/admin/tablet/admin_tablet.dart';
import '../views/admin/web/admin_web.dart';
import '../views/customer/desktop/customer_desktop.dart';
import '../views/customer/mobile/customer_mobile.dart';
import '../views/customer/tablet/customer_tablet.dart';
import '../views/customer/web/customer_web.dart';
import '../views/dealer/desktop/dealer_desktop.dart';
import '../views/dealer/mobile/dealer_mobile.dart';
import '../views/dealer/tablet/dealer_tablet.dart';
import '../views/dealer/web/dealer_web.dart';
import '../views/super_admin/mobile/super_admin_mobile.dart';

class LayoutController {
  static Widget getLayout(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final type = ScreenHelper.getDeviceType(width);
    final role = context.watch<UserProvider>().role;

    Widget getRoleBasedWidget(UserRole role) {
      switch (role) {
        case UserRole.superAdmin:
          return const SuperAdminMobile();
        case UserRole.admin:
          return _getLayoutForRole(
              type, const AdminMobile(),
              const AdminTablet(),
              const AdminDesktop(),
              const AdminWeb()
          );
        case UserRole.dealer:
          return _getLayoutForRole(
              type, const DealerMobile(),
              const DealerTablet(),
              const DealerDesktop(),
              const DealerWeb()
          );
        case UserRole.customer:
        case UserRole.subUser:
          return _getLayoutForRole(
              type, const CustomerMobile(),
              const CustomerTablet(),
              const CustomerDesktop(),
              const CustomerWeb()
          );
      }
    }

    return getRoleBasedWidget(role);
  }

  static Widget _getLayoutForRole(DeviceScreenType type, Widget mobile, Widget tablet, Widget desktop, Widget web) {
    return switch (type) {
      DeviceScreenType.mobile => mobile,
      DeviceScreenType.tablet => tablet,
      DeviceScreenType.desktop => desktop,
      DeviceScreenType.web => web,
    };
  }
}