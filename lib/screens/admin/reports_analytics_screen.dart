import 'package:material_ui/material_ui.dart';

import '../../services/admin_service.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../widgets/app_button.dart';
import '../../widgets/loading_indicator.dart';

class ReportsAnalyticsScreen extends StatefulWidget {
  const ReportsAnalyticsScreen({super.key});

  @override
  State<ReportsAnalyticsScreen> createState() => _ReportsAnalyticsScreenState();
}

class _ReportsAnalyticsScreenState extends State<ReportsAnalyticsScreen> {
  final _service = AdminService();

  late Future<_ReportData> _report = _load();

  Future<_ReportData> _load() async {
    final results = await Future.wait([
      _service.getReports(),
      _service.getDashboard(),
    ]);
    return _ReportData(
      reports: results[0],
      dashboard: results[1],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<_ReportData>(
        future: _report,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 56, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      ApiService.describeError(snapshot.error ?? 'No data'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Retry',
                      onPressed: () => setState(() => _report = _load()),
                    ),
                  ],
                ),
              ),
            );
          }
          return _content(snapshot.data!);
        },
      ),
    );
  }

  Widget _content(_ReportData data) {
    final summary = _map(data.reports['summary']);
    final totalRevenue = _number(summary['totalRevenue']);
    final totalBookings = _number(summary['totalBookings']);
    final average = totalBookings == 0 ? 0.0 : totalRevenue / totalBookings;
    final totalSlots = _number(data.dashboard['totalSlots']);
    final activeBookings = _number(data.dashboard['activeBookings']);
    final occupancy = totalSlots == 0 ? 0.0 : (activeBookings / totalSlots) * 100;
    final days = _lastSevenDays(data.reports);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Revenue',
                AppHelpers.formatCurrency(totalRevenue),
                Icons.attach_money_rounded,
                Colors.green,
              ),
            ),
            Expanded(
              child: _buildStatCard(
                'Total Bookings',
                totalBookings.toStringAsFixed(0),
                Icons.receipt_long_rounded,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: _buildStatCard(
                'Avg. Booking',
                AppHelpers.formatCurrency(average),
                Icons.bar_chart_rounded,
                Colors.amber,
              ),
            ),
            Expanded(
              child: _buildStatCard(
                'Occupancy Rate',
                '${occupancy.toStringAsFixed(0)}%',
                Icons.local_parking_rounded,
                const Color(0xFF126E63),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _chartCard(days),
        const SizedBox(height: 16),
        _bookingsByLotCard(data.reports),
      ],
    );
  }

  Widget _chartCard(List<_DayRevenue> days) {
    final maxRevenue = days.fold<double>(
      0,
      (max, day) => day.revenue > max ? day.revenue : max,
    );

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Revenue Trend (Last 7 Days)',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            spacing: 8,
            children: [
              for (final day in days)
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: maxRevenue == 0
                            ? 4
                            : 100 * (day.revenue / maxRevenue),
                        decoration: BoxDecoration(
                          color: const Color(0xFF126E63).withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        day.label,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bookingsByLotCard(Map<String, dynamic> reports) {
    final rows = (reports['bookingsByLot'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
    final top = rows.take(5).toList();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Bookings by Parking Lot',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (top.isEmpty)
            const Text(
              'No bookings recorded yet.',
              style: TextStyle(color: Color(0xFF6B7280)),
            )
          else
            ...top.map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        row['lotName']?.toString() ?? 'Unknown lot',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _number(row['bookings']).toStringAsFixed(0),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return _card(
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _map(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  double _number(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  List<_DayRevenue> _lastSevenDays(Map<String, dynamic> reports) {
    final byDate = <String, double>{};
    final rows = reports['revenueByDay'] as List<dynamic>? ?? const [];
    for (final row in rows) {
      if (row is! Map) continue;
      final rawDate = row['date']?.toString();
      if (rawDate == null || rawDate.isEmpty) continue;
      final key = rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;
      byDate[key] = _number(row['revenue']);
    }

    final today = DateTime.now();
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return List.generate(7, (index) {
      final date = DateTime(today.year, today.month, today.day - (6 - index));
      final key =
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
      return _DayRevenue(
        label: labels[date.weekday - 1],
        revenue: byDate[key] ?? 0,
      );
    });
  }
}

class _DayRevenue {
  final String label;
  final double revenue;

  const _DayRevenue({required this.label, required this.revenue});
}

class _ReportData {
  final Map<String, dynamic> reports;
  final Map<String, dynamic> dashboard;

  const _ReportData({required this.reports, required this.dashboard});
}
