import 'columns.dart';
import 'user.dart';

enum Frequency { immediate, daily, weekly }

class NotificationPref {
  final int id;
  final UserModel? user;
  final int? userId;
  final Frequency frequency;
  final bool pushEnabled;
  final bool emailEnabled;
  final DateTime updatedAt;

  NotificationPref({
    required this.id,
    this.user,
    this.userId,
    required this.frequency,
    required this.pushEnabled,
    required this.emailEnabled,
    required this.updatedAt,
  });

  factory NotificationPref.fromJson(Map<String, dynamic> json) {
    final userValue = json[BDColumns.notificationPrefUser];
    UserModel? user;
    int? userId;

    if (userValue is Map<String, dynamic>) {
      user = UserModel.fromJson(userValue);
      userId = user.id;
    } else if (userValue is int) {
      userId = userValue;
    }

    return NotificationPref(
      id: json[BDColumns.notificationPrefId] as int,
      user: user,
      userId: userId,
      frequency: _parseFrequency(
        json[BDColumns.notificationPrefFrequency] as String,
      ),
      pushEnabled: json[BDColumns.notificationPrefPushEnabled] as bool? ?? true,
      emailEnabled:
          json[BDColumns.notificationPrefEmailEnabled] as bool? ?? false,
      updatedAt: DateTime.parse(
        json[BDColumns.notificationPrefUpdatedAt] as String,
      ),
    );
  }

  static Frequency _parseFrequency(String value) {
    switch (value) {
      case 'daily':
        return Frequency.daily;
      case 'weekly':
        return Frequency.weekly;
      default:
        return Frequency.immediate;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      BDColumns.notificationPrefId: id,
      BDColumns.notificationPrefUser: userId ?? user?.id,
      BDColumns.notificationPrefFrequency: frequency.name,
      BDColumns.notificationPrefPushEnabled: pushEnabled,
      BDColumns.notificationPrefEmailEnabled: emailEnabled,
      BDColumns.notificationPrefUpdatedAt: updatedAt.toIso8601String(),
    };
  }
}
