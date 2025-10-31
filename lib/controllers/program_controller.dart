import 'package:get/get.dart';
import '../models/program.dart';
import '../services/api_service.dart';

class ProgramController extends GetxController {
  final RxList<Program> programs = <Program>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPrograms();
  }

  Future<void> fetchPrograms() async {
    isLoading.value = true;
    error.value = '';

    final result = await ApiService.getRequest('/api/programs/');

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

      programs.value = data.map((json) => Program.fromJson(json)).toList();
    } else {
      error.value = result['error'] ?? 'Erreur lors du chargement';
      Get.snackbar('Erreur', error.value);
    }

    isLoading.value = false;
  }

  Future<bool> createProgram({
    required String name,
    required String code,
  }) async {
    isLoading.value = true;
    error.value = '';

    final result = await ApiService.postRequest('/api/programs/', {
      'name': name,
      'code': code,
    });

    if (result['success'] == true) {
      await fetchPrograms(); // Rafraîchir la liste
      isLoading.value = false;
      return true;
    } else {
      error.value = result['error'] ?? 'Erreur lors de la création';
      isLoading.value = false;
      Get.snackbar('Erreur', error.value);
      return false;
    }
  }

  Future<bool> updateProgram(
    int id, {
    required String name,
    required String code,
  }) async {
    isLoading.value = true;
    error.value = '';

    final result = await ApiService.putRequest('/api/programs/$id/', {
      'name': name,
      'code': code,
    });

    if (result['success'] == true) {
      await fetchPrograms(); // Rafraîchir la liste
      isLoading.value = false;
      return true;
    } else {
      error.value = result['error'] ?? 'Erreur lors de la mise à jour';
      isLoading.value = false;
      Get.snackbar('Erreur', error.value);
      return false;
    }
  }

  Future<bool> deleteProgram(int id) async {
    isLoading.value = true;
    error.value = '';

    final result = await ApiService.deleteRequest('/api/programs/$id/');

    if (result['success'] == true) {
      await fetchPrograms(); // Rafraîchir la liste
      isLoading.value = false;
      return true;
    } else {
      error.value = result['error'] ?? 'Erreur lors de la suppression';
      isLoading.value = false;
      Get.snackbar('Erreur', error.value);
      return false;
    }
  }

  Program? getProgramById(int id) {
    try {
      return programs.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
