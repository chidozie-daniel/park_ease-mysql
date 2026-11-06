import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../models/vehicle.dart';
import '../../services/api_service.dart';
import '../../services/vehicle_service.dart';
import '../../widgets/loading_indicator.dart';

class MyVehiclesScreen extends StatefulWidget {
  const MyVehiclesScreen({super.key});

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen> {
  final _service = VehicleService();
  List<Vehicle> _vehicles = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final vehicles = await _service.getMyVehicles();
      if (mounted) setState(() => _vehicles = vehicles);
    } catch (error) {
      if (mounted) setState(() => _error = ApiService.describeError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addVehicle() async {
    final added = await Navigator.pushNamed(context, AppRoutes.addVehicle);
    if (added == true && mounted) await _loadVehicles();
  }

  Future<void> _showActions(Vehicle vehicle) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            if (!vehicle.isDefault)
              ListTile(
                leading: const Icon(Icons.star_outline_rounded),
                title: const Text('Set as default vehicle'),
                onTap: () => Navigator.pop(context, 'default'),
              ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
              title: const Text('Remove vehicle'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    try {
      if (action == 'default') {
        await _service.setDefault(vehicle.id);
      } else if (action == 'delete') {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove vehicle?'),
            content: Text('Remove ${vehicle.brand} ${vehicle.model}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Remove'),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
        await _service.deleteVehicle(vehicle.id);
      }
      await _loadVehicles();
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
        title: const Text('My Vehicles'),
        actions: [
          IconButton(
            tooltip: 'Add vehicle',
            icon: const Icon(Icons.add_rounded),
            onPressed: _addVehicle,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addVehicle,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Vehicle'),
      ),
      body: _loading
          ? const Center(child: LoadingIndicator())
          : _error != null
          ? _message(
              icon: Icons.cloud_off_rounded,
              message: _error!,
              action: TextButton(
                onPressed: _loadVehicles,
                child: const Text('Retry'),
              ),
            )
          : _vehicles.isEmpty
          ? _message(
              icon: Icons.directions_car_outlined,
              message: 'No vehicles yet. Add one to make booking faster.',
              action: OutlinedButton.icon(
                onPressed: _addVehicle,
                icon: const Icon(Icons.add),
                label: const Text('Add Vehicle'),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadVehicles,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _vehicles.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final vehicle = _vehicles[index];
                  return _VehicleCard(
                    vehicle: vehicle,
                    onTap: () => _showActions(vehicle),
                  );
                },
              ),
            ),
    );
  }

  Widget _message({
    required IconData icon,
    required String message,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 60, color: Colors.black38),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 12), action],
          ],
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const _VehicleCard({required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFEDECF5),
          child: Icon(Icons.directions_car_rounded, color: Color(0xFF9894BD)),
        ),
        title: Text(
          '${vehicle.brand} ${vehicle.model}'.trim(),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${vehicle.type.label} · ${vehicle.color}\n${vehicle.licensePlate}',
        ),
        isThreeLine: true,
        trailing: vehicle.isDefault
            ? const Chip(label: Text('Default'))
            : const Icon(Icons.more_vert_rounded),
      ),
    );
  }
}
