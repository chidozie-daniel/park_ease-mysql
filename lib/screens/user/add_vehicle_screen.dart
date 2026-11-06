import 'package:flutter/material.dart';

import '../../models/vehicle.dart';
import '../../services/api_service.dart';
import '../../services/vehicle_service.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _licenseController = TextEditingController();
  final _colorController = TextEditingController();
  String _selectedType = 'Car';
  bool _isDefault = false;
  bool _isSaving = false;
  String? _error;
  final _service = VehicleService();

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _licenseController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await _service.addVehicle(
        type: VehicleType.values.byName(_selectedType.toLowerCase()),
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        color: _colorController.text.trim(),
        licensePlate: _licenseController.text.trim(),
        isDefault: _isDefault,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = ApiService.describeError(error));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vehicle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 412),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Add New Vehicle',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fill in the details of your vehicle',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Vehicle Type',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildTypeChip('Car', Icons.directions_car_rounded),
                      _buildTypeChip('Bike', Icons.motorcycle_rounded),
                      _buildTypeChip('Scooter', Icons.electric_scooter_rounded),
                      _buildTypeChip('Truck', Icons.local_shipping_rounded),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildField(
                    label: 'Brand',
                    controller: _brandController,
                    hint: 'e.g. Toyota',
                  ),
                  const SizedBox(height: 20),
                  _buildField(
                    label: 'Model',
                    controller: _modelController,
                    hint: 'e.g. Camry',
                  ),
                  const SizedBox(height: 20),
                  _buildField(
                    label: 'License Plate',
                    controller: _licenseController,
                    hint: 'Enter your plate number',
                  ),
                  const SizedBox(height: 20),
                  _buildField(
                    label: 'Color',
                    controller: _colorController,
                    hint: 'e.g. Black',
                  ),
                  const SizedBox(height: 24),
                  CheckboxListTile(
                    value: _isDefault,
                    onChanged: (v) => setState(() => _isDefault = v ?? false),
                    title: const Text('Set as default vehicle'),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 40),
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],
                  AppButton(
                    label: 'Add Vehicle',
                    isLoading: _isSaving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFC8C7D4), width: 1),
          ),
          child: TextFormField(
            controller: controller,
            validator: (value) => AppValidators.required(value, label),
            textInputAction: TextInputAction.next,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9894BE)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeChip(String label, IconData icon) {
    final selected = _selectedType == label;
    return FilterChip(
      selected: selected,
      label: Text(label),
      avatar: Icon(icon),
      onSelected: (v) => setState(() => _selectedType = label),
      selectedColor: const Color(0xFF126E63).withValues(alpha: 0.15),
      checkmarkColor: const Color(0xFF126E63),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF126E63) : Colors.black87,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: selected ? const Color(0xFF126E63) : const Color(0xFFE5E7EB),
        ),
      ),
    );
  }
}
