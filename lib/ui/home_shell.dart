import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
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

    final tabs = _getTabsForRole(auth.currentUser?.role);

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
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
        drawer: _AppDrawer(tabs: tabs),
        body: _ShellBody(tabs: tabs),
        bottomNavigationBar: _BottomNav(tabs: tabs),
      ),
    );
  }

  List<TabInfo> _getTabsForRole(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return const [
          TabInfo('Panel', Icons.dashboard_rounded, DashboardScreen()),
          TabInfo('Həkimlər', Icons.medical_services_rounded, DoctorsScreen()),
          TabInfo('Pasientlər', Icons.people_rounded, PatientsScreen()),
          TabInfo('Randevular', Icons.event_rounded, AppointmentsScreen()),
          TabInfo('Resept', Icons.medication_rounded, PrescriptionsScreen()),
          TabInfo('Faktura', Icons.receipt_long_rounded, InvoicesScreen()),
          TabInfo('Hesabat', Icons.analytics_rounded, ReportsScreen()),
          TabInfo('Assistent', Icons.smart_toy_rounded, AssistantScreen()),
        ];
      case UserRole.doctor:
        return const [
          TabInfo('Panel', Icons.dashboard_rounded, DashboardScreen()),
          TabInfo('Randevular', Icons.event_rounded, AppointmentsScreen()),
          TabInfo('Resept', Icons.medication_rounded, PrescriptionsScreen()),
          TabInfo('Hesabat', Icons.analytics_rounded, ReportsScreen()),
          TabInfo('Assistent', Icons.smart_toy_rounded, AssistantScreen()),
        ];
      case UserRole.receptionist:
        return const [
          TabInfo('Panel', Icons.dashboard_rounded, DashboardScreen()),
          TabInfo('Pasientlər', Icons.people_rounded, PatientsScreen()),
          TabInfo('Randevular', Icons.event_rounded, AppointmentsScreen()),
          TabInfo('Faktura', Icons.receipt_long_rounded, InvoicesScreen()),
          TabInfo('Növbə', Icons.queue_rounded, QueueManagementScreen()),
          TabInfo('Assistent', Icons.smart_toy_rounded, AssistantScreen()),
        ];
      case UserRole.patient:
        return const [
          TabInfo('Panel', Icons.dashboard_rounded, DashboardScreen()),
          TabInfo('Randevular', Icons.event_rounded, AppointmentsScreen()),
          TabInfo('Resept', Icons.medication_rounded, PrescriptionsScreen()),
          TabInfo('Faktura', Icons.receipt_long_rounded, InvoicesScreen()),
        ];
      default:
        return const [
          TabInfo('Panel', Icons.dashboard_rounded, DashboardScreen()),
          TabInfo('Həkimlər', Icons.medical_services_rounded, DoctorsScreen()),
          TabInfo('Pasientlər', Icons.people_rounded, PatientsScreen()),
          TabInfo('Randevular', Icons.event_rounded, AppointmentsScreen()),
          TabInfo('Resept', Icons.medication_rounded, PrescriptionsScreen()),
          TabInfo('Faktura', Icons.receipt_long_rounded, InvoicesScreen()),
          TabInfo('Hesabat', Icons.analytics_rounded, ReportsScreen()),
          TabInfo('Assistent', Icons.smart_toy_rounded, AssistantScreen()),
        ];
    }
  }
}

class TabInfo {
  final String label;
  final IconData icon;
  final Widget screen;
  const TabInfo(this.label, this.icon, this.screen);
}

class _ShellBody extends StatelessWidget {
  final List<TabInfo> tabs;
  const _ShellBody({required this.tabs});

  @override
  Widget build(BuildContext context) {
    final tab = DefaultTabController.of(context)?.index ?? 0;
    if (tab >= tabs.length) return const SizedBox.shrink();
    return tabs[tab].screen;
  }
}

class _BottomNav extends StatelessWidget {
  final List<TabInfo> tabs;
  const _BottomNav({required this.tabs});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: DefaultTabController.of(context)?.index ?? 0,
      onTap: (index) {
        if (index < tabs.length) {
          DefaultTabController.of(context)?.animateTo(index);
        }
      },
      items: tabs.map((tab) {
        return BottomNavigationBarItem(
          icon: Icon(tab.icon),
          label: tab.label,
        );
      }).toList(),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final List<TabInfo> tabs;
  const _AppDrawer({required this.tabs});

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
          ...tabs.map((tab) {
            final index = tabs.indexOf(tab);
            return ListTile(
              leading: Icon(tab.icon),
              title: Text(tab.label),
              onTap: () {
                DefaultTabController.of(context)?.animateTo(index);
                Navigator.pop(context);
              },
            );
          }),
          const Divider(),
          if (auth.currentUser?.role == UserRole.admin) ...[
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
              leading: const Icon(Icons.backup_rounded),
              title: const Text('Backup'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupScreen()));
              },
            ),
          ],
          if (auth.hasAnyRole([UserRole.admin, UserRole.receptionist])) ...[
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
          ],
          if (auth.hasAnyRole([UserRole.admin, UserRole.doctor, UserRole.receptionist])) ...[
            ListTile(
              leading: const Icon(Icons.notifications_rounded),
              title: const Text('Bildirişlər'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
              },
            ),
          ],
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
