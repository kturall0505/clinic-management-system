import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_config.dart';
import 'core/db/app_database.dart';
import 'core/models/models.dart';
import 'core/repositories/repositories.dart';
import 'core/services/auth_service.dart';
import 'core/services/license_service.dart';
import 'core/services/sync_service.dart';
import 'core/services/payment_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/ai_service.dart';
import 'core/services/backup_service.dart';
import 'core/services/report_service.dart';
import 'core/services/queue_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/theme/app_theme.dart';
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
  final patientMedicalInfo = PatientMedicalInfoRepository(db);
  final medicalVisits = MedicalVisitRepository(db);
  final medications = MedicationRepository(db);
  final prescriptionItems = PrescriptionItemRepository(db);
  final invoices = InvoiceRepository(db);
  final invoiceItems = InvoiceItemRepository(db);
  final auditLogs = AuditLogRepository(db);
  final queueEntries = QueueEntryRepository(db);
  final notificationsRepo = AppNotificationRepository(db);
  final reportsRepo = ReportRepository(db);
  final backupRecords = BackupRecordRepository(db);

  final auth = AuthService(users, auditLogs: auditLogs);
  await auth.ensureSeedAdmin();

  final license = LicenseService(
    tenantId: AppConfig.defaultTenantId,
    licenseServerUrl: AppConfig.licenseServerUrl,
  );
  unawaited(license.initialize());

  final sync = SyncService(
    supabaseUrl: AppConfig.supabaseUrl,
    supabaseAnonKey: AppConfig.supabaseAnonKey,
  );

  final notificationService = NotificationService(
    supabaseUrl: AppConfig.supabaseUrl,
    supabaseAnonKey: AppConfig.supabaseAnonKey,
  );
  unawaited(notificationService.initialize());

  final paymentService = PaymentService(
    supabaseUrl: AppConfig.supabaseUrl,
    supabaseAnonKey: AppConfig.supabaseAnonKey,
  );

  final backupService = BackupService(
    tenantId: AppConfig.defaultTenantId,
    supabaseUrl: AppConfig.supabaseUrl,
    supabaseAnonKey: AppConfig.supabaseAnonKey,
  );

  final reportService = ReportService(
    tenantId: AppConfig.defaultTenantId,
    patientsRepo: patients,
    doctorsRepo: doctors,
    appointmentsRepo: appointments,
    paymentsRepo: payments,
    invoicesRepo: invoices,
    visitsRepo: medicalVisits,
  );

  final queueService = QueueService(tenantId: AppConfig.defaultTenantId);

  final connectivityService = ConnectivityService();
  await connectivityService.initialize();

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
        Provider.value(value: patientMedicalInfo),
        Provider.value(value: medicalVisits),
        Provider.value(value: medications),
        Provider.value(value: prescriptionItems),
        Provider.value(value: invoices),
        Provider.value(value: invoiceItems),
        Provider.value(value: auditLogs),
        Provider.value(value: queueEntries),
        Provider.value(value: notificationsRepo),
        Provider.value(value: reportsRepo),
        Provider.value(value: backupRecords),
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: license),
        Provider.value(value: sync),
        Provider.value(value: notificationService),
        Provider.value(value: paymentService),
        Provider.value(value: backupService),
        Provider.value(value: reportService),
        Provider.value(value: queueService),
        ChangeNotifierProvider.value(value: connectivityService),
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
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('az'),
        ],
        home: const DefaultTabController(
          length: 8,
          child: HomeShell(),
        ),
      ),
    );
  }
}
