import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/utils/Theme/agritel_theme.dart';
import 'package:provider/provider.dart';
import '../../../../StateManagement/mqtt_payload_provider.dart';
import '../../../../models/customer/site_model.dart';
import '../../../../modules/IrrigationProgram/view/program_library.dart';
import '../../../../providers/user_provider.dart';
import '../../../../repository/repository.dart';
import '../../../../services/http_service.dart';
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
        .where((rly) => rly.sNo.toString().startsWith('13.'))
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
          height: MediaQuery.of(context).size.height,
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

              /// Node Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: vm.nodeList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.45,
                  ),
                  itemBuilder: (context, index) {
                    final selectedValves = nodeValveSelections[index] ?? <int>{};
                    return NodeCard(
                      node: vm.nodeList[index],
                      customerId: widget.customerId,
                      controllerId: widget.controllerId,
                      modelId: widget.modelId,
                      selectedValveIndices: selectedValves,
                      onValveSelectionChanged: (newSelection) {
                        _onValveSelectionChanged(index, newSelection);
                      },
                    );
                  },
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
                label: 'Open all',
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
                label: 'Close all',
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

class NodeCard extends StatelessWidget {
  final NodeListModel node;
  final int customerId, controllerId, modelId;

  /// Indices (within this node's filtered valve list) that are currently
  /// selected. Owned by the parent (_OmsLineState) — this widget is now
  /// stateless with respect to selection so the parent always has an
  /// accurate, real-time picture of every valve pick.
  final Set<int> selectedValveIndices;

  /// Called with the FULL updated set of selected valve indices for this
  /// node whenever the user toggles the node checkbox or any single valve.
  final ValueChanged<Set<int>> onValveSelectionChanged;

  const NodeCard({
    super.key,
    required this.node,
    required this.customerId,
    required this.controllerId,
    required this.modelId,
    required this.selectedValveIndices,
    required this.onValveSelectionChanged,
  });

  List<RelayStatus> get _valves {

    final allValves = node.rlyStatus.where((rly) {
      final sNo = rly.sNo.toString();
      return sNo.startsWith('45.') || sNo.startsWith('13.');
    }).toList();

    allValves.sort((a, b) {
      final aSNo = a.sNo.toString();
      final bSNo = b.sNo.toString();

      // Check if valve starts with '45.'
      final aIsFlowControl = aSNo.startsWith('45.');
      final bIsFlowControl = bSNo.startsWith('45.');

      // Flow control valves (45.) come first
      if (aIsFlowControl && !bIsFlowControl) return -1;
      if (!aIsFlowControl && bIsFlowControl) return 1;

      // If both are same type, sort by sNo numerically
      return aSNo.compareTo(bSNo);
    });

    return allValves;
  }

  bool get _isNodeFullySelected =>
      _valves.isNotEmpty && selectedValveIndices.length == _valves.length;

  @override
  Widget build(BuildContext context) {
    final valves = _valves;
    final isSelected = _isNodeFullySelected;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 2,
          )
        ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header with Checkbox and Program Name
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Node Checkbox: checking/unchecking toggles ALL valves.
              GestureDetector(
                onTap: () {
                  if (isSelected) {
                    onValveSelectionChanged(<int>{});
                  } else {
                    onValveSelectionChanged(
                      valves.asMap().keys.toSet(),
                    );
                  }
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade400,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.deviceName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      'Program: Morning cycle',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Live',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 8),

          /// Device ID Row
          Row(
            children: [
              Expanded(
                child: Text(
                  node.deviceId,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                node.lastFeedbackReceivedTime,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const Divider(color: Colors.black12),

          /// Voltage Cards
          Row(
            children: [
              Expanded(
                child: _infoCard(
                  'Signal',
                  '0',
                  true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _infoCard(
                  'Solar',
                  '${node.sVolt} V',
                  false,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _infoCard(
                  'Battery',
                  '${node.batVolt} V',
                  false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          /// Valves Section with Checkboxes
          if (valves.isNotEmpty) ...[
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (selectedValveIndices.length == valves.length) {
                      onValveSelectionChanged(<int>{});
                    } else {
                      onValveSelectionChanged(valves.asMap().keys.toSet());
                    }
                  },
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: selectedValveIndices.length == valves.length && valves.isNotEmpty
                          ? Colors.blue
                          : Colors.transparent,
                      border: Border.all(
                        color: selectedValveIndices.length == valves.length && valves.isNotEmpty
                            ? Colors.blue
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: selectedValveIndices.length == valves.length && valves.isNotEmpty
                        ? const Icon(Icons.check, size: 10, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${selectedValveIndices.length} of ${valves.length} selected',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: valves.asMap().entries.map<Widget>((entry) {
                final index = entry.key;
                final valve = entry.value;
                return _ValveTile(
                  valve: valve,
                  isSelected: selectedValveIndices.contains(index),
                  onTap: () {
                    final updated = Set<int>.from(selectedValveIndices);
                    if (updated.contains(index)) {
                      updated.remove(index);
                    } else {
                      updated.add(index);
                    }
                    onValveSelectionChanged(updated);
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value, bool isSignal) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 0.7,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const Spacer(),
          Text(
            isSignal ? '$value %' : '$value Volts',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
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
          child: Container(
            width: 75,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade50 : _relayColor(currentStatus),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Checkbox for individual valve
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Valve Icon
                    SizedBox(
                      width: 45,
                      height: 38,
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
                          // Checkbox at top-right corner
                          Positioned(
                            top: -3,
                            right: -14,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue : Colors.white,
                                border: Border.all(
                                  color: isSelected ? Colors.blue : Colors.grey.shade400,
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
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    valve.name.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blue.shade500 : Colors.black87,
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

  Color _relayColor(int? status) {
    switch (status) {
      case 1:
        return Colors.green.shade50;
      case 2:
        return Colors.orange.shade50;
      case 3:
        return Colors.red.shade50;
      default:
        return Colors.grey.shade200;
    }
  }
}