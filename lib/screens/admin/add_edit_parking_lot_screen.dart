import 'package:flutter/material.dart';

import '../../models/parking_lot.dart';
import '../../services/admin_service.dart';
import '../../services/api_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/loading_indicator.dart';

class AddEditParkingLotScreen extends StatefulWidget {
  final String? parkingLotId;

  const AddEditParkingLotScreen({super.key, this.parkingLotId});

  @override
  State<AddEditParkingLotScreen> createState() =>
      _AddEditParkingLotScreenState();
}

class _AddEditParkingLotScreenState extends State<AddEditParkingLotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AdminService();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  final _totalSlots = TextEditingController();
  final _hourlyRate = TextEditingController();
  final _dailyRate = TextEditingController();
  final _description = TextEditingController();
  final _amenities = TextEditingController();
  ParkingLotType _type = ParkingLotType.indoor;
  ParkingStatus _status = ParkingStatus.available;
  bool _loading = false;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.parkingLotId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _loadLot();
  }

  Future<void> _loadLot() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final lots = await _service.getParkingLots();
      final lot = lots
          .where((item) => item.id == widget.parkingLotId)
          .firstOrNull;
      if (lot == null) throw StateError('Parking lot not found.');
      _name.text = lot.name;
      _address.text = lot.address;
      _latitude.text = lot.latitude.toString();
      _longitude.text = lot.longitude.toString();
      _totalSlots.text = lot.totalSlots.toString();
      _hourlyRate.text = lot.hourlyRate.toString();
      _dailyRate.text = lot.dailyRate?.toString() ?? '';
      _description.text = lot.description ?? '';
      _amenities.text = lot.amenities.join(', ');
      _type = lot.type;
      _status = lot.status;
    } catch (error) {
      _error = error is StateError
          ? error.message
          : ApiService.describeError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _totalSlots.dispose();
    _hourlyRate.dispose();
    _dailyRate.dispose();
    _description.dispose();
    _amenities.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final data = <String, dynamic>{
      'name': _name.text.trim(),
      'address': _address.text.trim(),
      'latitude': double.parse(_latitude.text.trim()),
      'longitude': double.parse(_longitude.text.trim()),
      'type': _type.name,
      'totalSlots': int.parse(_totalSlots.text.trim()),
      'hourlyRate': double.parse(_hourlyRate.text.trim()),
      'dailyRate': _dailyRate.text.trim().isEmpty
          ? null
          : double.parse(_dailyRate.text.trim()),
      'description': _description.text.trim(),
      'amenities': _amenities.text
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(),
      'status': _status.name,
    };
    try {
      if (_isEditing) {
        await _service.updateParkingLot(widget.parkingLotId!, data);
      } else {
        await _service.createParkingLot(data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = ApiService.describeError(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Parking Lot' : 'Add Parking Lot'),
      ),
      body: _loading
          ? const Center(child: LoadingIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _field('Name', _name, required: true),
                  _field('Address', _address, required: true),
                  Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: _field(
                          'Latitude',
                          _latitude,
                          number: true,
                          required: true,
                        ),
                      ),
                      Expanded(
                        child: _field(
                          'Longitude',
                          _longitude,
                          number: true,
                          required: true,
                        ),
                      ),
                    ],
                  ),
                  DropdownButtonFormField<ParkingLotType>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: ParkingLotType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _type = value ?? _type),
                  ),
                  _field(
                    'Total Slots',
                    _totalSlots,
                    number: true,
                    required: true,
                  ),
                  _field(
                    'Hourly Rate',
                    _hourlyRate,
                    number: true,
                    required: true,
                  ),
                  _field('Daily Rate (optional)', _dailyRate, number: true),
                  DropdownButtonFormField<ParkingStatus>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: ParkingStatus.values
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _status = value ?? _status),
                  ),
                  _field('Description', _description),
                  _field('Amenities (comma separated)', _amenities),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  AppButton(
                    label: _isEditing ? 'Save Changes' : 'Add Parking Lot',
                    isLoading: _saving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool number = false,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: number
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        maxLines: label == 'Description' || label.startsWith('Amenities')
            ? 3
            : 1,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return '$label is required';
          }
          if (number && value != null && value.trim().isNotEmpty) {
            final parsed = double.tryParse(value.trim());
            if (parsed == null || parsed < 0) {
              return 'Enter a valid non-negative number';
            }
            if ((label == 'Latitude' && parsed > 90) ||
                (label == 'Latitude' && parsed < -90) ||
                (label == 'Longitude' && parsed > 180) ||
                (label == 'Longitude' && parsed < -180)) {
              return 'Enter valid coordinates';
            }
            if (label == 'Total Slots' && parsed != parsed.roundToDouble()) {
              return 'Enter a whole number';
            }
          }
          return null;
        },
      ),
    );
  }
}
