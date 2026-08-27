import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'Tibb Klinika';
  static const String defaultTenantId = 'default-clinic';
  static const String supabaseUrl = '';
  static const String supabaseAnonKey = '';
  static const String licenseServerUrl = '';
  static const String aiEndpoint = '';
  static const Duration licenseGracePeriod = Duration(hours: 24);

  static bool get isDevelopment => kDebugMode;
  static bool get isProduction => kReleaseMode;
}
