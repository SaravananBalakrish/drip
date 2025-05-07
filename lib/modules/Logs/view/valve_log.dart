import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oro_drip_irrigation/modules/IrrigationProgram/view/schedule_screen.dart';

import '../../../Constants/constants.dart';
import '../../../Models/customer/site_model.dart';
import '../model/event_log_model.dart';

class ValveLog extends StatelessWidget {
  final List<EventLog> events;
  final MasterControllerModel masterData;
  const ValveLog({super.key, required this.events, required this.masterData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedEvents = _groupEvents(events);
    return Column(
      children: groupedEvents.map((group) {
        return Card(
          margin: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).primaryColorLight,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
          color: Colors.white,
          surfaceTintColor: Colors.white,
          shadowColor: Theme.of(context).primaryColorLight.withAlpha(100),
          child: Column(
            children: [
              _buildHeader(group['header']!, theme),
              ...group['valves']!.map<Widget>((valve) => _buildValveLog(event: valve, theme: theme)),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _groupEvents(List<EventLog> events) {
    final headers = events.where((e) => !e.isValve).toList();
    final valves = events.where((e) => e.isValve).toList();

    final timeFormat = DateFormat.Hm();
    DateTime lastKnownTime = timeFormat.parse("00:00");

    DateTime safeParseTime(String timeStr) {
      try {
        return timeFormat.parse(timeStr.substring(0, 5));
      } catch (e) {
        return lastKnownTime;
      }
    }

    List<Map<String, dynamic>> result = [];

    for (var header in headers) {
      final onTime = safeParseTime(header.onTime);
      final offTime = safeParseTime(header.offTime);

      final groupValves = valves.where((v) {
        final valveOn = safeParseTime(v.onTime);
        final valveOff = safeParseTime(v.offTime);

        return valveOn.isBefore(offTime) && valveOff.isAfter(onTime);
      }).toList();

      if (groupValves.isNotEmpty) {
        final lastValve = groupValves.last;
        try {
          lastKnownTime = timeFormat.parse(lastValve.offTime.substring(0, 5));
        } catch (_) {
        }
      }

      result.add({'header': header, 'valves': groupValves});
    }

    return result;
  }

  Widget _buildHeader(EventLog event, ThemeData theme) {
    final String pump = masterData.configObjects.where((e) => e.objectId == 5).map((ele) => ele.name).toList()[0];
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange)
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildItemContainer(
              title: event.onReason.replaceAll("MOTOR1", pump.toUpperCase()),
              value: event.onTime,
              theme: theme,
              color: Colors.green
          ),
          _buildItemContainer(
              title: "Duration".toUpperCase(),
              value: event.duration,
              theme: theme
          ),
          _buildItemContainer(
              title: event.offReason.replaceAll("MOTOR1", pump.toUpperCase()),
              value: event.offTime,
              theme: theme,
              color: Colors.red
          ),
        ],
      ),
    );
  }

  Widget _buildItemContainer({
    required String title,
    required String value,
    required ThemeData theme,
    Color color = Colors.black,
  }) {
    return ListTile(
      minTileHeight: 35,
      horizontalTitleGap: 8,
      dense: false,
      minVerticalPadding: 0,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Text(title, style: const TextStyle(fontSize: 13),),
      // subtitle: Text(value),
      trailing: SizedBox(
          width: 60,
          child: Text(value, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis,)
      ),
      leading: Icon(Icons.radio_button_checked, color: color,),
    );
  }

  Widget _buildValveLog({required EventLog event, required ThemeData theme}) {
    final valves = masterData.configObjects.where((e) => e.objectId == 13).map((e) => e.name).toList();
    final String valveName = valves[int.parse(event.onReason.split(' ')[0].substring(5)) - 1];
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          minVerticalPadding: 0,
          minTileHeight: 55,
          dense: false,
         // title: Text(valveName[int.parse(event.onReason.split(' ')[0].substring(5))]),
          title: Text(valveName,
            style: theme.textTheme.bodyLarge!.copyWith(color: theme.primaryColorDark, fontWeight: FontWeight.bold),
          ),
          leading: CircleAvatar(
            backgroundColor: cardColor,
            radius: 18,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Image.asset('assets/Images/Png/objectId_13.png'),
            ),
          ),
          subtitle: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: event.onTime,
                    style: const TextStyle(color: Colors.green)
                  ),
                  const TextSpan(
                    text: ' - ',
                    style: TextStyle(color: Colors.black)
                  ),
                  TextSpan(
                      text: event.offTime,
                      style: const TextStyle(color: Colors.red)
                  ),
                ]
              )
          ),
          trailing: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Duration", style: TextStyle(color: Colors.grey),),
                Text(event.duration, style: const TextStyle(fontWeight: FontWeight.bold),)
              ],
            ),
          ),
        ),
        const Divider(thickness: 0.3,)
      ],
    );
  }
}
