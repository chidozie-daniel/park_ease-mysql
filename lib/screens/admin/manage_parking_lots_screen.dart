import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../models/parking_lot.dart';
import '../../services/admin_service.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_indicator.dart';

class ManageParkingLotsScreen extends StatefulWidget {
  const ManageParkingLotsScreen({super.key});

  @override
  State<ManageParkingLotsScreen> createState() =>
      _ManageParkingLotsScreenState();
}

class _ManageParkingLotsScreenState extends State<ManageParkingLotsScreen> {
  final _service = AdminService();
  late Future<List<ParkingLot>> _lots;

  @override
  void initState() {
    super.initState();
    _lots = _service.getParkingLots();
  }

  Future<void> _refresh() async {
    final request = _service.getParkingLots();
    setState(() => _lots = request);
    await request;
  }

  Future<void> _edit([ParkingLot? lot]) async {
    final changed = await Navigator.pushNamed(
      context,
      AppRoutes.addEditParkingLot,
      arguments: {'parkingLotId': lot?.id},
    );
    if (changed == true && mounted) await _refresh();
  }

  Future<void> _delete(ParkingLot lot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete parking lot?'),
        content: Text('Delete "${lot.name}" and its parking spaces?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _service.deleteParkingLot(lot.id);
      if (mounted) await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(ApiService.describeError(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Parking Lots'),
        actions: [
          IconButton(
            tooltip: 'Add parking lot',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _edit(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Parking Lot'),
      ),
      body: FutureBuilder<List<ParkingLot>>(
        future: _lots,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }
          if (snapshot.hasError) {
            return _message(
              ApiService.describeError(snapshot.error!),
              action: TextButton(
                onPressed: _refresh,
                child: const Text('Retry'),
              ),
            );
          }
          final lots = snapshot.data ?? const <ParkingLot>[];
          if (lots.isEmpty) {
            return _message(
              'No parking lots have been added.',
              action: OutlinedButton.icon(
                onPressed: () => _edit(),
                icon: const Icon(Icons.add),
                label: const Text('Add Parking Lot'),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: lots.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final lot = lots[index];
                return Card(
                  color: Colors.white,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEDECF5),
                      child: Icon(
                        Icons.local_parking_rounded,
                        color: Color(0xFF126E63),
                      ),
                    ),
                    title: Text(
                      lot.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${lot.availableSlots}/${lot.totalSlots} available · '
                      'Rs ${lot.hourlyRate.toStringAsFixed(2)}/hr · '
                      '${lot.status.label}\n${lot.address}',
                    ),
                    isThreeLine: true,
                    onTap: () => _edit(lot),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) {
                        if (action == 'edit') _edit(lot);
                        if (action == 'delete') _delete(lot);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _message(String text, {Widget? action}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 12), action],
          ],
        ),
      ),
    );
  }
}
