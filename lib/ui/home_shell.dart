import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/auth_service.dart';
import '../core/services/license_service.dart';
import 'screens/appointments_screen.dart';
import 'screens/assistant_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/doctors_screen.dart';
import 'screens/patients_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _titles = [
    'İdarə paneli',
    'Pasientlər',
    'Həkimlər',
    'Randevular',
    'AI Köməkçi',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final license = context.watch<LicenseService>();
    const screens = [
      DashboardScreen(),
      PatientsScreen(),
      DoctorsScreen(),
      AppointmentsScreen(),
      AssistantScreen(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          Tooltip(
            message: license.state == LicenseState.valid
                ? 'Lisenziya aktivdir'
                : 'Lisenziya yoxlaması gözlənilir',
            child: Icon(
              license.state == LicenseState.valid
                  ? Icons.verified
                  : Icons.warning_amber,
              color: license.state == LicenseState.valid
                  ? Colors.green
                  : Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Center(child: Text(auth.currentUser?.fullName ?? '')),
          IconButton(
            tooltip: 'Çıxış',
            icon: const Icon(Icons.logout),
            onPressed: auth.logout,
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                  icon: Icon(Icons.dashboard), label: Text('Panel')),
              NavigationRailDestination(
                  icon: Icon(Icons.people), label: Text('Pasientlər')),
              NavigationRailDestination(
                  icon: Icon(Icons.medical_services), label: Text('Həkimlər')),
              NavigationRailDestination(
                  icon: Icon(Icons.event), label: Text('Randevular')),
              NavigationRailDestination(
                  icon: Icon(Icons.smart_toy), label: Text('AI Köməkçi')),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: screens[_index]),
        ],
      ),
    );
  }
}
