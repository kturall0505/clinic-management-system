import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/models.dart';
import '../repositories/repositories.dart';

class AuditLogService {
  AuditLogService({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.auditLogs,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String supabaseUrl;
  final String supabaseAnonKey;
  final AuditLogRepository auditLogs;
  final http.Client _client;

  Future<void> log({
    required String userId,
    required String userName,
    required UserRole userRole,
    required AuditAction action,
    required String entityType,
    String? entityId,
    String? entityName,
    Map<String, Object?>? changes,
  }) async {
    try {
      final log = AuditLog.create(
        userId: userId,
        userName: userName,
        userRole: userRole,
        action: action,
        entityType: entityType,
        entityId: entityId,
        entityName: entityName,
        changes: changes,
      );
      await auditLogs.save(log);

      if (supabaseUrl.isNotEmpty) {
        await _client
            .post(
              Uri.parse('$supabaseUrl/rest/v1/audit_logs'),
              headers: {
                'Content-Type': 'application/json',
                'apikey': supabaseAnonKey,
                'Authorization': 'Bearer $supabaseAnonKey',
                'Prefer': 'return=minimal',
              },
              body: jsonEncode(log.toMap()),
            )
            .timeout(const Duration(seconds: 10));
      }
    } on Exception catch (_) {}
  }
}
