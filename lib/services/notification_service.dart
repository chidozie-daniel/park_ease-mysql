import 'api_service.dart';
import '../config/api_config.dart';
import '../models/notification.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _api = ApiService();

  Future<List<AppNotification>> getNotifications() async {
    final response = await _api.get(ApiConfig.notifications);
    final list = response['data'] as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(String id) async {
    await _api.put('${ApiConfig.notifications}/$id/read', {});
  }

  Future<void> markAllAsRead() async {
    await _api.put('${ApiConfig.notifications}/read-all', {});
  }

  Future<void> deleteNotification(String id) async {
    await _api.delete('${ApiConfig.notifications}/$id');
  }

  Future<void> registerPushToken(String token) async {
    await _api.post('/api/v1/notifications/push-token', {'token': token});
  }
}