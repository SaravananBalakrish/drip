import 'package:flutter/cupertino.dart';
import 'package:oro_drip_irrigation/views/customer/controller_settings/widgets/parameter_selection_menu.dart';
import 'package:oro_drip_irrigation/views/customer/controller_settings/widgets/reason_selection_menu.dart';
import 'package:oro_drip_irrigation/views/customer/controller_settings/widgets/threshold_selector_widget.dart';
import 'package:oro_drip_irrigation/views/customer/controller_settings/widgets/value_selector_widget.dart';

import '../../../../view_models/customer/condition_library_view_model.dart';
import 'component_selection_menu.dart';
import 'condition_labels_column.dart';
import 'delay_time_selection_menu.dart';

Widget buildSelectionMenus(
    BuildContext context, ConditionLibraryViewModel vm, int index) {
  return Padding(
    padding: const EdgeInsets.only(left: 8, top: 8),
    child: Row(
      children: [
        const ConditionLabelsColumn(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ComponentSelectionMenu(index: index, vm: vm),
              const SizedBox(height: 5),
              ParameterSelectionMenu(index: index, vm: vm),
              const SizedBox(height: 5),
              Row(
                children: [
                  ThresholdSelectorWidget(index: index, vm: vm),
                  const SizedBox(width: 5),
                  ValueSelectorWidget(index: index, vm: vm),
                ],
              ),
              const SizedBox(height: 5),
              ReasonSelectionMenu(index: index, vm: vm),
              const SizedBox(height: 5),
              DelayTimeSelectionMenu(index: index, vm: vm),
            ],
          ),
        ),
      ],
    ),
  );
}