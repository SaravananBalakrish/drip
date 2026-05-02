import 'package:flutter/material.dart';

import '../../models/customer/help_support_model.dart';

class OroDashboardHelpContent {
  static const String title =
      'Irrigation Dashboard – Quick Overview';

  static const List<HelpSection> sections = [
    HelpSection(
      heading: 'Alerts & Notifications',
      icon:  Icons.alarm,
      description:
      'Shows important alerts like pump overload, pump OFF alarm, '
          'pressure high or low, dry run, and system warnings. '
          'Always check alerts before starting irrigation.',
    ),

    HelpSection(
      heading: 'Smart Advisory',
      icon:  Icons.stars_rounded,
      description:
      'Displays charts and AI-based crop advisory. '
          'Helps decide when to irrigate and how much water is required.',
    ),

    HelpSection(
      heading: 'Menu',
      icon:  Icons.menu,
      description:
      'Access profile edit, app information, help and support, '
          'send feedback, service request, and devices.',
    ),

    HelpSection(
      heading: 'Water Source & Well Status',
      icon:  Icons.water_drop_outlined,
      description:
      'Shows bore, well, and motor availability. '
          'Well level is displayed in percentage and feet to avoid dry run.',
    ),

    HelpSection(
      heading: 'Farm Control & Site View',
      icon:  Icons.energy_savings_leaf_outlined,
      description:
      '🏡 Site Selection\n'
          '• Customers can manage multiple sites (farms/locations) separately.\n'
          '• Each site contains one or more controllers.\n'
          '• You can switch between sites to view data independently.\n\n'

          '🎛️ Controller & Irrigation Lines\n'
          '• Each controller manages multiple irrigation lines.\n'
          '• Switch between controllers to view connected farms and valves.\n'
          '• Each irrigation line is displayed separately for easy monitoring.\n\n'

          '⏸️ Farm Control\n'
          '• Pause irrigation instantly for rain, maintenance, or emergency.\n'
          '• Stops water flow safely without affecting other sites or controllers.\n\n'

          '🔄 Last Sync Status\n'
          '• Shows the last time data was received from the controller.\n'
          '• Helps confirm whether the system is live and connected.',
    ),

    HelpSection(
      heading: 'Pressure Monitoring',
      icon:  Icons.watch_later_outlined,
      description:
      'Shows live pipeline pressure to detect leakage, blockage, '
          'or motor-related issues.',
    ),

    HelpSection(
      heading: 'Irrigation Flow Control',
      icon:  Icons.water_drop_outlined,
      description:
      '💧 Irrigation Components\n'
          '• Each valve represents one irrigation zone in the field.\n'
          '• Pump, filter, and fertilizer channels are part of the irrigation flow.\n\n'

          '🟢 Green Status\n'
          '• Valve ON – water is flowing to the field.\n'
          '• Pump ON – motor is running.\n'
          '• Filter ON – filtration is active.\n'
          '• Fertilizer ON – fertigation is in progress.\n\n'

          '⚪ Grey Status\n'
          '• Valve OFF – water is stopped.\n'
          '• Pump OFF – motor is not running.\n'
          '• Filter OFF – filtration is inactive.\n'
          '• Fertilizer OFF – fertigation is stopped.\n\n'

          'ℹ️ Note\n'
          '• All components work together to control safe and efficient irrigation.',
    ),

    HelpSection(
      heading: 'Controller Menu (☰)',
      icon:  Icons.menu,
      description:
      'This menu appears when tapping the menu icon inside an irrigation line.\n\n'

          '• Node Status: Shows controller health, online/offline status, '
          'and connected device availability.\n'
          '• I/O Connection Details: Displays connected pumps, valves, sensors, '
          'filters, and fertilizer channels mapped to the controller.\n'
          '• Program: Create and manage irrigation programs.\n'
          '• Scheduled Program Details: View all scheduled programs and timings.\n'
          '• Manual: Manually operate pumps, valves, filters, and fertilizers.\n'
          '• Sent & Received: View command and response communication logs.',
    ),

    HelpSection(
      heading: 'Connectivity Control',
      icon:  Icons.wifi,
      description:
      'The floating button at the bottom is used to manage controller connectivity.\n\n'

          '• Bluetooth Mode (🔵):\n'
          '  Used for nearby connection during installation, setup, '
          'or troubleshooting.\n'
          '  Allows direct communication with the controller without internet.\n\n'

          '• Wi-Fi Mode (📶):\n'
          '  Connects the master controller to the internet.\n'
          '  Used for remote monitoring, cloud data sync, alerts, and reports.\n\n'

          '• Change Wi-Fi Network:\n'
          '  You can update or switch the Wi-Fi network connected to the '
          'master controller anytime.\n'
          '  Helpful when router changes or signal issues occur.\n\n'

          '• Mode Status Indicator:\n'
          '  Shows current connection type and signal strength '
          '(Bluetooth or Wi-Fi).',
    ),

    HelpSection(
      heading: 'Connectivity Status',
      icon:  Icons.cell_wifi,
      description:
      'Shows device signal strength and connection health.',
    ),

    HelpSection(
      heading: 'Bottom Menu',
      icon:  Icons.linear_scale,
      description:
      '🏠 Home\n'
          '• Monitor live irrigation status of all farms and valves.\n'
          '• View scheduled irrigation programs.\n'
          '• Run irrigation manually when required.\n'
          '• View irrigation reports such as pump log, power log, and operation history.\n\n'

          '📅 Scheduled\n'
          '• Create and manage automatic irrigation programs.\n'
          '• Set start time, duration, and conditions.\n\n'

          '📄 Log\n'
          '• View detailed history of irrigation activities.\n'
          '• Check pump ON/OFF logs, power logs, alerts, and system events.\n\n'

          '⚙️ Settings\n'
          '• General controller settings such as controller MAC ID, site name, UTC time, and firmware version.\n'
          '• Preference settings for pump and valves.\n'
          '• Configure common options like constant settings for all valves, filters, and fertilizer units.\n'
          '• Change names of farms, pumps, valves, filters, and other connected devices.',
    ),
  ];

  static const String dailyTip =
      'Daily Tip: Check alerts, well level, pressure, and green valves '
      'before starting irrigation.';
}