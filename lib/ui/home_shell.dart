import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/models/models.dart';
import '../core/services/auth_service.dart';
import 'screens/appointments_screen.dart';
import 'screens/assistant_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/doctors_screen.dart';
import 'screens/patients_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  List<_ScreenEntry> _availableScreens() {
    final role = context.read<AuthService>().currentUser?.role;
    final all = _allScreens;
    if (role == null) return all;
    switch (role) {
      case UserRole.admin: return all;
      case UserRole.doctor: return [all[2], all[1], all[3], all[4]];
      case UserRole.receptionist: return [all[1], all[3], all[4]];
      case UserRole.patient: return [all[3], all[4]];
    }
  }

  @override Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final screens = _availableScreens();
    if (_index >= screens.length) _index = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(screens.isNotEmpty ? screens[_index].title : 'Klinika'),
        actions: [
          Text('${auth.currentUser?.fullName ?? ''}', style: Theme.of(context).textTheme.bodySmall),
          IconButton(icon: const Icon(Icons.logout), onPressed: auth.logout),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index.clamp(0, screens.length - 1),
            onDestinationSelected: (i) => setState(() => _index = i),
            labelType: NavigationRailLabelType.all,
            destinations: screens.map((s) => NavigationRailDestination(icon: Icon(s.icon), label: Text(s.label))).toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: screens[_index.clamp(0, screens.length - 1)].screen),
        ],
      ),
    );
  }
}

class _ScreenEntry {
  const _ScreenEntry({required this.title, required this.label, required this.icon, required this.screen});
  final String title; final String label; final IconData icon; final Widget screen;
}

const _allScreens = [
  _ScreenEntry(title: 'Dashboard', label: 'Panel', icon: Icons.dashboard, screen: DashboardScreen()),
  _ScreenEntry(title: 'Patients', label: 'Patients', icon: Icons.people, screen: PatientsScreen()),
  _ScreenEntry(title: 'Doctors', label: 'Doctors', icon: Icons.medical_services, screen: DoctorsScreen()),
  _ScreenEntry(title: 'Appointments', label: 'Appointments', icon: Icons.event, screen: AppointmentsScreen()),
  _ScreenEntry(title: 'AI Assistant', label: 'AI Assistant', icon: Icons.smart_toy, screen: AssistantScreen()),
];