import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/repositories/repositories.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/license_service.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/doctors_screen.dart';
import 'screens/patients_screen.dart';
import 'screens/appointments_screen.dart';
import 'screens/prescriptions_screen.dart';
import 'screens/invoices_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/assistant_screen.dart';
import 'screens/license_lock_screen.dart';
import 'screens/users_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/audit_log_screen.dart';
import 'screens/queue_management_screen.dart';
import 'screens/medical_history_screen.dart';
import 'screens/file_upload_screen.dart';
import 'screens/backup_screen.dart';
import 'screens/notifications_screen.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final license = context.watch<LicenseService>();
    final auth = context.watch<AuthService>();
    final connectivity = context.watch<ConnectivityService>();

    connectivity.onConnectionRestored = () async {
      final sync = context.read<SyncService>();
      final success = await sync.syncIncremental();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bağlantı yeniləndi, sinxronizasiya tamamlandı')),
        );
      }
    };

    if (license.isExpired) {
      return const LicenseLockScreen();
    }

    if (!auth.isLoggedIn) {
      return const SplashScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tibb Klinika'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Sinxronizasiya',
            onPressed: () async {
              final sync = context.read<SyncService>();
              final scaffold = ScaffoldMessenger.of(context);
              scaffold.showSnackBar(const SnackBar(content: Text('Sinxronizasiya başlayır...')));
              final success = await sync.syncAll();
              if (mounted) {
                scaffold.showSnackBar(SnackBar(content: Text(success ? 'Sinxronizasiya uğurla tamamlandı' : 'Sinxronizasiya uğursuz oldu')));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Çıxış',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Çıxış'),
                  content: const Text('Hesabdan çıxmaq istədiyinizə əminsiniz?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ləğv et')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Çıx')),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                context.read<AuthService>().logout();
              }
            },
          ),
        ],
      ),
      drawer: const _AppDrawer(),
      body: const _ShellBody(),
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

class _ShellBody extends StatelessWidget {
  const _ShellBody();

  @override
  Widget build(BuildContext context) {
    final tab = DefaultTabController.of(context)?.index ?? 0;
    switch (tab) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const DoctorsScreen();
      case 2:
        return const PatientsScreen();
      case 3:
        return const AppointmentsScreen();
      case 4:
        return const PrescriptionsScreen();
      case 5:
        return const InvoicesScreen();
      case 6:
        return const ReportsScreen();
      case 7:
        return const AssistantScreen();
      default:
        return const DashboardScreen();
    }
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: DefaultTabController.of(context)?.index ?? 0,
      onTap: (index) {
        DefaultTabController.of(context)?.animateTo(index);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Panel',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medical_services_rounded),
          label: 'Həkimlər',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_rounded),
          label: 'Pasientlər',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_rounded),
          label: 'Randevular',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medication_rounded),
          label: 'Resept',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_rounded),
          label: 'Faktura',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_rounded),
          label: 'Hesabat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.smart_toy_rounded),
          label: 'Assistent',
        ),
      ],
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(Icons.person, color: Theme.of(context).colorScheme.onPrimary),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.fullName ?? 'İstifadəçi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.role.label ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded),
            title: const Text('Panel'),
            onTap: () {
              DefaultTabController.of(context)?.animateTo(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.medical_services_rounded),
            title: const Text('Həkimlər'),
            onTap: () {
              DefaultTabController.of(context)?.animateTo(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_rounded),
            title: const Text('Pasientlər'),
            onTap: () {
              DefaultTabController.of(context)?.animateTo(2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.event_rounded),
            title: const Text('Randevular'),
            onTap: () {
              DefaultTabController.of(context)?.animateTo(3);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.medication_rounded),
            title: const Text('Resept'),
            onTap: () {
              DefaultTabController.of(context)?.animateTo(4);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_rounded),
            title: const Text('Faktura'),
            onTap: () {
              DefaultTabController.of(context)?.animateTo(5);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics_rounded),
            title: const Text('Hesabat'),
            onTap: () {
              DefaultTabController.of(context)?.animateTo(6);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.smart_toy_rounded),
            title: const Text('Assistent'),
            onTap: () {
              DefaultTabController.of(context)?.animateTo(7);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.people_rounded),
            title: const Text('İstifadəçilər'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UsersScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.history_rounded),
            title: const Text('Audit Jurnalı'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AuditLogScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.queue_rounded),
            title: const Text('Növbə'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const QueueManagementScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file_rounded),
            title: const Text('Fayl Yükləmə'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FileUploadScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup_rounded),
            title: const Text('Backup'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_rounded),
            title: const Text('Bildirişlər'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_rounded),
            title: const Text('Tənzimləmələr'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }
}
