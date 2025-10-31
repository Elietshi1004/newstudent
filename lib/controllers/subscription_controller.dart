import 'package:get/get.dart';
import '../models/subscription.dart';
import '../utils/Setting.dart';
import '../models/program.dart';
import '../services/api_service.dart';

class SubscriptionController extends GetxController {
  final RxList<Subscription> subscriptions = <Subscription>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSubscriptions();
  }

  Future<void> fetchSubscriptions() async {
    isLoading.value = true;
    error.value = '';

    final result = await ApiService.getRequest('/api/subscriptions/');

    if (result['success'] == true) {
      final responseData = result['data'];
      List<dynamic> data;

      // Gérer le format paginé Django REST Framework
      if (responseData is Map && responseData.containsKey('results')) {
        data = responseData['results'] as List;
      } else if (responseData is List) {
        data = responseData;
      } else {
        data = [];
      }

      subscriptions.value =
          data.map((json) => Subscription.fromJson(json)).toList();
      subscriptions.value =
          subscriptions
              .where(
                (subscription) =>
                    subscription.userId == Setting.authCtrl.userData['id'],
              )
              .toList();
    } else {
      error.value = result['error'] ?? 'Erreur lors du chargement';
      Get.snackbar('Erreur', error.value);
    }

    isLoading.value = false;
  }

  Future<bool> subscribeToProgram(int programId) async {
    isLoading.value = true;
    error.value = '';

    final userId = Setting.authCtrl.userData['id'];

    final result = await ApiService.postRequest('/api/subscriptions/', {
      if (userId != null) 'user': userId,
      'program': programId,
    });

    if (result['success'] == true) {
      await fetchSubscriptions(); // Rafraîchir la liste
      isLoading.value = false;
      Get.snackbar('Succès', 'Abonnement réussi');
      return true;
    } else {
      error.value = result['error'] ?? 'Erreur lors de l\'abonnement';
      isLoading.value = false;
      Get.snackbar('Erreur', error.value);
      return false;
    }
  }

  Future<bool> unsubscribeFromProgram(int subscriptionId) async {
    isLoading.value = true;
    error.value = '';

    final result = await ApiService.deleteRequest(
      '/api/subscriptions/$subscriptionId/',
    );

    if (result['success'] == true) {
      await fetchSubscriptions(); // Rafraîchir la liste
      isLoading.value = false;
      Get.snackbar('Succès', 'Désabonnement réussi');
      return true;
    } else {
      error.value = result['error'] ?? 'Erreur lors du désabonnement';
      isLoading.value = false;
      Get.snackbar('Erreur', error.value);
      return false;
    }
  }

  bool isSubscribedToProgram(int programId) {
    return subscriptions.any(
      (sub) =>
          (sub.program?.id ?? sub.programId) == programId &&
          sub.userId == Setting.authCtrl.userData['id'],
    );
  }

  List<Program> getSubscribedPrograms() {
    final pc = Setting.programCtrl;
    final List<Program> result = [];
    for (final sub in subscriptions) {
      if (sub.program != null) {
        result.add(sub.program!);
      } else if (sub.programId != null) {
        final p = pc.getProgramById(sub.programId!);
        if (p != null) result.add(p);
      }
    }
    return result;
  }

  Subscription? getSubscriptionByProgramId(int programId) {
    try {
      return subscriptions.firstWhere(
        (sub) => (sub.program?.id ?? sub.programId) == programId,
      );
    } catch (e) {
      return null;
    }
  }
}
