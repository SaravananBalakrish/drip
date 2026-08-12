import 'package:flutter/material.dart';
import '../model/service_request_model.dart';
import '../repository/service_request_repository.dart';
import '../widgets/service_request_constants.dart';
import '../widgets/service_request_shared.dart';
import '../widgets/service_request_sidebar.dart';
import '../widgets/service_request_timeline.dart';
import '../widgets/service_request_details.dart';
import '../widgets/service_request_dialogs.dart';

/// ---------------------------------------------------------------------
/// copyWith-style helpers for the (intentionally immutable) model classes,
/// kept here so service_request_model.dart doesn't need to change.
/// ---------------------------------------------------------------------
extension _ServiceRequestX on ServiceRequest {
  ServiceRequest withHandlers(List<TicketHandler> handlers) => ServiceRequest(
        ticketId: ticketId,
        name: name,
        mobileNumber: mobileNumber,
        issueDescription: issueDescription,
        issueType: issueType,
        issueStatus: issueStatus,
        ticketHandler: handlers,
        images: images,
      );
}

extension _TicketHandlerX on TicketHandler {
  TicketHandler withPersons(List<SalesPerson> persons) => TicketHandler(
        sNo: sNo,
        name: name,
        mobileNumber: mobileNumber,
        statusMessage: statusMessage,
        targetDates: targetDates,
        salesPerson: persons,
      );
}

class ServiceRequestScreen extends StatefulWidget {
  final int userId;
  final int controllerId;
  const ServiceRequestScreen({super.key, required this.userId, required this.controllerId});

  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen> {
  final _repository = ServiceRequestRepository();
  static const _filters = ['All', 'In progress', 'Closed'];

  List<ServiceRequest> _tickets = [];
  ServiceRequest? _selected;
  String _activeFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final tickets = await _repository.getTickets();
    setState(() {
      _tickets = tickets;
      _selected = tickets.isNotEmpty ? tickets.first : null;
    });
  }

  String _statusOf(ServiceRequest t) {
    final done = t.issueStatus.where((s) => s.value);
    if (done.isEmpty) return 'Pending';
    return done.any((s) => s.name == 'Ticket Closed') ? 'Closed' : 'In progress';
  }

  String _categoryOf(ServiceRequest t) {
    final type = t.issueType.where((x) => x.value).map((x) => x.type);
    return type.isNotEmpty ? type.first : 'General';
  }

  List<ServiceRequest> get _filtered => _activeFilter == 'All'
      ? _tickets
      : _tickets.where((t) => _statusOf(t) == _activeFilter).toList();

  void _replaceSelected(ServiceRequest updated) {
    setState(() {
      final idx = _tickets.indexWhere((t) => t.ticketId == updated.ticketId);
      if (idx != -1) _tickets[idx] = updated;
      _selected = updated;
    });
  }

  void _addHandler(TicketHandler handler) {
    if (_selected == null) return;
    final handlers = [..._selected!.ticketHandler, handler];
    _replaceSelected(_selected!.withHandlers(handlers));
    // TODO: persist via _repository once an "add handler" endpoint exists.
  }

  void _addServicePerson(int handlerIndex, SalesPerson person) {
    if (_selected == null) return;
    final handlers = [..._selected!.ticketHandler];
    if (handlerIndex < 0 || handlerIndex >= handlers.length) return;
    final handler = handlers[handlerIndex];
    handlers[handlerIndex] = handler.withPersons([...handler.salesPerson, person]);
    _replaceSelected(_selected!.withHandlers(handlers));
    // TODO: persist via _repository once an "add service person" endpoint exists.
  }

  void _openCreateTicketDialog() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const CreateTicketDialog(),
      );

  void _openAddHandlerSheet() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AddHandlerSheet(onSubmit: _addHandler, repository: _repository),
      );

  Future<void> _openAddServicePersonSheet(int handlerIndex) async {
    if (_selected == null) return;
    final handler = _selected!.ticketHandler[handlerIndex];

    // We need to find the full dealer data to get the list of available salesPersons.
    // In a real app, you might fetch this by ID. Here we can use the repository mock.
    final dealers = await _repository.getDealers();
    final fullDealer = dealers.firstWhere(
      (d) => d.name == handler.name,
      orElse: () => TicketHandler(
        sNo: 0,
        name: handler.name,
        mobileNumber: handler.mobileNumber,
        statusMessage: handler.statusMessage,
        targetDates: [],
        salesPerson: [],
      ),
    );

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddServicePersonSheet(
        onSubmit: (p) => _addServicePerson(handlerIndex, p),
        availablePersons: fullDealer.salesPerson,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ServiceRequestPalette.canvas,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            flex: 2,
            child: _selected == null ? const EmptyState() : TimelineCard(ticket: _selected!),
          ),
          Expanded(
            flex: 4,
            child: _selected == null
                ? const SizedBox.shrink()
                : DetailsPanel(
                    ticket: _selected!,
                    category: _categoryOf(_selected!),
                    onAddHandler: _openAddHandlerSheet,
                    onAddServicePerson: _openAddServicePersonSheet,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 300,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: ServiceRequestPalette.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tickets',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: ServiceRequestPalette.ink,
                        letterSpacing: -0.5)),
                RoundIconButton(icon: Icons.add_rounded, onTap: _openCreateTicketDialog),
              ],
            ),
          ),
          FilterBar(
            filters: _filters,
            active: _activeFilter,
            countFor: (f) => f == 'All' ? _tickets.length : _tickets.where((t) => _statusOf(t) == f).length,
            onSelect: (f) => setState(() => _activeFilter = f),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text('No tickets here',
                        style: TextStyle(color: ServiceRequestPalette.mutedLight, fontSize: 13)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final ticket = _filtered[i];
                      return TicketCard(
                        ticket: ticket,
                        status: _statusOf(ticket),
                        selected: _selected?.ticketId == ticket.ticketId,
                        onTap: () => setState(() => _selected = ticket),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
