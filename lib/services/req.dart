import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:newstudent/utils/Setting.dart';

Future<void> sendNotificationRequest({
  required String title,
  required String message,
  List<String>? segments,
  List<String>? externalIds,
  DateTime? scheduleTime,
}) async {
  final url = Uri.parse("https://api.onesignal.com/notifications");

  String appId = Setting.onesignal_app_id;
  String apiKey = Setting.onesignal_secret_key;

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Key $apiKey',
  };

  final body = jsonEncode({
    "target_channel": "push",
    if (externalIds == null)
      "included_segments": segments ?? ["Subscribed Users"],
    "app_id": appId,
    if (externalIds != null) "include_external_user_ids": externalIds,
    if (scheduleTime != null)
      "send_after": scheduleTime.toUtc().toIso8601String(),
    // "contents": {
    //   // "en": "Hello, world",

    //   "fr": "Bonjour le monde",
    // }
    "headings": {"fr": title, "en ": title},
    "contents": {"fr": message, "en": message},
  });

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      printDebug('Notification OneSignal sent successfully: ${response.body}');
    } else {
      printDebug(
        'Failed to send OneSignal notification: ${response.statusCode} ${response.body}',
      );
    }
  } catch (e) {
    printDebug('Error sending OneSignal notification: $e');
  }
}
// Future<void> sendNotification(
//     {required String title,
//     required String message,
//     List<String>? segments}) async {
//   const String url = "https://onesignal.com/api/v1/notifications";

//   String appId = Setting.homeCtrl.keyAppIDOneSignal;
//   String apiKey = Setting.homeCtrl.keyApiOneSignal;

//   final response = await http.post(
//     Uri.parse(url),
//     headers: {
//       "Content-Type": "application/json; charset=UTF-8",
//       "Authorization": "Key $apiKey"
//     },
//     body: json.encode({
//       "app_id": appId,
//       "included_segments": segments ?? ["Subscribed Users"],
//       "headings": {"en": title},
//       "contents": {"en": message},
//     }),
//   );

//   if (response.statusCode == 200) {
//     printDebug("Notification OneSignal envoyée avec succès");
//   } else {
//     printDebug("Erreur OneSignal lors de l'envoi : ${response.body}");
//   }
// }
