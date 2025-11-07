import 'package:get/get.dart';
import '../models/push_subscription.dart';
import '../services/api_service.dart';
import '../utils/Setting.dart';

class PushSubscriptionController extends GetxController {
  final Rx<PushSubscription?> currentSubscription = Rx<PushSubscription?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  /// Enregistrer ou mettre à jour un abonnement push OneSignal
  Future<bool> registerPushSubscription({
    required String externalUserId,
    String? deviceToken,
  }) async {
    isLoading.value = true;
    error.value = '';

    final result = await ApiService.postRequest('/api/register_push/', {
      'external_user_id': externalUserId,
      if (deviceToken != null) 'device_token': deviceToken,
    });

    if (result['success'] == true) {
      final data = result['data'];
      if (data is Map<String, dynamic>) {
        currentSubscription.value = PushSubscription.fromJson(data);
      }
      isLoading.value = false;
      return true;
    } else {
      error.value = result['error'] ?? 'Erreur lors de l\'enregistrement';
      isLoading.value = false;
      Get.snackbar('Erreur', error.value);
      return false;
    }
  }
}
