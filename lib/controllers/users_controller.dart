import 'package:get/get.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UsersController extends GetxController {
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final int pageSize = 10;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    isLoading.value = true;
    error.value = '';

    final result = await ApiService.getRequest('/api/users/');

    if (result['success'] == true) {
      final responseData = result['data'];
      List<dynamic> data;

      // Gérer format paginé {count, next, previous, results}
      if (responseData is Map && responseData.containsKey('results')) {
        data = responseData['results'] as List;
      } else if (responseData is List) {
        data = responseData;
      } else if (responseData is Map<String, dynamic>) {
        data = [responseData];
      } else {
        data = [];
      }

      users.value = data.map((json) => UserModel.fromJson(json)).toList();
    } else {
      error.value = result['error'] ?? 'Erreur lors du chargement';
      Get.snackbar('Erreur', error.value);
    }

    isLoading.value = false;
  }

  // Recherche
  void setSearchQuery(String query) {
    searchQuery.value = query.trim();
    currentPage.value = 1; // reset à la première page
  }

  // Pagination simple côté client
  List<UserModel> get filteredUsers {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return users;
    return users.where((u) {
      return u.username.toLowerCase().contains(q) ||
          (u.email?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  int get totalPages {
    final total = filteredUsers.length;
    return (total / pageSize).ceil().clamp(1, 1 << 30);
  }

  List<UserModel> get pagedUsers {
    final start = (currentPage.value - 1) * pageSize;
    final end = (start + pageSize).clamp(0, filteredUsers.length);
    if (start >= filteredUsers.length) return [];
    return filteredUsers.sublist(start, end);
  }

  void nextPage() {
    if (currentPage.value < totalPages) currentPage.value++;
  }

  void prevPage() {
    if (currentPage.value > 1) currentPage.value--;
  }

  Future<UserModel?> getUserById(int id) async {
    final result = await ApiService.getRequest('/api/users/$id/');
    if (result['success'] == true) {
      return UserModel.fromJson(result['data']);
    } else {
      return null;
    }
  }
}
