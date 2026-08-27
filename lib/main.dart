import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_config.dart';
import 'core/db/app_database.dart';
import 'core/models/models.dart';
import 'core/repositories/repositories.dart';
import 'core/services/auth_service.dart';
import 'core/services/license_service.dart';
import 'core/services/sync_service.dart';
import 'ui/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await AppDatabase.open(AppConfig.defaultTenantId);
  final users = UserRepository(db);
  final patients = PatientRepository(db);
  final doctors = DoctorRepository(db);
  final appointments = AppointmentRepository(db);
  final prescriptions = PrescriptionRepository(db);
  final payments = PaymentRepository(db);

  final auth = AuthService(users);
  await auth.ensureSeedAdmin();

  final license = LicenseService(
    tenantId: AppConfig.defaultTenantId,
    licenseServerUrl: AppConfig.licenseServerUrl,
  );
  await license.initialize();

  final sync = SyncService(
    supabaseUrl: AppConfig.supabaseUrl,
    supabaseAnonKey: AppConfig.supabaseAnonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: db),
        Provider.value(value: users),
        Provider.value(value: patients),
        Provider.value(value: doctors),
        Provider.value(value: appointments),
        Provider.value(value: prescriptions),
        Provider.value(value: payments),
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: license),
        Provider.value(value: sync),
      ],
      child: const ClinicApp(),
    ),
  );
}

class ClinicApp extends StatelessWidget {
  const ClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AiService(endpoint: AppConfig.aiEndpoint),
      child: MaterialApp(
        title: AppConfig.appName,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const DefaultTabController(
          length: 5,
          child: HomeShell(),
        ),
      ),
    );
  }
}
