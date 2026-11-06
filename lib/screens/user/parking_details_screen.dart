import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/routes.dart';
import '../../models/parking_lot.dart';
import '../../services/api_service.dart';
import '../../services/parking_service.dart';
import '../../utils/utils.dart';
import '../../widgets/loading_indicator.dart';

class ParkingDetailsScreen extends StatefulWidget {
  final String parkingLotId;

  const ParkingDetailsScreen({super.key, required this.parkingLotId});

  @override
  State<ParkingDetailsScreen> createState() => _ParkingDetailsScreenState();
}

class _ParkingDetailsScreenState extends State<ParkingDetailsScreen> {
  final _parking = ParkingService();
  late Future<ParkingLot> _lot;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _lot = _parking.getParkingLot(widget.parkingLotId);
  }

  Future<void> _retry() async {
    final request = _parking.getParkingLot(widget.parkingLotId);
    setState(() => _lot = request);
  }

  Future<void> _share(ParkingLot lot) async {
    await Clipboard.setData(ClipboardData(text: '${lot.name}\n${lot.address}'));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Parking details copied to clipboard.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ParkingLot>(
      future: _lot,
      builder: (context, snapshot) {
        return Scaffold(
          body: snapshot.hasData
              ? _details(snapshot.data!)
              : snapshot.hasError
              ? _error(ApiService.describeError(snapshot.error!))
              : const Center(child: LoadingIndicator()),
        );
      },
    );
  }

  Widget _error(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parking Details')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 56),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              TextButton(onPressed: _retry, child: const Text('Try again')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _details(ParkingLot lot) {
    final isOpen = lot.isActive && lot.status != ParkingStatus.closed;
    final canBook = lot.isBookable && isOpen && lot.availableSlots > 0;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          title: Text(lot.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(
              tooltip: 'Copy parking details',
              icon: const Icon(Icons.share_rounded),
              onPressed: () => _share(lot),
            ),
            IconButton(
              tooltip: _isFavorite ? 'Remove favorite' : 'Add favorite',
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
                color: _isFavorite ? Colors.red : null,
              ),
              onPressed: () {
                setState(() => _isFavorite = !_isFavorite);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isFavorite
                          ? 'Added to favorites for this visit.'
                          : 'Removed from favorites.',
                    ),
                  ),
                );
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: SweepGradient(
                  colors: [
                    Color(0xFFDEDCEC),
                    Color(0xFFF3F3F7),
                    Color(0xFFC8C7DF),
                  ],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.local_parking_rounded,
                  size: 80,
                  color: Color(0xFF126E63),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lot.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Chip(
                    label: Text(isOpen ? lot.status.label : 'Closed'),
                    backgroundColor: isOpen
                        ? const Color(0xFF126E63).withValues(alpha: 0.12)
                        : Colors.red.withValues(alpha: 0.12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _infoRow(Icons.location_on_outlined, lot.address),
              const SizedBox(height: 12),
              _infoRow(
                Icons.local_parking_outlined,
                lot.isBookable
                    ? '${lot.availableSlots} of ${lot.totalSlots} spots available'
                    : 'Community listing; availability is not provided',
              ),
              if (lot.description?.isNotEmpty ?? false) ...[
                const SizedBox(height: 20),
                Text(lot.description!),
              ],
              const Divider(height: 36),
              Text(
                'Pricing',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                lot.isBookable
                    ? '${AppHelpers.formatPrice(lot.hourlyRate)} per hour'
                    : 'Rates are not listed for this community location.',
                style: const TextStyle(
                  color: Color(0xFF126E63),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (lot.dailyRate != null) ...[
                const SizedBox(height: 4),
                Text('Daily rate: ${AppHelpers.formatPrice(lot.dailyRate!)}'),
              ],
              if (lot.amenities.isNotEmpty) ...[
                const Divider(height: 36),
                Text(
                  'Amenities',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: lot.amenities
                      .map((amenity) => Chip(label: Text(amenity)))
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),
              if (canBook)
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.selectSlot,
                    arguments: {'parkingLotId': lot.id},
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF126E63),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: const Text('Select Slot'),
                )
              else
                const Text(
                  'This location cannot currently be booked in Park Ease.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6B7280)),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    );
  }
}
