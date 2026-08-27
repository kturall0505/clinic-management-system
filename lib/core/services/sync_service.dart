import 'dart:convert';
import 'package:http/http.dart' as http;

class SyncService {
  SyncService({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String supabaseUrl;
  final String supabaseAnonKey;
  final http.Client _client;

  Future<void> syncPatients(String tenantId) async {
    if (supabaseUrl.isEmpty) return;
    try {
      await _client
          .post(
            Uri.parse('$supabaseUrl/rest/v1/rpc/sync_patients'),
            headers: {
              'Content-Type': 'application/json',
              'apikey': supabaseAnonKey,
              'Authorization': 'Bearer $supabaseAnonKey',
            },
            body: jsonEncode({'tenant_id': tenantId}),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {}
  }

  Future<void> syncAppointments(String tenantId) async {
    if (supabaseUrl.isEmpty) return;
    try {
      await _client
          .post(
            Uri.parse('$supabaseUrl/rest/v1/rpc/sync_appointments'),
            headers: {
              'Content-Type': 'application/json',
              'apikey': supabaseAnonKey,
              'Authorization': 'Bearer $supabaseAnonKey',
            },
            body: jsonEncode({'tenant_id': tenantId}),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {}
  }
}
