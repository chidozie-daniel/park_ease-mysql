import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

enum NotificationType { booking, payment, reminder, promotion, alert, system }

extension NotificationTypeExtension on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.booking:
        return 'Booking';
      case NotificationType.payment:
        return 'Payment';
      case NotificationType.reminder:
        return 'Reminder';
      case NotificationType.promotion:
        return 'Promotion';
      case NotificationType.alert:
        return 'Alert';
      case NotificationType.system:
        return 'System';
    }
  }
}

@JsonSerializable()
class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final String? data;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.isRead = false,
    this.data,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
  Map<String, dynamic> json() => _$AppNotificationToJson(this);

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      userId: userId,
      type: type,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      data: data,
      createdAt: createdAt,
    );
  }
}