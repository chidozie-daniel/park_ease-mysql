import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../models/parking_lot.dart';
import '../../services/api_service.dart';
import '../../services/parking_service.dart';
import '../../utils/utils.dart';
import '../../widgets/loading_indicator.dart';

class ParkingResultsScreen extends StatefulWidget {
  final String query;

  const ParkingResultsScreen({super.key, required this.query});

  @override
  State<ParkingResultsScreen> createState() => _ParkingResultsScreenState();
}

class _ParkingResultsScreenState extends State<ParkingResultsScreen> {
  final _parking = ParkingService();
  late Future<List<ParkingLot>> _lots;
  bool _sortByPrice = false;

  @override
  void initState() {
    super.initState();
    _lots = _loadLots();
  }

  Future<List<ParkingLot>> _loadLots() {
    final query = widget.query.trim();
    return query.isEmpty
        ? _parking.getAllLots()
        : _parking.searchParking(query);
  }

  Future<void> _refresh() async {
    final request = _loadLots();
    setState(() => _lots = request);
    await request;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.query.isEmpty ? 'All Parking' : widget.query),
        actions: [
          IconButton(
            tooltip: _sortByPrice ? 'Sort by availability' : 'Sort by price',
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => setState(() => _sortByPrice = !_sortByPrice),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<ParkingLot>>(
          future: _lots,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: LoadingIndicator());
            }
            if (snapshot.hasError) {
              return _Message(
                icon: Icons.cloud_off_rounded,
                message: ApiService.describeError(snapshot.error!),
                action: TextButton(
                  onPressed: _refresh,
                  child: const Text('Try again'),
                ),
              );
            }
            final lots = [...?snapshot.data];
            if (_sortByPrice) {
              lots.sort((a, b) => a.hourlyRate.compareTo(b.hourlyRate));
            } else {
              lots.sort((a, b) => b.availableSlots.compareTo(a.availableSlots));
            }
            if (lots.isEmpty) {
              return _Message(
                icon: Icons.local_parking_outlined,
                message: widget.query.isEmpty
                    ? 'No parking locations are available yet.'
                    : 'No parking locations matched "${widget.query}".',
                action: TextButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.searchParking),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Search on map'),
                ),
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: lots.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final lot = lots[index];
                return _LotCard(
                  lot: lot,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.parkingDetails,
                    arguments: {'parkingLotId': lot.id},
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _LotCard extends StatelessWidget {
  final ParkingLot lot;
  final VoidCallback onTap;

  const _LotCard({required this.lot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFEDECF5),
          child: Icon(Icons.local_parking_rounded, color: Color(0xFF126E63)),
        ),
        title: Text(
          lot.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lot.address, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(
                lot.isBookable
                    ? '${lot.availableSlots} of ${lot.totalSlots} spots · '
                          '${AppHelpers.formatPrice(lot.hourlyRate)}/hr'
                    : 'Community listing · availability not listed',
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String message;
  final Widget? action;

  const _Message({required this.icon, required this.message, this.action});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(icon, size: 64, color: Colors.black38),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(message, textAlign: TextAlign.center),
        ),
        if (action != null) ...[
          const SizedBox(height: 12),
          Center(child: action),
        ],
      ],
    );
  }
}
