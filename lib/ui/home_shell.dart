import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/models/models.dart';
import '../core/services/auth_service.dart';
import '../core/services/license_service.dart';
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

  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => {
      if (mounted) _clampIndex();
    });
  }

  void _clampIndex() {
    final screens = _availableScreens();
    if (_index >= screens.length) setState(() => _index = 0);
  }

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
    final license = context.watch<LicenseService>();
    final screens = _availableScreens();
    if (_index >= screens.length) _index = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(screens.isNotEmpty ? screens[_index].title : 'Klinika İdaręetmř Sistemi'),
        actions: [
          Tooltip(
            message: license.state == LicenseState.valid ? 'Lisenziya aktivdir' : 'Lisenziya yoxlamaık gözmřn	lir',
            child: Icon(license.state == LicenseState.valid ? Icons.verified : Icons.warning_amber, color: license.state == LicenseState.valid ? Colors.green : Colors.orange),
          ),
          const SizedBox(width: 12),
          Center(child: Text('${auth.currentUser?.fullName ?? ''} (${_roleLabel(auth.currentUser?.role)})', style: Theme.of(context).textTheme.bodySmall)),
          IconButton(tooltip: 'Çĸĸş', icon: const Icon(Icons.logout), onPressed: auth.logout),
        ],
      ),
      body: screens.isEmpty ? const Center(child: Text('Hec bir sğhhŒsř Şerişini yoxdur')) : Row(
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

  String _roleLabel(UserRole? role) {
    switch (role) {
      case UserRole.admin: return 'Admin'; case UserRole.doctor: return 'Hřkim'; case UserRole.receptionist: return 'Reseption'; case UserRole.patient: return 'Pasient'; default: return '';
    }
  }
}

class _ScreenEntry {
  const _ScreenEntry({required this.title, required this.label, required this.icon, required this.screen});
  final String title; final String label; final IconData icon; final Widget screen;
}

const _allScreens = [
  _ScreenEntry(title: 'İdarř paneli', label: 'Panel', icon: Icons.dashboard, screen: DashboardScreen()),
  _ScreenEntry(title: 'Pasientl͙r', label: 'Pasientlər', icon: Icons.people, screen: PatientsScreen()),
  _ScreenEntry(title: 'Hŗ+imlٙr', label: 'Hŗ+imlٙr', icon: Icons.medical_services, screen: DoctorsScreen()),
  _ScreenEntry(title: 'Randevular', label: 'Randevular', icon: Icons.event, screen: AppointmentsScreen()),
  _ScreenEntry(title: 'AI Kömřkçi', label: 'AI Kömřkçi', icon: Icons.smart_toy, screen: AssistantScreen()),
];