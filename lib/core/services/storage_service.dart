import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class StorageService {
  StorageService({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String supabaseUrl;
  final String supabaseAnonKey;
  final http.Client _client;

  Future<String?> uploadFile(String bucket, String path, File file) async {
    if (supabaseUrl.isEmpty) return null;
    try {
      final bytes = await file.readAsBytes();
      final response = await _client
          .post(
            Uri.parse('$supabaseUrl/storage/v1/object/$bucket/$path'),
            headers: {
              'Content-Type': 'application/octet-stream',
              'apikey': supabaseAnonKey,
              'Authorization': 'Bearer $supabaseAnonKey',
            },
            body: bytes,
          )
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) return '$supabaseUrl/storage/v1/object/public/$bucket/$path';
    } catch (_) {}
    return null;
  }

  Future<String?> uploadBase64(String bucket, String path, String base64Data) async {
    if (supabaseUrl.isEmpty) return null;
    try {
      final bytes = base64Decode(base64Data);
      final response = await _client
          .post(
            Uri.parse('$supabaseUrl/storage/v1/object/$bucket/$path'),
            headers: {
              'Content-Type': 'application/octet-stream',
              'apikey': supabaseAnonKey,
              'Authorization': 'Bearer $supabaseAnonKey',
            },
            body: bytes,
          )
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) return '$supabaseUrl/storage/v1/object/public/$bucket/$path';
    } catch (_) {}
    return null;
  }
}
