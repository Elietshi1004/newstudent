import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:newstudent/utils/Setting.dart';
import '../models/attachment.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AttachmentService {
  static Future<Map<String, dynamic>> uploadAttachment({
    required int newsId,
    required File file,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/api/attachments/');
    final token = StorageService.getToken();

    final request = http.MultipartRequest('POST', uri);
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    printDebug("upload attachment request: $request");

    request.fields['news'] = newsId.toString();
    final mimeType = _detectMimeType(file.path);
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: mimeType,
      ),
    );

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      printDebug("upload attachment response: ${response.body}");
      final data = jsonDecode(response.body);
      printDebug("upload attachment data: $data");
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data':
              data is Map<String, dynamic> ? Attachment.fromJson(data) : data,
        };
      } else {
        return {
          'success': false,
          'error': data['detail'] ?? 'Erreur lors de l\'upload',
        };
      }
    } catch (e) {
      printDebug("upload attachment error: $e");
      return {'success': false, 'error': 'Réponse invalide du serveur'};
    }
  }

  static MediaType? _detectMimeType(String path) {
    // Best-effort minimal detection based on extension
    final lower = path.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    } else if (lower.endsWith('.png')) {
      return MediaType('image', 'png');
    } else if (lower.endsWith('.gif')) {
      return MediaType('image', 'gif');
    }
    return null;
  }
}
