import 'package:get/get.dart';
import 'package:newstudent/utils/Setting.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final RxMap<String, dynamic> userData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    isLoggedIn.value = AuthService.isLoggedIn();
    if (isLoggedIn.value) {
      userData.value = AuthService.getUserData() ?? {};
    }
  }

  // Restaurer la session au démarrage de l'app
  Future<void> restoreSession() async {
    isLoading.value = true;
    final sessionRestored = await AuthService.restoreSession();
    if (sessionRestored) {
      isLoggedIn.value = true;
      userData.value = AuthService.getUserData() ?? {};
    } else {
      isLoggedIn.value = false;
      // Optionnel : nettoyer les données invalides
      await AuthService.logout();
    }
    isLoading.value = false;
  }

  Future<bool> signup({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    isLoading.value = true;
    try {
      final result = await AuthService.signup(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      if (result['success'] == true) {
        await _fetchUserData();
        isLoggedIn.value = true;
        isLoading.value = false;
        return true;
      } else {
        Get.snackbar(
          'Erreur',
          result['error'] ?? 'Erreur lors de l\'inscription',
        );
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Erreur', 'Erreur lors de l\'inscription: $e');
      return false;
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      final result = await AuthService.login(
        username: username,
        password: password,
      );

      if (result['success'] == true) {
        await _fetchUserData();
        isLoggedIn.value = true;
        isLoading.value = false;
        return true;
      } else {
        Get.snackbar('Erreur', result['error'] ?? 'Identifiants invalides');
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      printDebug("Erreur lors de la connexion: $e");
      isLoading.value = false;
      Get.snackbar('Erreur', 'Erreur lors de la connexion: $e');
      return false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    await AuthService.logout();
    isLoggedIn.value = false;
    userData.clear();
    isLoading.value = false;
    Get.offAllNamed('/login');
  }

  Future<void> _fetchUserData() async {
    final data = AuthService.getUserData();
    if (data != null) {
      userData.value = data;
    }
  }

  void refreshUserData() {
    _fetchUserData();
  }
}
