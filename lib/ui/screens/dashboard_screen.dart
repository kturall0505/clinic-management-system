import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/repositories/repositories.dart';
import '../../core/models/models.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _retryKey = 0;

  @override
  Widget build(BuildContext context) {
    final patientsRepo = context.read<PatientRepository>();
    final doctorsRepo = context.read<DoctorRepository>();
    final appointmentsRepo = context.read<AppointmentRepository>();

    return FutureBuilder<List<dynamic>>(
      key: ValueKey(_retryKey),
      future: Future.wait([
        patientsRepo.all(),
        doctorsRepo.all(),
        appointmentsRepo.all(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingState();
        }

        if (snapshot.hasError) {
          return _ErrorState(
            message: 'Məlumatlar yüklənərkən xəta baş verdi',
            onRetry: () {
              setState(() => _retryKey++);
            },
          );
        }

        final patients = snapshot.data?[0] as List<Patient>? ?? [];
        final doctors = snapshot.data?[1] as List<Doctor>? ?? [];
        final appointments = snapshot.data?[2] as List<Appointment>? ?? [];

        if (patients.isEmpty && doctors.isEmpty && appointments.isEmpty) {
          return _EmptyState(
            icon: Icons.dashboard_outlined,
            title: 'Panel boşdur',
            message: 'Başlanğıc üçün pasient və ya həkim əlavə edin',
            actionLabel: 'Pasient əlavə et',
            onAction: () {
              DefaultTabController.of(context)?.animateTo(2);
            },
          );
        }

        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final todayEnd = todayStart.add(const Duration(days: 1));

        final todayAppointments = appointments.where((a) {
          return a.dateTime.isAfter(todayStart) && a.dateTime.isBefore(todayEnd);
        }).toList();

        final scheduledToday = todayAppointments
            .where((a) => a.status == AppointmentStatus.scheduled)
            .length;

        final completedAppointments = appointments
            .where((a) => a.status == AppointmentStatus.completed)
            .length;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final crossAxisCount = isWide ? 3 : (constraints.maxWidth >= 600 ? 2 : 1);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              child: Wrap(
                spacing: AppTheme.spacing3,
                runSpacing: AppTheme.spacing3,
                children: [
                  _StatCard(
                    icon: Icons.people_rounded,
                    label: 'Pasientlər',
                    value: '${patients.length}',
                    color: theme.colorScheme.primary,
                  ),
                  _StatCard(
                    icon: Icons.medical_services_rounded,
                    label: 'Həkimlər',
                    value: '${doctors.length}',
                    color: theme.colorScheme.secondary,
                  ),
                  _StatCard(
                    icon: Icons.event_rounded,
                    label: 'Bugünkü randevular',
                    value: '$scheduledToday',
                    color: theme.colorScheme.tertiary,
                  ),
                  _StatCard(
                    icon: Icons.event_note_rounded,
                    label: 'Bütün randevular',
                    value: '${appointments.length}',
                    color: theme.colorScheme.primaryContainer,
                  ),
                  _StatCard(
                    icon: Icons.check_circle_rounded,
                    label: 'Tamamlanmış',
                    value: '$completedAppointments',
                    color: AppTheme.success,
                  ),
                  _StatCard(
                    icon: Icons.calendar_today_rounded,
                    label: 'Bugün ümumi',
                    value: '${todayAppointments.length}',
                    color: AppTheme.warning,
                  ),
                ],
              ),
            );
          },
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
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 400;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppTheme.borderRadiusMedium,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppTheme.spacing3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing8),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              message,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing4),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Yenidən cəhd et'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing2),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppTheme.spacing4),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
