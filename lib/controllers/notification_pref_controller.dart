import 'package:get/get.dart';
import 'package:newstudent/models/user.dart';
import 'package:newstudent/utils/Setting.dart';
import '../models/notification_pref.dart';
import '../services/api_service.dart';

class NotificationPrefController extends GetxController {
  final Rx<NotificationPref?> notificationPref = Rx<NotificationPref?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotificationPrefs();
  }

  Future<void> fetchNotificationPrefs() async {
    isLoading.value = true;
    error.value = '';

    final result = await ApiService.getRequest(
      '/api/notifications/?user_id=${Setting.authCtrl.userData['id']}',
    );
    printDebug("NotificationPrefs: $result");

    if (result['success'] == true) {
      final responseData = result['data'];
      final currentUserId = Setting.authCtrl.userData['id'];

      Map<String, dynamic>? selected;
      List<dynamic> itemsList = [];

      // Gérer le format paginé Django REST Framework
      if (responseData is Map && responseData.containsKey('results')) {
        itemsList = responseData['results'] as List;
      } else if (responseData is List) {
        itemsList = responseData;
      } else if (responseData is Map<String, dynamic>) {
        itemsList = [responseData];
      }

      // Chercher la préférence correspondant à l'utilisateur courant
      for (final item in itemsList) {
        final userField = item['user'];
        final itemUserId =
            userField is int
                ? userField
                : (userField is Map<String, dynamic>
                    ? userField['id'] as int?
                    : null);
        if (itemUserId == currentUserId) {
          selected = Map<String, dynamic>.from(item);
          break;
        }
      }

      if (selected != null) {
        notificationPref.value = NotificationPref.fromJson(selected);
      } else {
        // Créer une préférence par défaut si aucune n'existe
        notificationPref.value = NotificationPref(
          id: 0,
          frequency: Frequency.immediate,
          pushEnabled: true,
          emailEnabled: false,
          userId: currentUserId,
          user: UserModel(
            id: currentUserId ?? 0,
            username: Setting.authCtrl.userData['username'] ?? '',
          ),
          updatedAt: DateTime.now(),
        );
      }
    } else {
      error.value = result['error'] ?? 'Erreur lors du chargement';
      Get.snackbar('Erreur', error.value);
    }

    isLoading.value = false;
  }

  Future<bool> updateNotificationPrefs({
    Frequency? frequency,
    bool? pushEnabled,
    bool? emailEnabled,
  }) async {
    isLoading.value = true;
    error.value = '';

    // Construire la nouvelle préférence à partir des valeurs fournies ou de l'existant
    final current = notificationPref.value;
    final int currentUserId = Setting.authCtrl.userData['id'];

    final Frequency newFrequency =
        frequency ?? current?.frequency ?? Frequency.immediate;
    final bool newPushEnabled = pushEnabled ?? current?.pushEnabled ?? true;
    final bool newEmailEnabled = emailEnabled ?? current?.emailEnabled ?? false;

    // 1) Supprimer l'ancienne préférence si elle existe (id > 0)
    if (current != null && current.id > 0) {
      final del = await ApiService.deleteRequest(
        '/api/notifications/${current.id}/',
      );
      if (del['success'] != true) {
        error.value =
            del['error'] ??
            'Erreur lors de la suppression de l’ancienne préférence';
        isLoading.value = false;
        Get.snackbar('Erreur', error.value);
        return false;
      }
    }

    // 2) Créer la nouvelle préférence
    final createBody = {
      'user': currentUserId,
      'frequency': newFrequency.name,
      'push_enabled': newPushEnabled,
      'email_enabled': newEmailEnabled,
    };

    final create = await ApiService.postRequest(
      '/api/notifications/',
      createBody,
    );

    if (create['success'] == true) {
      await fetchNotificationPrefs();
      isLoading.value = false;
      Get.snackbar('Succès', 'Préférences mises à jour');
      return true;
    } else {
      error.value =
          create['error'] ??
          'Erreur lors de la création de la nouvelle préférence';
      isLoading.value = false;
      Get.snackbar('Erreur', error.value);
      return false;
    }
  }

  Frequency getFrequency() {
    return notificationPref.value?.frequency ?? Frequency.immediate;
  }

  bool isPushEnabled() {
    return notificationPref.value?.pushEnabled ?? true;
  }

  bool isEmailEnabled() {
    return notificationPref.value?.emailEnabled ?? false;
  }
}
