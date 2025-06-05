import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Constants/notifications_service.dart';
import '../flavors.dart';
import '../utils/Theme/smart_comm_theme.dart';
import '../utils/Theme/oro_theme.dart';
import '../utils/routes.dart';
import '../utils/shared_preferences_helper.dart';
import '../views/login_screen.dart';
import '../views/screen_controller.dart';
import '../views/splash_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      // Initialize notifications and request permissions
      NotificationServiceCall().initialize();
      NotificationServiceCall().configureFirebaseMessaging();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NotificationServiceCall.requestPermission(context);
      });
    }
  }

  /// Show a custom dialog to ask for notification permission
  Future<bool> showNotificationPrompt(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Allow Notifications'),
        content: const Text('Would you like to receive push notifications from this app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Skip'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Allow'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Determine initial route based on token
  Future<String> getInitialRoute() async {
    try {
      final token = await PreferenceHelper.getToken();
      return (token != null && token.trim().isNotEmpty) ? Routes.dashboard : Routes.login;
    } catch (e) {
      debugPrint("Error in getInitialRoute: $e");
      return Routes.login;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOro = F.appFlavor?.name.contains('oro') ?? false;
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return FutureBuilder<String>(
      future: getInitialRoute(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: isOro ? OroTheme.lightTheme : SmartCommTheme.lightTheme,
          darkTheme: isOro ? OroTheme.darkTheme : SmartCommTheme.darkTheme,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: navigateToInitialScreen(snapshot.data ?? Routes.login),
          onGenerateRoute: Routes.generateRoute,
        );
      },
    );
  }
}

Widget navigateToInitialScreen(String route) {
  switch (route) {
    case Routes.login:
      return const LoginScreen();
    case Routes.dashboard:
      return const ScreenController();
    default:
      return const SplashScreen();
  }
}