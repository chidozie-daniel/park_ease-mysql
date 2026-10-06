import 'package:flutter/material.dart';

import '../../widgets/app_button.dart';

class AddEditParkingLotScreen extends StatelessWidget {
  final String? parkingLotId;

  const AddEditParkingLotScreen({super.key, this.parkingLotId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(parkingLotId == null ? 'Add Parking Lot' : 'Edit Parking Lot'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildField('Name', 'City Center Parking'),
          const SizedBox(height: 16),
          _buildField('Address', '123 Main Street, Downtown'),
          const SizedBox(height: 16),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: _buildField('Latitude', '40.7128'),
              ),
              Expanded(
                child: _buildField('Longitude', '-74.0060'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildField('Total Slots', '120'),
          const SizedBox(height: 16),
          _buildField('Hourly Rate', '50'),
          const SizedBox(height: 16),
          _buildField('Description', 'A premium parking facility in the heart of the city.'),
          const SizedBox(height: 32),
          AppButton(
            label: parkingLotId == null ? 'Add Parking Lot' : 'Save Changes',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFC8C7D4),
              width: 1,
            ),
          ),
          child: TextField(
            controller: TextEditingController(text: initialValue),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
