import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newstudent/utils/Setting.dart';
import 'storage_service.dart';
import 'api_service.dart';

class AuthService {
  // Inscription
  static Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/signup/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Sauvegarder les tokens retournés par le backend
        await StorageService.saveToken(data['access']);
        await StorageService.saveRefreshToken(data['refresh']);

        // Sauvegarder les données utilisateur retournées
        await StorageService.saveUserData({
          'username': data['username'],
          'email': data['email'],
        });

        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Erreur lors de l\'inscription',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur réseau: $e'};
    }
  }

  // Connexion
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/token/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Sauvegarder les tokens
        await StorageService.saveToken(data['access']);
        await StorageService.saveRefreshToken(data['refresh']);

        // Obtenir les infos utilisateur
        await _fetchUserData(data['access']);

        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': data['detail'] ?? 'Identifiants invalides',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur réseau: $e'};
    }
  }

  // Rafraîchir le token
  static Future<bool> refreshToken() async {
    try {
      final refreshToken = StorageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await StorageService.saveToken(data['access']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Récupérer les infos utilisateur
  static Future<void> _fetchUserData(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/me/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        await StorageService.saveUserData(userData);
      }
    } catch (e) {
      printDebug('Erreur lors de la récupération des infos utilisateur: $e');
      // Ignore les erreurs
    }
  }

  // Restaurer la session au démarrage
  static Future<bool> restoreSession() async {
    final token = StorageService.getToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    // Vérifier si le token est valide en testant /api/me/
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/me/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        await StorageService.saveUserData(userData);
        return true;
      } else if (response.statusCode == 401) {
        // Token expiré, essayer de le rafraîchir
        return await refreshToken();
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Obtenir le token actuel
  static String? getToken() {
    return StorageService.getToken();
  }

  // Obtenir les données utilisateur
  static Map<String, dynamic>? getUserData() {
    return StorageService.getUserData();
  }

  // Déconnexion
  static Future<void> logout() async {
    await StorageService.clearAll();
  }

  // Vérifier si connecté
  static bool isLoggedIn() {
    return StorageService.isLoggedIn();
  }
}
