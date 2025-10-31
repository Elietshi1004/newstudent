import 'package:get/get.dart';
import '../models/role.dart';
import '../services/api_service.dart';

class RolesController extends GetxController {
  final RxList<Role> roles = <Role>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRoles();
  }

  Future<void> fetchRoles() async {
    isLoading.value = true;
    error.value = '';

    final result = await ApiService.getRequest('/api/roles/');

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

      roles.value = data.map((json) => Role.fromJson(json)).toList();
    } else {
      error.value = result['error'] ?? 'Erreur lors du chargement';
      Get.snackbar('Erreur', error.value);
    }

    isLoading.value = false;
  }
}
