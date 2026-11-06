import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../models/parking_slot.dart';
import '../../services/api_service.dart';
import '../../services/parking_service.dart';
import '../../widgets/loading_indicator.dart';

class SelectSlotScreen extends StatefulWidget {
  final String parkingLotId;

  const SelectSlotScreen({super.key, required this.parkingLotId});

  @override
  State<SelectSlotScreen> createState() => _SelectSlotScreenState();
}

class _SelectSlotScreenState extends State<SelectSlotScreen> {
  final _parking = ParkingService();
  late Future<List<ParkingSlot>> _slots;

  @override
  void initState() {
    super.initState();
    _slots = _parking.getParkingSlots(widget.parkingLotId);
  }

  void _continueWithoutSlot() {
    Navigator.pushNamed(
      context,
      AppRoutes.bookingForm,
      arguments: {'parkingLotId': widget.parkingLotId},
    );
  }

  void _select(ParkingSlot slot) {
    if (slot.status != SlotStatus.available) return;
    Navigator.pushNamed(
      context,
      AppRoutes.bookingForm,
      arguments: {
        'parkingLotId': widget.parkingLotId,
        'parkingSlotId': slot.id,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Parking Slot')),
      body: FutureBuilder<List<ParkingSlot>>(
        future: _slots,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ApiService.describeError(snapshot.error!),
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      onPressed: () => setState(
                        () => _slots = _parking.getParkingSlots(
                          widget.parkingLotId,
                        ),
                      ),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final slots = snapshot.data ?? const <ParkingSlot>[];
          final available = slots
              .where((slot) => slot.status == SlotStatus.available)
              .toList();
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Choose an available space, or continue without selecting a specific slot.',
                  textAlign: TextAlign.center,
                ),
              ),
              const _Legend(),
              const SizedBox(height: 12),
              if (slots.isEmpty)
                const Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No individual spaces are listed for this parking location.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 92,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                    itemCount: slots.length,
                    itemBuilder: (context, index) {
                      final slot = slots[index];
                      return _SlotTile(slot: slot, onTap: () => _select(slot));
                    },
                  ),
                ),
              if (available.isEmpty || slots.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _continueWithoutSlot,
                      child: const Text('Continue without a specific slot'),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _LegendItem(color: Color(0xFF126E63), label: 'Available'),
        _LegendItem(color: Colors.red, label: 'Occupied'),
        _LegendItem(color: Colors.amber, label: 'Reserved'),
        _LegendItem(color: Colors.grey, label: 'Maintenance'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _SlotTile extends StatelessWidget {
  final ParkingSlot slot;
  final VoidCallback onTap;

  const _SlotTile({required this.slot, required this.onTap});

  Color get _color => switch (slot.status) {
    SlotStatus.available => const Color(0xFF126E63),
    SlotStatus.occupied => Colors.red,
    SlotStatus.reserved => Colors.amber,
    SlotStatus.maintenance => Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final isAvailable = slot.status == SlotStatus.available;
    return InkWell(
      onTap: isAvailable ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.12),
          border: Border.all(color: _color, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                slot.slotNumber,
                style: TextStyle(
                  color: _color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                slot.status.label,
                style: TextStyle(color: _color, fontSize: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
