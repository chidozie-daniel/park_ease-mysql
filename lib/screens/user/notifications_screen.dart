import 'package:flutter/material.dart';

import '../../models/notification.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/loading_indicator.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();
  List<AppNotification> _notifications = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final notifications = await _service.getNotifications();
      if (mounted) setState(() => _notifications = notifications);
    } catch (error) {
      if (mounted) setState(() => _error = ApiService.describeError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAllRead() async {
    try {
      await _service.markAllAsRead();
      if (!mounted) return;
      setState(() {
        _notifications = _notifications
            .map((item) => item.copyWith(isRead: true))
            .toList();
      });
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _open(AppNotification notification) async {
    if (!notification.isRead) {
      try {
        await _service.markAsRead(notification.id);
        if (mounted) {
          setState(() {
            _notifications = _notifications
                .map(
                  (item) => item.id == notification.id
                      ? item.copyWith(isRead: true)
                      : item,
                )
                .toList();
          });
        }
      } catch (error) {
        _showError(error);
        return;
      }
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Text(notification.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(AppNotification notification) async {
    try {
      await _service.deleteNotification(notification.id);
      if (mounted) {
        setState(() {
          _notifications.removeWhere((item) => item.id == notification.id);
        });
      }
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(ApiService.describeError(error))));
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _notifications.any((item) => !item.isRead);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: hasUnread && !_loading ? _markAllRead : null,
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: LoadingIndicator())
          : _error != null
          ? _message(
              icon: Icons.cloud_off_rounded,
              message: _error!,
              action: TextButton(onPressed: _load, child: const Text('Retry')),
            )
          : _notifications.isEmpty
          ? _message(
              icon: Icons.notifications_none_rounded,
              message:
                  'You are all caught up. New notifications will appear here.',
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return Dismissible(
                    key: ValueKey(notification.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) async {
                      await _delete(notification);
                      return !_notifications.any(
                        (item) => item.id == notification.id,
                      );
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                    ),
                    child: Card(
                      color: notification.isRead
                          ? Colors.white
                          : const Color(0xFFF3F3F7),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(
                            0xFF126E63,
                          ).withValues(alpha: 0.12),
                          child: Icon(
                            _iconFor(notification.type),
                            color: const Color(0xFF126E63),
                          ),
                        ),
                        title: Text(
                          notification.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${notification.body}\n${_formatTime(notification.createdAt)}',
                        ),
                        isThreeLine: true,
                        trailing: notification.isRead
                            ? null
                            : const Icon(
                                Icons.circle,
                                size: 10,
                                color: Color(0xFF126E63),
                              ),
                        onTap: () => _open(notification),
                      ),
                    ),
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

  IconData _iconFor(NotificationType type) => switch (type) {
    NotificationType.booking => Icons.local_parking_rounded,
    NotificationType.payment => Icons.payments_rounded,
    NotificationType.reminder => Icons.access_time_rounded,
    NotificationType.promotion => Icons.local_offer_rounded,
    NotificationType.alert => Icons.warning_rounded,
    NotificationType.system => Icons.info_rounded,
  };

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    return '${local.day}/${local.month}/${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
