import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/utils/Theme/agritel_theme.dart';
import 'package:provider/provider.dart';
import '../../../../StateManagement/mqtt_payload_provider.dart';
import '../../../../models/customer/site_model.dart';
import '../../../../modules/IrrigationProgram/view/program_library.dart';
import '../../../../providers/user_provider.dart';
import '../../../../repository/repository.dart';
import '../../../../services/http_service.dart';
import '../../../../utils/my_function.dart';
import '../../../../view_models/customer/node_list_view_model.dart';

class OmsLine extends StatefulWidget {
  final MasterControllerModel master;
  final int customerId, controllerId, modelId, groupId;
  final String deviceId;

  const OmsLine({
    super.key,
    required this.customerId,
    required this.controllerId,
    required this.modelId,
    required this.deviceId,
    required this.master,
    required this.groupId,
  });

  @override
  State<OmsLine> createState() => _OmsLineState();
}

class _OmsLineState extends State<OmsLine> {
  /// Node index -> set of selected valve indices (within that node's
  /// filtered valve list). A node index appears here the moment ANY of its
  /// valves is checked, even if not all of them are.
  final Map<int, Set<int>> nodeValveSelections = {};

  /// Node indices where the node checkbox itself is "fully selected"
  /// (i.e. all of that node's valves are selected). This drives whether
  /// "Apply program" is enabled.
  ///
  /// Takes `vm` explicitly rather than reading it via `context.read` —
  /// `_OmsLineState`'s own `context` sits ABOVE the `ChangeNotifierProvider`
  /// created in `build()`, so `context.read<NodeListViewModel>()` from here
  /// would throw a ProviderNotFoundError. Callers already have `vm` from
  /// the `Consumer2` builder, so we just pass it down.
  Set<int> fullySelectedNodeIndices(NodeListViewModel vm) {
    return nodeValveSelections.entries
        .where((e) => e.value.isNotEmpty)
        .where((e) => _isNodeFullySelected(vm, e.key, e.value))
        .map((e) => e.key)
        .toSet();
  }

  /// True if there is at least one valve selected anywhere, regardless of
  /// whether its parent node counts as "fully selected".
  bool get hasAnyValveSelected {
    return nodeValveSelections.values.any((valves) => valves.isNotEmpty);
  }

  bool _isNodeFullySelected(
      NodeListViewModel vm, int nodeIndex, Set<int> selectedValveIdx) {
    final node = vm.nodeList[nodeIndex];

    final totalValves = node.rlyStatus
        .where((rly) {
      final sNo = rly.sNo.toString();
      return sNo.startsWith('13.') || sNo.startsWith('45.');
    })
        .length;

    return totalValves > 0 && selectedValveIdx.length == totalValves;
  }

