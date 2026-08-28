import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/repositories/repositories.dart';
import '../../core/models/models.dart';
import '../../core/services/queue_service.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appointmentRepo = context.read<AppointmentRepository>();
    final patientRepo = context.read<PatientRepository>();
    final doctorRepo = context.read<DoctorRepository>();
    final queueService = context.read<QueueService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Randevu Detayı'),
      ),
      body: FutureBuilder(
        future: appointmentRepo.all(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final appointments = snapshot.data as List<Appointment>? ?? [];
          final appointment = appointments.firstWhere(
            (a) => a.id == widget.appointmentId,
            orElse: () => Appointment(
              id: widget.appointmentId,
              patientId: '',
              doctorId: '',
              dateTime: DateTime.now(),
              createdAt: DateTime.now(),
            ),
          );

          if (appointment.patientId.isEmpty) {
            return const Center(child: Text('Randevu tapılmadı'));
          }

          return FutureBuilder(
            future: Future.wait([
              patientRepo.all(),
              doctorRepo.all(),
            ]),
            builder: (context, snapshot) {
              final patients = (snapshot.data?[0] as List<Patient>?) ?? [];
              final doctors = (snapshot.data?[1] as List<Doctor>?) ?? [];
              final patient = patients.firstWhere((p) => p.id == appointment.patientId, orElse: () => Patient(id: '', fullName: 'Naməlum', birthDate: DateTime.now(), phone: '', createdAt: DateTime.now()));
              final doctor = doctors.firstWhere((d) => d.id == appointment.doctorId, orElse: () => Doctor(id: '', fullName: 'Naməlum', specialty: '', phone: '', consultationFee: 0, createdAt: DateTime.now()));

              final statusColor = switch (appointment.status) {
                AppointmentStatus.scheduled => AppTheme.primary,
                AppointmentStatus.completed => AppTheme.success,
                AppointmentStatus.cancelled => AppTheme.error,
                AppointmentStatus.noShow => AppTheme.warning,
              };

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacing4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacing4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: statusColor.withValues(alpha: 0.12),
                                  child: Icon(Icons.event_rounded, color: statusColor),
                                ),
                                const SizedBox(width: AppTheme.spacing3),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Randevu #${appointment.id.substring(0, 8)}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                                      Text(DateFormat('yyyy-MM-dd HH:mm').format(appointment.dateTime), style: theme.textTheme.bodyMedium),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacing3),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                appointment.status.label,
                                style: TextStyle(color: statusColor, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Text('Pasient', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppTheme.spacing2),
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
                        title: Text(patient.fullName),
                        subtitle: Text(patient.phone),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing3),
                    Text('Həkim', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppTheme.spacing2),
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.medical_services_rounded)),
                        title: Text(doctor.fullName),
                        subtitle: Text(doctor.specialty),
                      ),
                    ),
                    if (appointment.reason != null) ...[
                      const SizedBox(height: AppTheme.spacing3),
                      Text('Səbəb', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppTheme.spacing2),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacing3),
                          child: Text(appointment.reason!),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppTheme.spacing4),
                    Text('Əməliyyatlar', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppTheme.spacing2),
                    Wrap(
                      spacing: AppTheme.spacing2,
                      children: [
                        if (appointment.status == AppointmentStatus.scheduled)
                          FilledButton.icon(
                            onPressed: () async {
                              await queueService.createQueueEntry(
                                repo: context.read<QueueEntryRepository>(),
                                patientId: appointment.patientId,
                                doctorId: appointment.doctorId,
                                appointmentId: appointment.id,
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Növbəyə əlavə edildi')));
                              }
                            },
                            icon: const Icon(Icons.queue_rounded),
                            label: const Text('Növbəyə əlavə et'),
                          ),
                         if (appointment.status == AppointmentStatus.scheduled)
                          FilledButton.tonalIcon(
                            onPressed: () async {
                              await appointmentRepo.save(appointment.copyWith(status: AppointmentStatus.completed));
                              final auth = context.read<AuthService>();
                              final audit = context.read<AuditLogService>();
                              await audit.log(
                                userId: auth.currentUser?.id ?? '',
                                userName: auth.currentUser?.fullName ?? 'System',
                                userRole: auth.currentUser?.role ?? UserRole.clinicAdmin,
                                action: AuditAction.update,
                                entityType: 'Appointment',
                                entityId: appointment.id,
                                entityName: appointment.patientId,
                                changes: {'status': 'completed'},
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Randevu tamamlandı')));
                                setState(() {});
                              }
                            },
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Tamamlandı'),
                          ),
                        if (appointment.status == AppointmentStatus.scheduled)
                          FilledButton.tonalIcon(
                            onPressed: () async {
                              await appointmentRepo.save(appointment.copyWith(status: AppointmentStatus.cancelled));
                              final auth = context.read<AuthService>();
                              final audit = context.read<AuditLogService>();
                              await audit.log(
                                userId: auth.currentUser?.id ?? '',
                                userName: auth.currentUser?.fullName ?? 'System',
                                userRole: auth.currentUser?.role ?? UserRole.clinicAdmin,
                                action: AuditAction.update,
                                entityType: 'Appointment',
                                entityId: appointment.id,
                                entityName: appointment.patientId,
                                changes: {'status': 'cancelled'},
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Randevu ləğv edildi')));
                                setState(() {});
                              }
                            },
                            icon: const Icon(Icons.cancel_rounded),
                            label: const Text('Ləğv et'),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
