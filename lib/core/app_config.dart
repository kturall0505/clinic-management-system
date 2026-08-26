/// Per-installation configuration. Each clinic gets its own tenant id and
/// license key at install time; values can be overridden at build time with
/// --dart-define.
class AppConfig {
  static const tenantId = String.fromEnvironment(
    'TENANT_ID',
    defaultValue: 'demo-clinic',
  );

  static const licenseServerUrl = String.fromEnvironment(
    'LICENSE_SERVER_URL',
    defaultValue: 'https://license.example.com/api',
  );

  static const aiEndpoint = String.fromEnvironment('AI_ENDPOINT');
}
