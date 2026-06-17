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
  // Track selected nodes
  Set<int> selectedNodeIndices = {};

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
                    childAspectRatio: 1.4,
                  ),
                  itemBuilder: (context, index) {
                    return NodeCard(
                      node: vm.nodeList[index],
                      customerId: widget.customerId,
                      controllerId: widget.controllerId,
                      modelId: widget.modelId,
                      isSelected: selectedNodeIndices.contains(index),
                      onSelectionChanged: (isSelected) {
                        setState(() {
                          if (isSelected) {
                            selectedNodeIndices.add(index);
                          } else {
                            selectedNodeIndices.remove(index);
                          }
                        });
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
    final selectedCount = selectedNodeIndices.length;
    final totalNodes = vm.nodeList.length;

    // Get names of selected nodes (first 3)
    String selectedNames = '';
    if (selectedCount > 0) {
      final names = selectedNodeIndices
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
                label: 'Start all',
                icon: Icons.play_arrow,
                onPressed: selectedCount > 0 ? () {
                  _onStartAll(vm);
                } : null,
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                label: 'Stop all',
                icon: Icons.stop,
                onPressed: selectedCount > 0 ? () {
                  _onStopAll(vm);
                } : null,
                color: Colors.red,
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                label: 'Apply program',
                icon: Icons.playlist_add_check,
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
    if (status == 'Program created' && mounted) print(status);
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

  void _onStartAll(NodeListViewModel vm) {
    print('Start all selected nodes: $selectedNodeIndices');
    // Implement your start logic here
    for (var index in selectedNodeIndices) {
      final node = vm.nodeList[index];
      // Send start command
      print('Starting node: ${node.deviceName}');
    }
  }

  void _onStopAll(NodeListViewModel vm) {
    print('Stop all selected nodes: $selectedNodeIndices');
    // Implement your stop logic here
    for (var index in selectedNodeIndices) {
      final node = vm.nodeList[index];
      // Send stop command
      print('Stopping node: ${node.deviceName}');
    }
  }

  void _onApplyProgram(NodeListViewModel vm) {
    print('Apply program to selected nodes: $selectedNodeIndices');
    // Implement your apply program logic here
    // Show dialog or navigate to program selection
  }
}

class NodeCard extends StatefulWidget {
  final NodeListModel node;
  final int customerId, controllerId, modelId;
  final bool isSelected;
  final Function(bool) onSelectionChanged;

  const NodeCard({
    super.key,
    required this.node,
    required this.customerId,
    required this.controllerId,
    required this.modelId,
    required this.isSelected,
    required this.onSelectionChanged,
  });

  @override
  State<NodeCard> createState() => _NodeCardState();
}

class _NodeCardState extends State<NodeCard> {
  // Track selected valves for this node
  Set<int> selectedValves = {};

  @override
  void initState() {
    super.initState();
    // If node is selected, select all valves
    if (widget.isSelected) {
      final valves = widget.node.rlyStatus
          .where((rly) => rly.sNo.toString().startsWith('13.'))
          .toList();
      selectedValves = valves.asMap().entries
          .map((entry) => entry.key)
          .toSet();
    }
  }

  @override
  void didUpdateWidget(NodeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      final valves = widget.node.rlyStatus
          .where((rly) => rly.sNo.toString().startsWith('13.'))
          .toList();
      if (widget.isSelected) {
        // Select all valves when node is selected
        selectedValves = valves.asMap().entries
            .map((entry) => entry.key)
            .toSet();
      } else {
        // Deselect all valves when node is deselected
        selectedValves.clear();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final valves = widget.node.rlyStatus
        .where((rly) => rly.sNo.toString().startsWith('13.'))
        .toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
          width: widget.isSelected ? 2 : 1,
        ),
        boxShadow: widget.isSelected
            ? [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
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
              // Node Checkbox
              GestureDetector(
                onTap: () {
                  widget.onSelectionChanged(!widget.isSelected);
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: widget.isSelected ? Colors.blue : Colors.transparent,
                    border: Border.all(
                      color: widget.isSelected ? Colors.blue : Colors.grey.shade400,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: widget.isSelected
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
                      widget.node.deviceName,
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
                  widget.node.deviceId,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                widget.node.lastFeedbackReceivedTime,
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
                  '${widget.node.sVolt} V',
                  false,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _infoCard(
                  'Battery',
                  '${widget.node.batVolt} V',
                  false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          /// Valves Section with Checkboxes
          if (valves.isNotEmpty) ...[
            Row(
              children: [
                // Select all checkbox for valves
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selectedValves.length == valves.length) {
                        selectedValves.clear();
                      } else {
                        selectedValves = valves.asMap().entries
                            .map((entry) => entry.key)
                            .toSet();
                      }
                      // Update node selection state
                      if (selectedValves.length == valves.length && !widget.isSelected) {
                        widget.onSelectionChanged(true);
                      } else if (selectedValves.length < valves.length && widget.isSelected) {
                        widget.onSelectionChanged(false);
                      }
                    });
                  },
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: selectedValves.length == valves.length && valves.isNotEmpty
                          ? Colors.blue
                          : Colors.transparent,
                      border: Border.all(
                        color: selectedValves.length == valves.length && valves.isNotEmpty
                            ? Colors.blue
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: selectedValves.length == valves.length && valves.isNotEmpty
                        ? const Icon(Icons.check, size: 10, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${selectedValves.length} of ${valves.length} selected',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: valves.asMap().entries.map<Widget>((entry) {
                final index = entry.key;
                final valve = entry.value;
                return _buildValveWithCheckbox(valve, index);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildValveWithCheckbox(RelayStatus valve, int index) {
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
        bool isSelected = selectedValves.contains(index);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedValves.remove(index);
              } else {
                selectedValves.add(index);
              }
              // Update node selection state
              final valves = widget.node.rlyStatus
                  .where((rly) => rly.sNo.toString().startsWith('13.'))
                  .toList();
              if (selectedValves.length == valves.length && !widget.isSelected) {
                widget.onSelectionChanged(true);
              } else if (selectedValves.length < valves.length && widget.isSelected) {
                widget.onSelectionChanged(false);
              }
            });
          },
          child: Container(
            width: 70,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.shade50
                  : _relayColor(currentStatus),
              borderRadius: BorderRadius.circular(8),
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
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey.shade400,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 10, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 4),
                    // Valve Icon
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: isOn
                          ? Image.asset(
                        'assets/gif/m_valve_green.gif',
                        fit: BoxFit.contain,
                      )
                          : Image.asset(
                        'assets/png/m_valve_grey.png',
                        color: valveColor,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                Text(
                  valve.name.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

  Color _relayColor(int? status) {
    switch (status) {
      case 1:
        return Colors.green.shade100;
      case 0:
        return Colors.grey.shade200;
      case 2:
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}


/*class OmsLine extends StatefulWidget {
  final List<NodeListModel> nodes;
  final int customerId, controllerId, modelId;
  final String deviceId;

  const OmsLine({
    super.key,
    required this.customerId,
    required this.controllerId,
    required this.modelId,
    required this.deviceId,
    required this.nodes,
  });

  @override
  State<OmsLine> createState() => _OmsLineState();
}

class _OmsLineState extends State<OmsLine> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NodeListViewModel(context, Repository(HttpService()), widget.nodes),
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
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: vm.nodeList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                  ),
                  itemBuilder: (context, index) {
                    return NodeCard(
                      node: vm.nodeList[index],
                      customerId: widget.customerId,
                      controllerId: widget.controllerId,
                      modelId: widget.modelId,
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
}

class NodeCard extends StatefulWidget {
  final NodeListModel node;
  final int customerId, controllerId, modelId;

  const NodeCard({
    super.key,
    required this.node,
    required this.customerId,
    required this.controllerId,
    required this.modelId,
  });

  @override
  State<NodeCard> createState() => _NodeCardState();
}

class _NodeCardState extends State<NodeCard> {
  // Track selected valves for this node
  Set<int> selectedValves = {};
  bool isNodeSelected = false;

  @override
  Widget build(BuildContext context) {
    final valves = widget.node.rlyStatus
        .where((rly) => rly.sNo.toString().startsWith('13.'))
        .toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isNodeSelected ? Colors.blue.shade300 : Colors.grey.shade300,
          width: isNodeSelected ? 2 : 1,
        ),
        boxShadow: isNodeSelected
            ? [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
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
              // Node Checkbox
              GestureDetector(
                onTap: () {
                  setState(() {
                    isNodeSelected = !isNodeSelected;
                    if (isNodeSelected) {
                      // Select all valves
                      selectedValves = valves.asMap().entries
                          .map((entry) => entry.key)
                          .toSet();
                    } else {
                      // Deselect all valves
                      selectedValves.clear();
                    }
                  });
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isNodeSelected ? Colors.blue : Colors.transparent,
                    border: Border.all(
                      color: isNodeSelected ? Colors.blue : Colors.grey.shade400,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: isNodeSelected
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
                      widget.node.deviceName,
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
                  widget.node.deviceId,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                widget.node.lastFeedbackReceivedTime,
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
                  '${widget.node.sVolt} V',
                  false,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _infoCard(
                  'Battery',
                  '${widget.node.batVolt} V',
                  false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          /// Valves Section with Checkboxes
          if (valves.isNotEmpty) ...[
            Row(
              children: [
                // Select all checkbox for valves
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selectedValves.length == valves.length) {
                        selectedValves.clear();
                      } else {
                        selectedValves = valves.asMap().entries
                            .map((entry) => entry.key)
                            .toSet();
                      }
                      // Update node selection state
                      isNodeSelected = selectedValves.length == valves.length;
                    });
                  },
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: selectedValves.length == valves.length && valves.isNotEmpty
                          ? Colors.blue
                          : Colors.transparent,
                      border: Border.all(
                        color: selectedValves.length == valves.length && valves.isNotEmpty
                            ? Colors.blue
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: selectedValves.length == valves.length && valves.isNotEmpty
                        ? const Icon(Icons.check, size: 10, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${selectedValves.length} of ${valves.length} selected',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Configure node',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: valves.asMap().entries.map<Widget>((entry) {
                final index = entry.key;
                final valve = entry.value;
                return _buildValveWithCheckbox(valve, index);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTopHeader(NodeListViewModel vm) {
    final selectedCount = selectedNodeIndices.length;
    final totalNodes = vm.nodeList.length;

    // Get names of selected nodes (first 3)
    String selectedNames = '';
    if (selectedCount > 0) {
      final names = selectedNodeIndices
          .map((index) => vm.nodeList[index].deviceName)
          .take(3)
          .join(', ');
      selectedNames = selectedCount > 3 ? '$names, +${selectedCount - 3} more' : names;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  ? '$selectedCount nodes selected ($selectedNames)'
                  : '${totalNodes} nodes available',
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
                label: 'Start all',
                icon: Icons.play_arrow,
                onPressed: selectedCount > 0 ? () {
                  // Handle start all
                  _onStartAll(vm);
                } : null,
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                label: 'Stop all',
                icon: Icons.stop,
                onPressed: selectedCount > 0 ? () {
                  // Handle stop all
                  _onStopAll(vm);
                } : null,
                color: Colors.red,
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                label: 'Apply program',
                icon: Icons.playlist_add_check,
                onPressed: selectedCount > 0 ? () {
                  // Handle apply program
                  _onApplyProgram(vm);
                } : null,
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValveWithCheckbox(RelayStatus valve, int index) {
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
        bool isSelected = selectedValves.contains(index);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedValves.remove(index);
              } else {
                selectedValves.add(index);
              }
              // Update node selection state
              final valves = widget.node.rlyStatus
                  .where((rly) => rly.sNo.toString().startsWith('13.'))
                  .toList();
              isNodeSelected = selectedValves.length == valves.length;
            });
          },
          child: Container(
            width: 60,
            height: 65,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.shade50
                  : _relayColor(currentStatus),
              borderRadius: BorderRadius.circular(8),
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
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey.shade400,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 10, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 4),
                    // Valve Icon
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: isOn
                          ? Image.asset(
                        'assets/gif/m_valve_green.gif',
                        fit: BoxFit.contain,
                      )
                          : Image.asset(
                        'assets/png/m_valve_grey.png',
                        color: valveColor,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'V${index + 1}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

  Color _relayColor(int? status) {
    switch (status) {
      case 1:
        return Colors.green.shade100;
      case 0:
        return Colors.grey.shade200;
      case 2:
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}*/

/*
class OmsLine extends StatefulWidget {
  final List<NodeListModel> nodes;
  final int customerId, controllerId, modelId;
  final String deviceId;

  const OmsLine({
    super.key,
    required this.customerId,
    required this.controllerId,
    required this.modelId,
    required this.deviceId,
    required this.nodes,
  });

  @override
  State<OmsLine> createState() => _OmsLineState();
}

class _OmsLineState extends State<OmsLine> {

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (_) => NodeListViewModel(context, Repository(HttpService()), widget.nodes),
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

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: vm.nodeList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemBuilder: (context, index) {
                    return NodeCard(node: vm.nodeList[index], customerId: widget.customerId,
                      controllerId: widget.customerId, modelId: widget.customerId);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class NodeCard extends StatelessWidget {
  final NodeListModel node;
  final int customerId, controllerId, modelId;

  const NodeCard({
    super.key,
    required this.node,
    required this.customerId,
    required this.controllerId,
    required this.modelId,
  });

  @override
  Widget build(BuildContext context) {

    final valves = node.rlyStatus.where((rly) => rly.sNo.toString().startsWith('13.')).toList();

    final pressureSensors = node.rlyStatus.where((rly) => rly.sNo.toString().startsWith('24.')).toList();

    final allValveWidgets = [
      ...valveList(
        valves: valves,
        customerId: customerId,
        controllerId: controllerId,
        modelId: modelId,
      ),

    ];

    final allItems = [
      ...allValveWidgets,
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              Expanded(
                child: Text(
                  node.deviceName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
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
                  ),
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  node.deviceId,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              Text(
                node.lastFeedbackReceivedTime,
                style: const TextStyle(
                  color: Colors.grey,
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
                  '0', true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _infoCard(
                  'Solar',
                  '${node.sVolt} V', false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _infoCard(
                  'Battery',
                  '${node.batVolt} V', false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          /// Valves Section (displayed second)
          if (valves.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allItems.asMap().entries.map<Widget>((entry) {
                final item = entry.value;
                return item;

              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

        ],
      ),
    );
  }

  List<Widget> valveList({
    required List<RelayStatus> valves,
    required int customerId,
    required int controllerId,
    required int modelId,
  }) {
    return mapWidgets(
      list: valves,
      builder: (valve, index) {
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

            return Container(
              width: 70,
              height: 55,
              decoration: BoxDecoration(
                color: _relayColor(currentStatus),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Valve Icon
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: isOn
                        ? Image.asset(
                      'assets/gif/m_valve_green.gif',
                      fit: BoxFit.contain,
                    )
                        : Image.asset(
                      'assets/png/m_valve_grey.png',
                      color: valveColor,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Text(
                    valve.name.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
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
          Text(title, style: const TextStyle(
            fontSize: 12,
            color: Colors.grey
          )),
          const Spacer(),
          Text(
            isSignal ?
            '$value %' : '$value Volts',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Color _relayColor(int? status) {
    switch (status) {
      case 1:
        return Colors.green.shade100;
      case 0:
        return Colors.grey.shade200;
      case 2:
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}*/
