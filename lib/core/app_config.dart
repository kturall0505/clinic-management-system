import 'package:flutter/foundation.dart';

class AppConfig {
  static String appName = 'Tibb Klinika';
  static String defaultTenantId = 'default-clinic';
  static String supabaseUrl = '';
  static String supabaseAnonKey = '';
  static String licenseServerUrl = '';
  static String aiEndpoint = '';
  static Duration licenseGracePeriod = const Duration(hours: 24);

  static bool get isDevelopment => kDebugMode;
  static bool get isProduction => kReleaseMode;

  static void updateFromIntegrationSettings(IntegrationSettings settings) {
    supabaseUrl = settings.supabaseUrl;
    supabaseAnonKey = settings.supabaseAnonKey;
    aiEndpoint = settings.aiEndpoint;
    licenseServerUrl = settings.licenseServerUrl;
  }
}
