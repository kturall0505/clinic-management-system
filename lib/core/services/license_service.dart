import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../exceptions/app_exception.dart';

enum LicenseState { valid, graceExpired, unknown }

class LicenseService extends ChangeNotifier {
  static const String _lastCheckKey = 'license_last_success';
  static const String _firstRunKey = 'license_first_run';

  LicenseService({
    required this.tenantId,
    required this.licenseServerUrl,
    http.Client? client,
    this.gracePeriod = const Duration(hours: 24),
  }) : _client = client ?? http.Client();

  final String tenantId;
  final String licenseServerUrl;
  final Duration gracePeriod;
  final http.Client _client;

  LicenseState _state = LicenseState.unknown;
  DateTime? _lastSuccess;
  String? _lastError;

  LicenseState get state => _state;
  DateTime? get lastSuccess => _lastSuccess;
  String? get lastError => _lastError;
  bool get isExpired => _state == LicenseState.graceExpired;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_lastCheckKey);
      _lastSuccess = stored == null ? null : DateTime.tryParse(stored);

      if (_lastSuccess == null) {
        final firstRun = prefs.getString(_firstRunKey);
        if (firstRun == null) {
          await prefs.setString(_firstRunKey, DateTime.now().toIso8601String());
          _lastSuccess = DateTime.now();
        } else {
          _lastSuccess = DateTime.tryParse(firstRun);
        }
      }

      await checkNow();
    } on Exception catch (e) {
      _lastError = 'Lisenziya xidməti başladılması uğursuz oldu: $e';
      _recomputeState();
      notifyListeners();
    }
  }

  Future<void> checkNow() async {
    try {
      final succeeded = await _sendHeartbeat();
      if (succeeded) {
        _lastSuccess = DateTime.now();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastCheckKey, _lastSuccess!.toIso8601String());
        _lastError = null;
      } else {
        _lastError = 'Lisenziya serverinə qoşulmaq olmadı';
      }
    } on SocketException catch (e) {
      _lastError = 'İnternet bağlantısı yoxdur: ${e.message}';
    } on HttpException catch (e) {
      _lastError = 'HTTP xətası: ${e.message}';
    } on FormatException catch (e) {
      _lastError = 'Server cavabı düzgün deyil: ${e.message}';
    } on Exception catch (e) {
      _lastError = 'Gözlənilməz xəta: $e';
    }

    _recomputeState();
    notifyListeners();
  }

  Future<bool> validateLicenseKey(String licenseKey) async {
    if (licenseKey.isEmpty || licenseServerUrl.isEmpty) {
      return false;
    }

    try {
      final uri = Uri.parse('$licenseServerUrl/validate');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'tenantId': tenantId,
              'licenseKey': licenseKey,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final valid = body['valid'] as bool? ?? false;
        if (valid) {
          _lastSuccess = DateTime.now();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_lastCheckKey, _lastSuccess!.toIso8601String());
          _lastError = null;
          _recomputeState();
          notifyListeners();
        }
        return valid;
      }
      return false;
    } on Exception catch (e) {
      _lastError = 'Lisenziya təsdiqi xətası: $e';
      return false;
    }
  }

  Future<bool> _sendHeartbeat() async {
    if (licenseServerUrl.isEmpty) {
      _lastError = 'Lisenziya server URL-i təyin edilməyib';
      return false;
    }

    try {
      final uri = Uri.parse('$licenseServerUrl/heartbeat');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'tenantId': tenantId,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      return response.statusCode == 200;
    } on TimeoutException catch (_) {
      _lastError = 'Sorğu vaxt limitini keçdi';
      return false;
    } on Exception catch (e) {
      _lastError = 'Xəta: $e';
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

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}
