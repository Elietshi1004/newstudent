import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newstudent/utils/Setting.dart';
import 'auth_service.dart';

class ApiService {
  // URL de base du backend (à modifier selon votre configuration)
  // static const String baseUrl = 'http://127.0.0.1:8000';
  static const String baseUrl = "http://172.18.197.188:8000";

  // Méthode générique pour les requêtes GET
  static Future<Map<String, dynamic>> getRequest(String endpoint) async {
    try {
      final token = AuthService.getToken();
      if (token == null) {
        return {'success': false, 'error': 'Non authentifié'};
      }
      printDebug("get request baseUrl: $baseUrl$endpoint");

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      printDebug("get request data $endpoint: $data");

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else if (response.statusCode == 401) {
        // Token expiré, essayer de rafraîchir
        final refreshed = await AuthService.refreshToken();
        if (refreshed) {
          return getRequest(endpoint); // Réessayer la requête
        } else {
          return {'success': false, 'error': 'Session expirée'};
        }
      } else {
        return {'success': false, 'error': data['detail'] ?? 'Erreur inconnue'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur réseau: $e'};
    }
  }

  // Méthode générique pour les requêtes POST
  static Future<Map<String, dynamic>> postRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final token = AuthService.getToken();
      if (token == null) {
        return {'success': false, 'error': 'Non authentifié'};
      }
      printDebug("post request baseUrl: $baseUrl$endpoint");
      printDebug("post request body: $body");

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      printDebug("post request data: $data");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else if (response.statusCode == 401) {
        final refreshed = await AuthService.refreshToken();
        if (refreshed) {
          return postRequest(endpoint, body);
        } else {
          return {'success': false, 'error': 'Session expirée'};
        }
      } else {
        return {'success': false, 'error': data['detail'] ?? 'Erreur inconnue'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur réseau: $e'};
    }
  }

  // Méthode générique pour les requêtes PUT
  static Future<Map<String, dynamic>> putRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final token = AuthService.getToken();
      if (token == null) {
        return {'success': false, 'error': 'Non authentifié'};
      }
      printDebug("put request baseUrl: $baseUrl$endpoint");
      printDebug("put request body: $body");
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      printDebug("put request data: $data");
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else if (response.statusCode == 401) {
        final refreshed = await AuthService.refreshToken();
        if (refreshed) {
          return putRequest(endpoint, body);
        } else {
          return {'success': false, 'error': 'Session expirée'};
        }
      } else {
        return {'success': false, 'error': data['detail'] ?? 'Erreur inconnue'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur réseau: $e'};
    }
  }

  // Méthode générique pour les requêtes DELETE
  static Future<Map<String, dynamic>> deleteRequest(String endpoint) async {
    try {
      final token = AuthService.getToken();
      if (token == null) {
        return {'success': false, 'error': 'Non authentifié'};
      }
      printDebug("delete request baseUrl: $baseUrl$endpoint");
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return {'success': true};
      } else if (response.statusCode == 401) {
        final refreshed = await AuthService.refreshToken();
        if (refreshed) {
          return deleteRequest(endpoint);
        } else {
          return {'success': false, 'error': 'Session expirée'};
        }
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'error': data['detail'] ?? 'Erreur inconnue'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur réseau: $e'};
    }
  }
}
