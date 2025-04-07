import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_drip_irrigation/modules/Preferences/state_management/preference_provider.dart';
import 'package:oro_drip_irrigation/modules/Preferences/view/preference_main_screen.dart';
import 'package:provider/provider.dart';

class ValveSettings extends StatelessWidget {
  const ValveSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: context.read<PreferenceProvider>().valveSettings!.setting.length,
        itemBuilder: (BuildContext context, int index) {
          final item = context.read<PreferenceProvider>().valveSettings!.setting[index];
          return Column(
            children: [
              buildCustomListTileWidget(
                context: context,
                title: item.title,
                widgetType: item.widgetTypeId,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp('[^0-9.]')),
                  LengthLimitingTextInputFormatter(6),
                ],
                dataList: item.title.toUpperCase() == "SENSOR HEIGHT" ? ["20", "35"] : ["10", "12"],
                value: item.value,
                leading: CircleAvatar(child: Text('${index+1}'),),
                onValueChange: (newValue) => item.value = newValue,
                conditionToShow: true,
                hidden: item.hidden,
                enabled: true,
              ),
              if(index == context.read<PreferenceProvider>().valveSettings!.setting.length - 1)
                const SizedBox(height: 60),
            ],
          );
        },
      ),
    );
  }
}
