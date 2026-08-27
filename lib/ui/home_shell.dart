import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/repositories/repositories.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/license_service.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/payment_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/ai_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/doctors_screen.dart';
import 'screens/patients_screen.dart';
import 'screens/appointments_screen.dart';
import 'screens/assistant_screen.dart';
import 'screens/license_lock_screen.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final license = context.watch<LicenseService>();
    final auth = context.watch<AuthService>();

    if (license.isExpired) {
      return const LicenseLockScreen();
    }

    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tibb Klinika'),
        centerTitle: false,
        actions: [
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
    final theme = Theme.of(context);
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
          icon: Icon(Icons.smart_toy_rounded),
          label: 'Assistent',
        ),
      ],
    );
  }
}
