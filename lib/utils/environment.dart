import '../flavors.dart';

class Environment {
  static const String currentEnvironment = String.fromEnvironment('ENV', defaultValue: 'oroDevelopment');
  static const String appVersion = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');

  static Map<String, Map<String, dynamic>> config = {
    'oroDevelopment' : {
      'apiUrl': 'http://192.168.68.141:5000/api/v1',
      'apiKey': 'dev-api-key',
      'mqttWebUrl': 'ws://192.168.68.141',
      'mqttMobileUrl': '192.168.68.141',
      'publishTopic': 'AppToFirmware',
      'subscribeTopic': 'FirmwareToApp',
      'mqttPort': 9001,
    },
    'smartComm' : {
      'apiUrl': 'http://192.168.68.141:5000/api/v1',
      'apiKey': 'dev-api-key',
      'mqttWebUrl': 'ws://192.168.68.141',
      'publishTopic': 'AppToFirmware',
      'subscribeTopic': 'FirmwareToApp',
      'mqttMobileUrl': '192.168.68.141',
      'mqttPort': 9001,
    },
    'oroProduction': {
      'apiUrl': 'http://4.213.181.6:5000/api/v1',
      'apiKey': 'prod-api-key',
      'mqttWebUrl': 'ws://52.172.214.208:1883/mqtt',
      'publishTopic': 'AppsToFirmware',
      'subscribeTopic': 'FirmwareToApps',
      'mqttPort': 1883,
    },
  };

  static String get apiUrl => config[F.name]?['apiUrl'] ?? '';
  static String get apiKey => config[currentEnvironment]?['apiKey'] ?? '';

  static String get mqttWebUrl => config[F.name]?['mqttWebUrl'] ?? '';
  static String get mqttWebPublishTopic => config[F.name]?['publishTopic'] ?? '';
  static String get mqttMobileUrl => config[F.name]?['mqttMobileUrl'] ?? '';
  static int get mqttPort => config[F.name]?['mqttPort'] ?? 0;
}