import 'package:flutter/material.dart';
import '../../core/models/models.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int patientCount = 0; int doctorCount = 0; int todayCount = 0;
  List<Appointment> allAppointments = [];

  @override void initState() { super.initState(); }

  @override Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(spacing: 16, runSpacing: 16, children: [
                _StatCard(icon: Icons.people, label: 'Patients', value: '\$patientCount'),
                _StatCard(icon: Icons.medical_services, label: 'Doctors', value: '\$doctorCount'),
                _StatCard(icon: Icons.event, label: "Today's Appointments", value: '\$todayCount'),
                _StatCard(icon: Icons.event_note, label: 'Total Appointments', value: '\${allAppointments.length}'),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value});
  final IconData icon; final String label; final String value;

  @override Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(padding: const EdgeInsets.all(20), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        )),
      ),
    );
  }
}