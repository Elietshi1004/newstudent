import 'package:newstudent/models/columns.dart';
import 'package:newstudent/models/user.dart';

class PushSubscription {
  final int id;
  final int userId;
  final String externalUserId;
  final String? deviceToken;
  final DateTime createdAt;
  final UserModel? user;

  PushSubscription({
    required this.id,
    required this.userId,
    required this.externalUserId,
    this.deviceToken,
    required this.createdAt,
    this.user,
  });

  factory PushSubscription.fromJson(Map<String, dynamic> json) {
    UserModel? parsedUser;
    int? parsedUserId;
    final userField = json[BDColumns.pushSubscriptionUser];
    if (userField is Map<String, dynamic>) {
      parsedUser = UserModel.fromJson(userField);
      parsedUserId = parsedUser.id;
    } else if (userField is int) {
      parsedUserId = userField;
    }

    return PushSubscription(
      id:
          json[BDColumns.pushSubscriptionId] != null
              ? json[BDColumns.pushSubscriptionId] as int
              : 0,
      userId:
          parsedUserId ??
          (json[BDColumns.pushSubscriptionUser] is int
              ? json[BDColumns.pushSubscriptionUser] as int
              : 0),
      externalUserId: json[BDColumns.pushSubscriptionExternalUserId] as String,
      deviceToken: json[BDColumns.pushSubscriptionDeviceToken] as String?,
      createdAt:
          DateTime.tryParse(
            json[BDColumns.pushSubscriptionCreatedAt].toString(),
          ) ??
          DateTime.now(),
      user: parsedUser,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      BDColumns.pushSubscriptionId: id,
      BDColumns.pushSubscriptionUser: user != null ? user!.toJson() : userId,
      BDColumns.pushSubscriptionExternalUserId: externalUserId,
      BDColumns.pushSubscriptionDeviceToken: deviceToken,
      BDColumns.pushSubscriptionCreatedAt: createdAt.toIso8601String(),
    };
  }
}
