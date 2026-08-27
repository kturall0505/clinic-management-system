import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/repositories/repositories.dart';
import '../../core/models/models.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patients = context.read<PatientRepository>();
    final doctors = context.read<DoctorRepository>();
    final appointments = context.read<AppointmentRepository>();
    return FutureBuilder(
      future: Future.wait([patients.all(), doctors.all(), appointments.all()]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        final patientCount = data[0].length;
        final doctorCount = data[1].length;
        final allAppointments = data[2].cast<Appointment>();
        final now = DateTime.now();
        final todayCount = allAppointments
            .where((a) =>
                a.dateTime.year == now.year &&
                a.dateTime.month == now.month &&
                a.dateTime.day == now.day &&
                a.status == AppointmentStatus.scheduled)
            .length;
        final completedCount = allAppointments
            .where((a) => a.status == AppointmentStatus.completed)
            .length;
        final revenue = allAppointments
            .where((a) => a.status == AppointmentStatus.completed)
            .length;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatCard(
                  icon: Icons.people,
                  label: 'Pasientlər',
                  value: '$patientCount'),
              _StatCard(
                  icon: Icons.medical_services,
                  label: 'Həkimlər',
                  value: '$doctorCount'),
              _StatCard(
                  icon: Icons.event,
                  label: 'Bugünkü randevular',
                  value: '$todayCount'),
              _StatCard(
                  icon: Icons.event_note,
                  label: 'Bütün randevular',
                  value: '${allAppointments.length}'),
              _StatCard(
                  icon: Icons.check_circle,
                  label: 'Tamamlanmış',
                  value: '$completedCount'),
              _StatCard(
                  icon: Icons.attach_money,
                  label: 'Gəlir (randevu)',
                  value: '$revenue'),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 12),
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
