import 'package:shared_preferences/shared_preferences.dart';

class IntegrationSettings {
  static const String _keySupabaseUrl = 'integration_supabase_url';
  static const String _keySupabaseKey = 'integration_supabase_key';
  static const String _keyAiEndpoint = 'integration_ai_endpoint';
  static const String _keyLicenseServer = 'integration_license_server';
  static const String _keyPaymentGateway = 'integration_payment_gateway';
  static const String _keyPaymentPublicKey = 'integration_payment_public_key';
  static const String _keyPaymentSecretKey = 'integration_payment_secret_key';
  static const String _keyPollingInterval = 'integration_polling_interval';
  static const String _keyAutoSync = 'integration_auto_sync';
  static const String _keyNotificationsEnabled = 'integration_notifications_enabled';

  final SharedPreferences prefs;

  IntegrationSettings({required this.prefs});

  String get supabaseUrl => prefs.getString(_keySupabaseUrl) ?? '';
  String get supabaseAnonKey => prefs.getString(_keySupabaseKey) ?? '';
  String get aiEndpoint => prefs.getString(_keyAiEndpoint) ?? '';
  String get licenseServerUrl => prefs.getString(_keyLicenseServer) ?? '';
  String get paymentGateway => prefs.getString(_keyPaymentGateway) ?? 'none';
  String get paymentPublicKey => prefs.getString(_keyPaymentPublicKey) ?? '';
  String get paymentSecretKey => prefs.getString(_keyPaymentSecretKey) ?? '';
  int get pollingInterval => prefs.getInt(_keyPollingInterval) ?? 30;
  bool get autoSyncEnabled => prefs.getBool(_keyAutoSync) ?? true;
  bool get notificationsEnabled => prefs.getBool(_keyNotificationsEnabled) ?? true;

  Future<void> setSupabaseUrl(String value) async => await prefs.setString(_keySupabaseUrl, value);
  Future<void> setSupabaseAnonKey(String value) async => await prefs.setString(_keySupabaseKey, value);
  Future<void> setAiEndpoint(String value) async => await prefs.setString(_keyAiEndpoint, value);
  Future<void> setLicenseServerUrl(String value) async => await prefs.setString(_keyLicenseServer, value);
  Future<void> setPaymentGateway(String value) async => await prefs.setString(_keyPaymentGateway, value);
  Future<void> setPaymentPublicKey(String value) async => await prefs.setString(_keyPaymentPublicKey, value);
  Future<void> setPaymentSecretKey(String value) async => await prefs.setString(_keyPaymentSecretKey, value);
  Future<void> setPollingInterval(int value) async => await prefs.setInt(_keyPollingInterval, value);
  Future<void> setAutoSyncEnabled(bool value) async => await prefs.setBool(_keyAutoSync, value);
  Future<void> setNotificationsEnabled(bool value) async => await prefs.setBool(_keyNotificationsEnabled, value);

  bool get isSupabaseConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  bool get isAiConfigured => aiEndpoint.isNotEmpty;
  bool get isLicenseConfigured => licenseServerUrl.isNotEmpty;
  bool get isPaymentConfigured => paymentGateway != 'none' && paymentPublicKey.isNotEmpty;
  bool get hasAnyIntegration => isSupabaseConfigured || isAiConfigured || isLicenseConfigured || isPaymentConfigured;

  Map<String, dynamic> toMap() => {
    'supabaseUrl': supabaseUrl,
    'supabaseAnonKey': supabaseAnonKey,
    'aiEndpoint': aiEndpoint,
    'licenseServerUrl': licenseServerUrl,
    'paymentGateway': paymentGateway,
    'paymentPublicKey': paymentPublicKey,
    'pollingInterval': pollingInterval,
    'autoSyncEnabled': autoSyncEnabled,
    'notificationsEnabled': notificationsEnabled,
  };
}
