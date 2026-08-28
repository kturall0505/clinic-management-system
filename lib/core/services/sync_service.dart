import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../exceptions/app_exception.dart';

enum SyncStatus { idle, syncing, success, failed }

class SyncService {
  SyncService({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.tenantId,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String? tenantId;
  final http.Client _client;

  SyncStatus _lastStatus = SyncStatus.idle;
  String? _lastError;
  DateTime? _lastSyncTime;

  SyncStatus get lastStatus => _lastStatus;
  String? get lastError => _lastError;
  DateTime? get lastSyncTime => _lastSyncTime;

  Future<bool> syncAll() async {
    if (supabaseUrl.isEmpty || tenantId == null) {
      _lastStatus = SyncStatus.failed;
      _lastError = 'Supabase konfiqurasiya edilməyib';
      return false;
    }

    _lastStatus = SyncStatus.syncing;
    _lastError = null;

    try {
      await _syncWithBackend('patients');
      await _syncWithBackend('appointments');
      await _syncWithBackend('prescriptions');
      await _syncWithBackend('payments');

      _lastSyncTime = DateTime.now();
      _lastStatus = SyncStatus.success;
      debugPrint('Sync completed at $_lastSyncTime');
      return true;
    } on NetworkException catch (e) {
      _lastStatus = SyncStatus.failed;
      _lastError = e.message;
      debugPrint('Sync failed: ${e.message}');
      return false;
    } on Exception catch (e) {
      _lastStatus = SyncStatus.failed;
      _lastError = 'Sinxronizasiya xətası: $e';
      debugPrint('Sync failed: $e');
      return false;
    }
  }

  Future<bool> syncIncremental() async {
    if (supabaseUrl.isEmpty || tenantId == null) {
      return false;
    }

    final lastSync = _lastSyncTime;
    if (lastSync == null) {
      return syncAll();
    }

    _lastStatus = SyncStatus.syncing;
    _lastError = null;

    try {
      await _syncWithBackend('patients', since: lastSync.toIso8601String());
      await _syncWithBackend('appointments', since: lastSync.toIso8601String());
      await _syncWithBackend('prescriptions', since: lastSync.toIso8601String());
      await _syncWithBackend('payments', since: lastSync.toIso8601String());

      _lastSyncTime = DateTime.now();
      _lastStatus = SyncStatus.success;
      debugPrint('Incremental sync completed at $_lastSyncTime');
      return true;
    } on Exception catch (e) {
      _lastStatus = SyncStatus.failed;
      _lastError = 'İnkremental sinxronizasiya xətası: $e';
      debugPrint('Incremental sync failed: $e');
      return false;
    }
  }

  Future<void> _syncWithBackend(String table, {String? since}) async {
    final body = {'tenant_id': tenantId};
    if (since != null) {
      body['since'] = since;
    }

    final uri = Uri.parse('$supabaseUrl/rest/v1/rpc/sync_$table');
    final response = await _client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'apikey': supabaseAnonKey,
            'Authorization': 'Bearer $supabaseAnonKey',
            'Prefer': 'return=minimal',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw NetworkException('$table sinxronizasiya uğursuz: ${response.statusCode}');
    }
  }

  Future<bool> checkConnection() async {
    if (supabaseUrl.isEmpty) return false;
    try {
      final response = await _client
          .get(Uri.parse(supabaseUrl))
          .timeout(const Duration(seconds: 10));
      return response.statusCode >= 200 && response.statusCode < 300;
    } on Exception catch (_) {
      return false;
    }
  }
}
