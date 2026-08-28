import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_config.dart';
import 'core/db/app_database.dart';
import 'core/repositories/repositories.dart';
import 'core/services/ai_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/license_service.dart';
import 'ui/home_shell.dart';
import 'ui/screens/license_lock_screen.dart';
import 'ui/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await AppDatabase.open(AppConfig.tenantId);
  final userRepository = UserRepository(db);
  final authService = AuthService(userRepository);
  await authService.ensureSeedAdmin();
  final licenseService = LicenseService(tenantId: AppConfig.tenantId, licenseServerUrl: AppConfig.licenseServerUrl);
  await licenseService.initialize();
  runApp(ClinicApp(db: db, authService: authService, licenseService: licenseService));
}

class ClinicApp extends StatelessWidget {
  const ClinicApp({required this.db, required this.authService, required this.licenseService});
  final AppDatabase db; final AuthService authService; final LicenseService licenseService;

  @override Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider.value(value: licenseService),
        Provider(create: (_) => PatientRepository(db)),
        Provider(create: (_) => DoctorRepository(db)),
        Provider(create: (_) => AppointmentRepository(db)),
        Provider(create: (_) => AiService(endpoint: AppConfig.aiEndpoint)),
      ],
      child: MaterialApp(title: 'Klinika İdarəetmə Sistemi', debugShowCheckedModeBanner: false, theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), useMaterial3: true), home: const _RootGate()),
    );
  }
}

class _RootGate extends StatelessWidget {
  const _RootGate();
  @override Widget build(BuildContext context) {
    final license = context.watch<LicenseService>();
    final auth = context.watch<AuthService>();
    if (license.state == LicenseState.graceExpired) return const LicenseLockScreen();
    if (!auth.isLoggedIn) return const LoginScreen();
    return const HomeShell();
  }
}