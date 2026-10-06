import 'package:flutter/material.dart';

class SelectSlotScreen extends StatelessWidget {
  final String parkingLotId;

  const SelectSlotScreen({super.key, required this.parkingLotId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Parking Slot'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF3F3F7),
            child: const Text(
              'Select a parking slot from the grid below',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                spacing: 16,
                children: [
                  const Row(
                    spacing: 16,
                    children: [
                      _LegendItem(color: Color(0xFF126E63), label: 'Available'),
                      _LegendItem(color: Colors.red, label: 'Occupied'),
                      _LegendItem(color: Colors.amber, label: 'Reserved'),
                    ],
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: List.generate(24, (index) {
                        return _SlotWidget(
                          slotNumber: 'A${index + 1}',
                          status: index % 5 == 0 ? 'occupied' : 'available',
                          onTap: () {},
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
      spacing: 6,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _SlotWidget extends StatelessWidget {
  final String slotNumber;
  final String status;
  final VoidCallback onTap;

  const _SlotWidget({
    required this.slotNumber,
    required this.status,
    required this.onTap,
  });

  Color get _color {
    switch (status) {
      case 'occupied':
        return Colors.red;
      case 'reserved':
        return Colors.amber;
      default:
        return const Color(0xFF126E63);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(width: 50, height: 50, decoration: BoxDecoration(color: _color.withValues(alpha: 0.15), border: Border.all(color: _color, width: 2), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(slotNumber, style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w700))));
  }
}