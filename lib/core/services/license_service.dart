import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum LicenseState { valid, graceExpired, unknown }

class LicenseService extends ChangeNotifier {
  LicenseService({
    required this.tenantId,
    required this.licenseServerUrl,
    http.Client? client,
    this.gracePeriod = const Duration(hours: 24),
  }) : _client = client ?? http.Client();

  static const _lastCheckKey = 'license_last_success';
  static const _firstRunKey = 'license_first_run';

  final String tenantId;
  final String licenseServerUrl;
  final Duration gracePeriod;
  final http.Client _client;

  LicenseState _state = LicenseState.unknown;
  DateTime? _lastSuccess;

  LicenseState get state => _state;
  DateTime? get lastSuccess => _lastSuccess;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_lastCheckKey);
    _lastSuccess = stored == null ? null : DateTime.tryParse(stored);
    if (_lastSuccess == null) {
      final firstRun = prefs.getString(_firstRunKey);
      if (firstRun == null) {
        await prefs.setString(
            _firstRunKey, DateTime.now().toIso8601String());
        _lastSuccess = DateTime.now();
      } else {
        _lastSuccess = DateTime.tryParse(firstRun);
      }
    }
    await checkNow();
  }

  Future<void> checkNow() async {
    final succeeded = await _sendHeartbeat();
    if (succeeded) {
      _lastSuccess = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastCheckKey, _lastSuccess!.toIso8601String());
    }
    _recomputeState();
    notifyListeners();
  }

  Future<bool> _sendHeartbeat() async {
    try {
      final response = await _client
          .post(
            Uri.parse('$licenseServerUrl/heartbeat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'tenantId': tenantId,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void _recomputeState() {
    final last = _lastSuccess;
    if (last == null) {
      _state = LicenseState.graceExpired;
    } else if (DateTime.now().difference(last) > gracePeriod) {
      _state = LicenseState.graceExpired;
    } else {
      _state = LicenseState.valid;
    }
  }
}
