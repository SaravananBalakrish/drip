import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../StateManagement/mqtt_payload_provider.dart';
import '../../services/mqtt_service.dart';
import '../../utils/environment.dart';

class ConfigureMqtt extends StatefulWidget {
  final String deviceID;

  const ConfigureMqtt({Key? key, required this.deviceID}) : super(key: key);

  @override
  _ConfigureMqttState createState() => _ConfigureMqttState();
}

class _ConfigureMqttState extends State<ConfigureMqtt> {
  late MqttPayloadProvider mqttPayloadProvider;
  List<Map<String, dynamic>> configs = [];
  List<String> projectNames = [];
  String? selectedProject;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);

    fetchData();
  }

  Future<void> fetchData() async {
    final url = Uri.parse('http://13.235.254.21:9000/getConfigs'); // Your API URL

    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> rawConfigs = data['data'];

        // Save configs as List<Map>
        configs = rawConfigs.cast<Map<String, dynamic>>();

        // Extract unique project names
        projectNames = configs.map((c) => c['PROJECT_NAME'] as String).toSet().toList();

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load configs: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  String formatConfig(Map<String, dynamic> config) {
    final projectName = config['PROJECT_NAME'] ?? '';

    if (projectName == 'ORO') {
       return
        '${config['MQTT_IP'] ?? '-'},'
            '${config['MQTT_USER_NAME'] ?? '-'},'
            '${config['MQTT_PASSWORD'] ?? '-'},'
            '${config['MQTT_PORT'] ?? '-'},'
            '${config['HTTP_URL'] ?? '-'},'
            '${config['STATIC_IP'] ?? '-'},'
            '${config['SUBNET_MASK'] ?? '-'},'
            '${config['DEFAULT_GATEWAY'] ?? '-'},'
            '${config['DNS_SERVER'] ?? '-'},'
            '${config['FTP_IP'] ?? '-'},'
            '${config['FTP_USER_NAME'] ?? '-'},'
            '${config['FTP_PASSWORD'] ?? '-'},'
            '${config['FTP_PORT'] ?? '-'},'
            '${config['MQTT_FRONTEND_TOPIC'] ?? '-'},'
            '${config['MQTT_HARDWARE_TOPIC'] ?? '-'},'
            '${config['MQTT_SERVER_TOPIC'] ?? '-'}'
             ';';
    } else {
      // Format for other projects - full list
      return
        '${config['MQTT_IP'] ?? '-'},'
            '${config['MQTT_USER_NAME'] ?? '-'},'
            '${config['MQTT_PASSWORD'] ?? '-'},'
            '${config['MQTT_PORT'] ?? '-'},'
            '${config['HTTP_URL'] ?? '-'},'
            '${config['STATIC_IP'] ?? '-'},'
            '${config['SUBNET_MASK'] ?? '-'},'
            '${config['DEFAULT_GATEWAY'] ?? '-'},'
            '${config['DNS_SERVER'] ?? '-'},'
            '${config['FTP_IP'] ?? '-'},'
            '${config['FTP_USER_NAME'] ?? '-'},'
            '${config['FTP_PASSWORD'] ?? '-'},'
            '${config['FTP_PORT'] ?? '-'},'
            '${config['MQTT_FRONTEND_TOPIC'] ?? '-'},'
            '${config['MQTT_HARDWARE_TOPIC'] ?? '-'},'
            '${config['MQTT_SERVER_TOPIC'] ?? '-'},'
            '${config['SFTP_IP'] ?? '-'},'
            '${config['SFTP_USER_NAME'] ?? '-'},'
            '${config['SFTP_PASSWORD'] ?? '-'},'
            '${config['SFTP_PORT'] ?? '-'},'
            '${config['MQTTS_PORT'] ?? '-'},'
            '${config['MQTTS_STATUS'] ?? '-'},'
            '${config['REVERSE_SSH_BROKER_NAME'] ?? '-'},'
            '${config['REVERSE_SSH_PORT'] ?? '-'}'
            ';';
    }
  }

  void sendSelectedProject() {
    if (selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a project")),
      );
      return;
    }

    // Find the config for selected project (assuming first match)
    final config = configs.firstWhere(
          (c) => c['PROJECT_NAME'] == selectedProject,
      orElse: () => {},
    );

    if (config.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Config not found for project $selectedProject")),
      );
      return;
    }

    final formatted = formatConfig(config);

    final payload = {
      "5700": {"5701": formatted},
    };
    print('jsonEncode(payload)${jsonEncode(payload)}');
    MqttService().topicToPublishAndItsMessage(
      jsonEncode(payload),
      "${Environment.mqttPublishTopic}/${widget.deviceID}",
    );
    print("Sending to device ${widget.deviceID}: $formatted");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Sending to ${widget.deviceID}: $formatted")),
    );

    // TODO: Actually send this string to device via your method
  }
  void Updatecode() {
    final payload = {
      "5700": {"5701": "28"},
    };
     MqttService().topicToPublishAndItsMessage(
      jsonEncode(payload),
      "${Environment.mqttPublishTopic}/${widget.deviceID}",
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configure MQTT: ${widget.deviceID}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: selectedProject,
              isExpanded: true,
              hint: const Text('Select Project'),
              items: projectNames.map((name) {
                return DropdownMenuItem(
                  value: name,
                  child: Text(name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedProject = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: sendSelectedProject,
                  child: const Text('Send Settings'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: Updatecode,
                  child: const Text('Update HW Code'),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
