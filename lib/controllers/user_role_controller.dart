import 'package:get/get.dart';
import '../models/user_role.dart';
import '../models/role.dart';
import 'package:newstudent/utils/Setting.dart';
import '../services/api_service.dart';

class UserRoleController extends GetxController {
  final RxList<UserRole> userRoles = <UserRole>[].obs; // current user roles
  final RxList<UserRole> allUserRoles = <UserRole>[].obs; // all links (admin)
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserRoles();
  }

  Future<void> fetchUserRoles() async {
    isLoading.value = true;
    error.value = '';

    // Utiliser /api/me/ qui retourne déjà les rôles de l'utilisateur
    final result = await ApiService.getRequest('/api/me/');

    if (result['success'] == true) {
      final data = result['data'];
      if (data != null && data['roles'] is List) {
        final rolesList = data['roles'] as List;
        userRoles.value =
            rolesList.map((roleJson) {
              final roleMap = roleJson as Map<String, dynamic>;
              return UserRole(
                id: 0,
                user: data['id'] as int,
                role: roleMap['id'] as int,
              );
            }).toList();
      }
    } else {
      error.value = result['error'] ?? 'Erreur lors du chargement';
    }

    isLoading.value = false;
  }

  Future<void> fetchAllUserRoles() async {
    isLoading.value = true;
    error.value = '';

    final result = await ApiService.getRequest('/api/userroles/');
    if (result['success'] == true) {
      final responseData = result['data'];
      List<dynamic> data;
      if (responseData is Map && responseData.containsKey('results')) {
        data = responseData['results'] as List;
      } else if (responseData is List) {
        data = responseData;
      } else if (responseData is Map<String, dynamic>) {
        data = [responseData];
      } else {
        data = [];
      }

      allUserRoles.value = data.map((json) => UserRole.fromJson(json)).toList();
    } else {
      error.value = result['error'] ?? 'Erreur lors du chargement';
      Get.snackbar('Erreur', error.value);
    }
    isLoading.value = false;
  }

  List<Role> getRolesForUser(int userId) {
    final rolesCtrl = Setting.rolesCtrl;
    final roleIds =
        allUserRoles
            .where((ur) => ur.user == userId)
            .map((ur) => ur.role)
            .toSet();
    return rolesCtrl.roles.where((r) => roleIds.contains(r.id)).toList();
  }

  // Vérifier si l'utilisateur a un rôle spécifique
  bool hasRole(String roleName) {
    final rolesCtrl = Setting.rolesCtrl;
    final roleIds = userRoles.map((ur) => ur.role).toSet();
    return rolesCtrl.roles.any(
      (r) =>
          roleIds.contains(r.id) &&
          r.name.toLowerCase() == roleName.toLowerCase(),
    );
  }

  bool isAdmin() => hasRole('Admin');
  bool isModerator() => hasRole('Modérateur');
  bool isPubliant() => hasRole('Publiant');
  bool isStudent() => hasRole('Étudiant');

  List<String> get roleNames {
    final rolesCtrl = Setting.rolesCtrl;
    final roleIds = userRoles.map((ur) => ur.role).toSet();
    return rolesCtrl.roles
        .where((r) => roleIds.contains(r.id))
        .map((r) => r.name)
        .toList();
  }

  Future<bool> assignRoleToUser({
    required int userId,
    required int roleId,
  }) async {
    isLoading.value = true;

    final result = await ApiService.postRequest('/api/userroles/', {
      'user': userId,
      'role': roleId,
    });

    if (result['success'] == true) {
      await fetchAllUserRoles();
      isLoading.value = false;
      Get.snackbar('Succès', 'Rôle attribué avec succès');
      return true;
    } else {
      isLoading.value = false;
      Get.snackbar(
        'Erreur',
        result['error'] ?? "Erreur lors de l'attribution du rôle",
      );
      return false;
    }
  }

  Future<bool> removeRoleFromUser(int userRoleId) async {
    isLoading.value = true;

    final result = await ApiService.deleteRequest(
      '/api/userroles/$userRoleId/',
    );

    if (result['success'] == true) {
      await fetchAllUserRoles();
      isLoading.value = false;
      Get.snackbar('Succès', 'Rôle retiré avec succès');
      return true;
    } else {
      isLoading.value = false;
      Get.snackbar(
        'Erreur',
        result['error'] ?? 'Erreur lors de la suppression du rôle',
      );
      return false;
    }
  }

  Future<bool> assignRoleByNameToUser({
    required int userId,
    required String roleName,
    required List<Role> availableRoles,
  }) async {
    final role = availableRoles.firstWhere(
      (r) => r.name.toLowerCase() == roleName.toLowerCase(),
      orElse: () => throw Exception('Rôle $roleName introuvable'),
    );

    return await assignRoleToUser(userId: userId, roleId: role.id);
  }

  Future<bool> assignMultipleRolesToUser({
    required int userId,
    required List<int> roleIds,
  }) async {
    isLoading.value = true;
    bool allSuccess = true;

    for (final roleId in roleIds) {
      final result = await ApiService.postRequest('/api/userroles/', {
        'user': userId,
        'role': roleId,
      });

      if (result['success'] != true) {
        allSuccess = false;
      }
    }

    if (allSuccess) {
      await fetchAllUserRoles();
      isLoading.value = false;
      Get.snackbar('Succès', 'Rôles attribués avec succès');
      return true;
    } else {
      isLoading.value = false;
      Get.snackbar('Erreur', "Certains rôles n'ont pas pu être attribués");
      return false;
    }
  }
}
