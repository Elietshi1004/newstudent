import 'package:get_storage/get_storage.dart';

class StorageService {
  static final GetStorage _storage = GetStorage();
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  // Initialisation
  static Future<void> init() async {
    await GetStorage.init();
  }

  // Gestion du token d'accès
  static Future<void> saveToken(String token) async {
    await _storage.write(_tokenKey, token);
  }

  static String? getToken() {
    return _storage.read(_tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.remove(_tokenKey);
  }

  // Gestion du refresh token
  static Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(_refreshTokenKey, refreshToken);
  }

  static String? getRefreshToken() {
    return _storage.read(_refreshTokenKey);
  }

  static Future<void> deleteRefreshToken() async {
    await _storage.remove(_refreshTokenKey);
  }

  // Gestion des données utilisateur
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _storage.write(_userKey, userData);
  }

  static Map<String, dynamic>? getUserData() {
    return _storage.read(_userKey);
  }

  static Future<void> deleteUserData() async {
    await _storage.remove(_userKey);
  }

  // Déconnexion complète
  static Future<void> clearAll() async {
    await _storage.erase();
  }

  // Vérifier si l'utilisateur est connecté
  static bool isLoggedIn() {
    return getToken() != null && getToken()!.isNotEmpty;
  }
}
