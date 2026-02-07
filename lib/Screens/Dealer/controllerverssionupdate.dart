
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_drip_irrigation/Screens/Dealer/pumpTopicChange.dart';
import 'package:oro_drip_irrigation/utils/constants.dart';
import 'package:oro_drip_irrigation/utils/environment.dart';
import 'package:provider/provider.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../services/mqtt_service.dart';
import '../../utils/shared_preferences_helper.dart';
import 'configureMqttTopic.dart';
import 'controllerlogfile.dart';
import 'frequencyLoRaPage.dart';


class ResetVerssion extends StatefulWidget {
  const ResetVerssion(
      {Key? key,
        required this.userId,
        required this.controllerId,
        required this.deviceID});
  final userId, controllerId, deviceID;

  @override
  _ResetVerssionState createState() => _ResetVerssionState();
}

class _ResetVerssionState extends State<ResetVerssion> {
  List<Map<String, dynamic>> mergedList = [];
  late MqttPayloadProvider mqttPayloadProvider;

  String? selectedDeviceId;
  int checkupdatediable = 0;
  String? userRole;

  @override
  void initState() {
    super.initState();

    mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: false);

    fetchData();
    checkrole().then((role) => setState(() => userRole = role));

    mqttPayloadProvider.addListener(_onMqttPayloadChanged);
  }

  @override
  void dispose() {
    mqttPayloadProvider.removeListener(_onMqttPayloadChanged);
    super.dispose();
  }

  /* ---------------- MQTT LISTENER ---------------- */

  void _onMqttPayloadChanged() {
    print("mergedList--->${mergedList}");
    if (!mounted || selectedDeviceId == null) return;

    final data = mqttPayloadProvider.messageFromHw;
    if (data == null || data.isEmpty) return;

    final index = mergedList.indexWhere(
            (e) => e['deviceId'] == data['DeviceId']);
    if (index == -1) return;

    final name = data['Name'] ?? '';

    setState(() {
      if (name.contains('Started') || name.contains('Progress')) {
        mergedList[index]['status'] = 'Progress';
        mergedList[index]['icon'] = Icons.downloading;
        mergedList[index]['iconColor'] = Colors.blue;
      } else if (name.contains('Restarting')) {
        mergedList[index]['status'] = 'Restarting...';
        mergedList[index]['icon'] = Icons.restart_alt;
        mergedList[index]['iconColor'] = Colors.teal;
      } else if (name.contains('Turned')) {
        mergedList[index]['status'] = 'Success';
        mergedList[index]['icon'] = Icons.check_circle;
        mergedList[index]['iconColor'] = Colors.green;
        checkupdatediable = 0;
        selectedDeviceId = null;
      } else if (name.contains('wrong') || name.contains('GitFailed')) {
        mergedList[index]['status'] = data['Message'] ?? 'Error';
        mergedList[index]['icon'] = Icons.error;
        mergedList[index]['iconColor'] = Colors.red;
        checkupdatediable = 0;
        selectedDeviceId = null;
      }
    });
  }

  /* ---------------- DATA ---------------- */

  Future<void> fetchData() async {
    final Repository repository = Repository(HttpService());
    var response =
    await repository.getUserDeviceFirmwareDetails({"userId": widget.userId});

    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body);
      mergedList.clear();

      for (var group in jsondata['data']) {
        for (var device in group['master']) {
          mergedList.add({
            'deviceId': device['deviceId'],
            'groupName': group['groupName'],
            'categoryName': device['categoryName'],
            'modelName': device['modelName'],
            'currentVersion': device['currentVersion'] ?? '',
            'latestVersion': device['latestVersion'] ?? '',
            'status': 'Status',
            'icon': Icons.info_outline,
            'iconColor': Colors.grey,
          });
        }
      }

      setState(() {});
    }
  }

  Future<String?> checkrole() async {
    return await PreferenceHelper.getUserRole();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade100,
      appBar: AppBar(title: const Text('Controller Info')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mergedList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: kIsWeb ? 3 : 1,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          mainAxisExtent: 500,
        ),
        itemBuilder: (context, index) {
          final item = mergedList[index];
          return Card(
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['categoryName'],
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),

                  SelectableText(item['deviceId'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),

                  Text('Site : ${item['groupName']}'),
                  Text('Model : ${item['modelName']}'),
                  Text('Controller : ${item['currentVersion']}'),
                  Text('Server : ${item['latestVersion']}'),

                  Icon(item['icon'],
                      color: item['iconColor'], size: 36),

                  Text(item['status'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),

                  LinearProgressIndicator(
                    value: _progressValue(),
                    minHeight: 8,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      FilledButton(
                        onPressed: checkupdatediable == 0
                            ? () {
                          setState(() {
                            checkupdatediable = 1;
                          });

                          _showDialogcheck(context, "Restart", index);
                        }
                            : null,
                        child: const Text('Restart'),
                      ),
                      FilledButton(
                        onPressed: checkupdatediable == 0
                            ? () {
                          setState(() {
                            checkupdatediable = 1;
                          });

                          _showDialogcheck(context, "Update", index);
                        }
                            : null,
                        child: const Text('Update'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  double _progressValue() {
    try {
      final p = mqttPayloadProvider.proogressstatus
          .replaceAll('%', '')
          .trim();
      print("mqttPayloadProvider.proogressstatus---->${mqttPayloadProvider.proogressstatus}");
      return (double.tryParse(p) ?? 0) / 100;
    } catch (_) {
      return 0;
    }
  }

  void _showDialogcheck(BuildContext context, String update, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: Text(
              "Are you sure you want to $update?\n First, stop. If you confirm that you want to stop, then update your controller by clicking the 'Sure' button."),
          actions: [
            TextButton(
              onPressed: () {
                update == "Update" ? _update(index) : _restart(index);
                Navigator.of(context).pop();
              },
              child: const Text('Sure'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  void _update(int index) {
    selectedDeviceId = mergedList[index]['deviceId'];
    checkupdatediable = 1;

    MqttService().topicToPublishAndItsMessage(
      jsonEncode({"5700": {"5701": "3"}}),
      "${Environment.mqttPublishTopic}/${selectedDeviceId}",
    );
  }

  void _restart(int index) {
    selectedDeviceId = mergedList[index]['deviceId'];
    checkupdatediable = 1;

    MqttService().topicToPublishAndItsMessage(
      jsonEncode({"5700": {"5701": "2"}}),
      "${Environment.mqttPublishTopic}/${selectedDeviceId}",
    );
  }
}

class BlinkingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration blinkDuration;

  const BlinkingText({
    Key? key,
    required this.text,
    this.style = const TextStyle(fontSize: 20, color: Colors.red),
    this.blinkDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  _BlinkingTextState createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<BlinkingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.blinkDuration,
      reverseDuration: widget.blinkDuration,
    )..repeat(reverse: true);

    _opacityAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Text(
        widget.text,
        style: widget.style,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