  void _onValveSelectionChanged(int nodeIndex, Set<int> selectedValveIdx) {
    setState(() {
      if (selectedValveIdx.isEmpty) {
        nodeValveSelections.remove(nodeIndex);
      } else {
        nodeValveSelections[nodeIndex] = selectedValveIdx;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NodeListViewModel(context, Repository(HttpService()), widget.master.nodeList),
      child: nodeListBody(context),
    );
  }

  Widget nodeListBody(BuildContext context) {
    return Consumer2<NodeListViewModel, MqttPayloadProvider>(
      builder: (context, vm, mqttProvider, _) {
        final nodeLiveMessage = mqttProvider.nodeLiveMessage;
        final outputOnOffPayload = mqttProvider.outputOnOffPayload;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (vm.shouldUpdate(nodeLiveMessage, outputOnOffPayload)) {
            vm.onLivePayloadReceived(
              List.from(nodeLiveMessage),
              List.from(outputOnOffPayload),
            );
          }
        });

        return SizedBox(
          height: (vm.nodeList.length * 60) + 150,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              /// Top Header Bar
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                child: _buildTopHeader(vm, widget.master, widget.controllerId,
                    widget.deviceId, widget.customerId, widget.groupId),
              ),
              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  height: (vm.nodeList.length * 60) + 40,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 3, right: 3, top: 5),
                    child: DataTable2(
                      columnSpacing: 12,
                      horizontalMargin: 12,
                      minWidth: 800,
                      headingRowHeight: 30,
                      dataRowHeight: 60,
                      headingRowColor: WidgetStateProperty.all(primary.withValues(alpha: 0.3)),
                      border: TableBorder(
                        horizontalInside: BorderSide(
                          color: Colors.grey.shade50,
                        ),
                      ),
                      columns: const [
                        DataColumn2(
                          label: Center(child: Text('Select', style: TextStyle(fontWeight: FontWeight.bold))),
                          fixedWidth: 50,
                        ),
                        DataColumn2(
                          label: Text('Node', style: TextStyle(fontWeight: FontWeight.bold)),
                          fixedWidth: 200,
                        ),
                        DataColumn2(
                          label: Text('Device ID', style: TextStyle(fontWeight: FontWeight.bold)),
                          fixedWidth: 130,
                        ),
                        DataColumn2(
                          label: Center(child: Text('Signal', style: TextStyle(fontWeight: FontWeight.bold))),
                          fixedWidth: 60,
                        ),
                        DataColumn2(
                          label: Center(child: Text('Solar', style: TextStyle(fontWeight: FontWeight.bold))),
                          fixedWidth: 60,
                        ),
                        DataColumn2(
                          label: Center(child: Text('Battery', style: TextStyle(fontWeight: FontWeight.bold))),
                          fixedWidth: 60,
                        ),
                        DataColumn2(
                          label: Center(child: Text('Sensor', style: TextStyle(fontWeight: FontWeight.bold))),
                          fixedWidth: 140,
                        ),
                        DataColumn2(
                          label: Text('Valves', style: TextStyle(fontWeight: FontWeight.bold)),
                          size: ColumnSize.L,
                        ),
                      ],
                      rows: List.generate(
                        vm.nodeList.length, (index) {

                        final node = vm.nodeList[index];

                        final sensors = node.rlyStatus.where((rly) {
                          final sNo = rly.sNo.toString();
                          return sNo.startsWith('24.') || sNo.startsWith('46.');
                        }).toList();

                        final selectedValves = nodeValveSelections[index] ?? <int>{};

                        final valves = node.rlyStatus.where((rly) {
                          final sNo = rly.sNo.toString();
                          return sNo.startsWith('45.') || sNo.startsWith('13.');
                        }).toList();

                        valves.sort((a, b) {
                          final aSNo = a.sNo.toString();
                          final bSNo = b.sNo.toString();

                          final aIsFlowControl = aSNo.startsWith('45.');
                          final bIsFlowControl = bSNo.startsWith('45.');

                          if (aIsFlowControl && !bIsFlowControl) return -1;
                          if (!aIsFlowControl && bIsFlowControl) return 1;

                          return aSNo.compareTo(bSNo);
                        });

                        final isNodeFullySelected = selectedValves.length == valves.length && valves.isNotEmpty;


                          return DataRow2(
                            selected: isNodeFullySelected,
                            cells: [

                              // In the checkbox cell
                              DataCell(
                                Center(
                                  child: Checkbox(
                                    value: isNodeFullySelected,
                                    onChanged: (_) => _toggleNodeSelection(vm, index),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ),

                              DataCell(
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      node.deviceName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      node.lastFeedbackReceivedTime,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              DataCell(
                                Text(node.deviceId),
                              ),

                              const DataCell(
                                Center(child: Text('0%')),
                              ),

                              DataCell(
                                Center(child: Text('${node.sVolt} V')),
                              ),

                              DataCell(
                                Center(child: Text('${node.batVolt} V')),
                              ),

                              DataCell(
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: sensors.asMap().entries.map((entry) {
                                    final sensor = entry.value;

                                    return sensorWidget(sensor);
                                  }).toList(),
                                ),
                              ),

                              DataCell(
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: valves.asMap().entries.map((entry) {
                                    final valveIndex = entry.key;
                                    final valve = entry.value;

                                    return _ValveTile(
                                      valve: valve,
                                      isSelected: selectedValves.contains(valveIndex),
                                      onTap: () {
                                        final updated = Set<int>.from(selectedValves);

                                        if (updated.contains(valveIndex)) {
                                          updated.remove(valveIndex);
                                        } else {
                                          updated.add(valveIndex);
                                        }

                                        _onValveSelectionChanged(index, updated);
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildTopHeader(NodeListViewModel vm, MasterControllerModel cMaster,
      int controllerId, String deviceId, int customerId, int groupId) {
    final fullNodeSelection = fullySelectedNodeIndices(vm);
    final anyValveSelected = hasAnyValveSelected;

    final selectedCount = fullNodeSelection.length;
    final totalNodes = vm.nodeList.length;

    // Get names of fully-selected nodes (first 3) for the header label.
    String selectedNames = '';
    if (selectedCount > 0) {
      final names = fullNodeSelection
          .map((index) => vm.nodeList[index].deviceName)
          .take(3)
          .join(', ');
      selectedNames = selectedCount > 3 ? '$names, +${selectedCount - 3} more' : names;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          /// Selection Info
          Expanded(
            flex: 2,
            child: Text(
              selectedCount > 0
                  ? '$selectedCount node selected ($selectedNames)'
                  : '$totalNodes nodes available',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selectedCount > 0 ? Colors.black87 : Colors.grey.shade500,
              ),
            ),
          ),
          const Spacer(),

          /// Action Buttons
          Row(
            children: [
              _buildActionButton(
                label: 'Open',
                icon: Icons.play_arrow,
                // Enabled if ANY valve is selected anywhere (node need not
                // be fully selected).
                onPressed: anyValveSelected ? () {
                  _onStartAll(vm);
                } : null,
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                label: 'Close',
                icon: Icons.stop,
                onPressed: anyValveSelected ? () {
                  _onStopAll(vm);
                } : null,
                color: Colors.red,
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                label: 'Apply program',
                icon: Icons.playlist_add_check,
                // Enabled ONLY when at least one node is fully selected
                // (every valve under it checked) — partial valve picks
                // don't count.
                onPressed: selectedCount > 0 ? () {
                  _onApplyProgram(vm);
                } : null,
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                label: 'New program',
                icon: Icons.add,
                onPressed: () {

                  final loggedInUser = context.read<UserProvider>().loggedInUser;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProgramLibraryScreenNew(
                        customerId: customerId,
                        controllerId: controllerId,
                        deviceId: deviceId,
                        userId: loggedInUser.id,
                        groupId: groupId,
                        categoryId: cMaster.categoryId,
                        modelId: cMaster.modelId,
                        deviceName: cMaster.deviceName,
                        categoryName: cMaster.categoryName,
                        callbackFunction: callbackFunction,
                        nodeList: vm.nodeList,
                      ),
                    ),
                  );
                },
                color: primary,
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget sensorWidget(RelayStatus sensor) {

    return Selector<MqttPayloadProvider, String?>(
      selector: (_, provider) => provider.getSensorUpdatedValve(sensor.sNo.toString()),
      builder: (_, status, __) {
        String sensorVal = '0';
        final statusParts = status?.split(',') ?? [];
        if (statusParts.isNotEmpty) {
          sensorVal = statusParts[1];
          print('sensorVal:$sensorVal');
        }

        final sNo = sensor.sNo?.toString() ?? '';
        String sensorType = sNo.startsWith('24.') ? 'Pressure Sensor' : 'Water Meter';
        String imagePath = sNo.startsWith('24.') ? 'assets/png/pressure_sensor.png'
            :'assets/png/water_meter.png';

        return SizedBox(
          width: 60,
          height: 60,
          child: Column(
            children: [
              const SizedBox(height: 3),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset(imagePath, width: 32, height: 32),
                  Positioned(
                    top: 21,
                    right: -5,
                    child: _unitBox(context, sensorVal, sensorType),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                sensor.name.toString(),
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _unitBox(BuildContext context, String sensorVal, String sensorType) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey, width: 0.5),
      ),
      child: Text(
        MyFunction().getUnitByParameter(context, sensorType, sensorVal.toString()) ??
            '',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  void callbackFunction(String status) {
    if (status == 'Program created' && mounted) debugPrint(status);
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed != null ? color : Colors.grey.shade300,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    );
  }

  void _toggleNodeSelection(NodeListViewModel vm, int nodeIndex) {
    final node = vm.nodeList[nodeIndex];

    // Get all valves for this node (BOTH 13. and 45. series)
    final valves = node.rlyStatus
        .where((rly) {
      final sNo = rly.sNo.toString();
      return sNo.startsWith('13.') || sNo.startsWith('45.');
    })
        .toList();

    // Get current selection for this node
    final currentSelection = nodeValveSelections[nodeIndex] ?? <int>{};

    // Check if all valves are currently selected
    final isFullySelected = currentSelection.length == valves.length && valves.isNotEmpty;

    if (isFullySelected) {
      // If fully selected, deselect ALL valves
      _onValveSelectionChanged(nodeIndex, <int>{});
    } else {
      // If not fully selected, select ALL valves
      _onValveSelectionChanged(nodeIndex, valves.asMap().keys.toSet());
    }
  }

  /// Builds a flat list of (nodeId, valveId) pairs for every currently
  /// selected valve across all nodes. nodeId is the node's deviceId and
  /// valveId is the valve's sNo — adjust these two lines if your backend
  /// expects different identifiers (e.g. a numeric node id field instead
  /// of deviceId).
  List<Map<String, dynamic>> _collectSelectedNodeValveIds(NodeListViewModel vm) {
    final List<Map<String, dynamic>> result = [];

    nodeValveSelections.forEach((nodeIndex, valveIdxSet) {
      if (valveIdxSet.isEmpty) return;
      final node = vm.nodeList[nodeIndex];
      final valves = node.rlyStatus
          .where((rly) => rly.sNo.toString().startsWith('13.'))
          .toList();

      for (final valveIdx in valveIdxSet) {
        if (valveIdx < 0 || valveIdx >= valves.length) continue;
        final valve = valves[valveIdx];
        result.add({
          'nodeId': node.deviceId,
          'valveId': valve.sNo,
        });
      }
    });

    return result;
  }

  void _onStartAll(NodeListViewModel vm) {
    final targets = _collectSelectedNodeValveIds(vm);
    debugPrint('Start all selected valves: $targets');
    for (final t in targets) {
      // Send start command using t['nodeId'] and t['valveId'].
      debugPrint('Starting nodeId=${t['nodeId']} valveId=${t['valveId']}');
    }
  }

  void _onStopAll(NodeListViewModel vm) {
    final targets = _collectSelectedNodeValveIds(vm);
    debugPrint('Stop all selected valves: $targets');
    for (final t in targets) {
      // Send stop command using t['nodeId'] and t['valveId'].
      debugPrint('Stopping nodeId=${t['nodeId']} valveId=${t['valveId']}');
    }
  }

  void _onApplyProgram(NodeListViewModel vm) {
    final targets = fullySelectedNodeIndices(vm)
        .map((i) => vm.nodeList[i].deviceId)
        .toList();
    debugPrint('Apply program to fully-selected node ids: $targets');
    // Show dialog or navigate to program selection, passing `targets`.
  }
}

/// A single valve tile. Stateless: status/percent are derived live from
/// MqttPayloadProvider via Selector, selection state comes from the parent.
class _ValveTile extends StatelessWidget {
  final RelayStatus valve;
  final bool isSelected;
  final VoidCallback onTap;

  const _ValveTile({
    required this.valve,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<MqttPayloadProvider, String?>(
      selector: (_, provider) => provider.getValveOnOffStatus(
        double.parse(valve.sNo.toString()).toStringAsFixed(3),
      ),
      builder: (_, status, __) {
        int currentStatus = valve.status;
        int completePercent = 0;

        final statusParts = status?.split(',') ?? [];
        if (statusParts.isNotEmpty) {
          currentStatus = int.tryParse(statusParts[1]) ?? valve.status;
          completePercent = statusParts.length > 2
              ? int.parse(statusParts[2])
              : 0;
        }

        Color valveColor = _valveColor(currentStatus, completePercent);
        bool isOn = currentStatus == 1;

        // Check if it's a flow control valve (starts with '45.')
        final isFlowControl = valve.sNo.toString().startsWith('45.');

        return GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: 75,
            height: 60,
            //color: isSelected ? Colors.blue.shade50 : Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 55,
                  height: 35,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: isOn ? Image.asset(
                          isFlowControl
                              ? 'assets/png/m_flow_control_valve.png'
                              : 'assets/gif/m_valve_green.gif',
                          color: isFlowControl ? valveColor : null,
                          fit: BoxFit.contain,
                        )
                            : Image.asset(
                          isFlowControl
                              ? 'assets/png/m_flow_control_valve.png'
                              : 'assets/png/m_valve_grey.png',
                          color: valveColor,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        top: 14,
                        right: 45,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: isSelected ? primary : Colors.white,
                            border: Border.all(
                              color: isSelected ? primary : Colors.grey.shade400,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 10, color: Colors.white)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    valve.name.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? primary : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _valveColor(int status, int cPer) {
    if (status == 0 && cPer == 0) return Colors.black54;
    if (status == 0 && cPer == 100) return Colors.blue;
    if (status == 0 && cPer > 0 && cPer < 100) return Colors.yellow;
    if (status == 2) return Colors.orange;
    return Colors.red;
  }

}