import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/repositories/repositories.dart';
import '../../core/models/models.dart';
import '../../core/services/queue_service.dart';

class QueueManagementScreen extends StatefulWidget {
  const QueueManagementScreen({super.key});

  @override
  State<QueueManagementScreen> createState() => _QueueManagementScreenState();
}

class _QueueManagementScreenState extends State<QueueManagementScreen> with SingleTickerProviderStateMixin {
  String? _selectedDoctorId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final queueRepo = context.read<QueueEntryRepository>();
    final doctorRepo = context.read<DoctorRepository>();
    final queueService = context.read<QueueService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: Text(
            'Növbə İdarəetməsi',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
          child: Row(
            children: [
              Expanded(
                child: FutureBuilder(
                  future: doctorRepo.all(),
                  builder: (context, snapshot) {
                    final doctors = snapshot.data as List<Doctor>? ?? [];
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Həkim',
                        prefixIcon: Icon(Icons.medical_services_rounded),
                      ),
                      value: _selectedDoctorId,
                      items: doctors
                          .map((d) => DropdownMenuItem(value: d.id, child: Text(d.fullName)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedDoctorId = v),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppTheme.spacing3),
              FilledButton.icon(
                onPressed: _selectedDoctorId == null ? null : () async {
                  final appointments = await context.read<AppointmentRepository>().all();
                  final scheduled = appointments.where((a) => a.doctorId == _selectedDoctorId && a.status == AppointmentStatus.scheduled).toList();
                  if (scheduled.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bu həkim üçün planlaşdırılmış randevu yoxdur')),
                    );
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (context) => _AddToQueueDialog(
                      appointments: scheduled,
                      onAdd: (appointmentId) async {
                        final appointment = scheduled.firstWhere((a) => a.id == appointmentId);
                        final entry = await queueService.createQueueEntry(
                          repo: queueRepo,
                          patientId: appointment.patientId,
                          doctorId: appointment.doctorId,
                          appointmentId: appointment.id,
                        );
                        await queueRepo.save(entry);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Növbəyə əlavə edildi: ${entry.queueNumber}')),
                          );
                        }
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Növbəyə əlavə et'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing3),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildQueueList(queueRepo, theme),
              _buildCompletedList(queueRepo, theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQueueList(QueueEntryRepository repo, ThemeData theme) {
    return FutureBuilder(
      future: _selectedDoctorId != null ? repo.findByDoctorId(_selectedDoctorId!) : Future.value(<QueueEntry>[]),
      builder: (context, snapshot) {
        final entries = snapshot.data as List<QueueEntry>? ?? [];
        final waiting = entries.where((e) => e.status == QueueStatus.waiting).toList();
        final called = entries.where((e) => e.status == QueueStatus.called || e.status == QueueStatus.inProgress).toList();

        if (waiting.isEmpty && called.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.queue_rounded, size: 48, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(height: AppTheme.spacing3),
                Text('Növbə boşdur', style: theme.textTheme.titleMedium),
              ],
            ),
          );
        }

        return Column(
          children: [
            if (called.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4, vertical: AppTheme.spacing2),
                child: Text('Cari', style: theme.textTheme.titleSmall),
              ),
              ...called.map((e) => _buildQueueCard(e, repo, theme, isActive: true)),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4, vertical: AppTheme.spacing2),
              child: Text('Gözləyən', style: theme.textTheme.titleSmall),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
                itemCount: waiting.length,
                itemBuilder: (context, index) {
                  final entry = waiting[index];
                  return _buildQueueCard(entry, repo, theme);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompletedList(QueueEntryRepository repo, ThemeData theme) {
    return FutureBuilder(
      future: _selectedDoctorId != null ? repo.findByDoctorId(_selectedDoctorId!) : Future.value(<QueueEntry>[]),
      builder: (context, snapshot) {
        final entries = snapshot.data as List<QueueEntry>? ?? [];
        final completed = entries.where((e) => e.status == QueueStatus.completed || e.status == QueueStatus.skipped).toList();

        if (completed.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, size: 48, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(height: AppTheme.spacing3),
                Text('Tamamlanmış növbə yoxdur', style: theme.textTheme.titleMedium),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          itemCount: completed.length,
          itemBuilder: (context, index) {
            final entry = completed[index];
            final statusColor = entry.status == QueueStatus.completed ? AppTheme.success : AppTheme.warning;
            return Card(
              margin: const EdgeInsets.only(bottom: AppTheme.spacing2),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.12),
                  child: Icon(Icons.check_rounded, color: statusColor),
                ),
                title: Text('Növbə #${entry.queueNumber}', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Pasient: ${entry.patientId}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.status.label,
                    style: TextStyle(fontSize: 12, color: statusColor),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQueueCard(QueueEntry entry, QueueEntryRepository repo, ThemeData theme, {bool isActive = false}) {
    final statusColor = switch (entry.status) {
      QueueStatus.waiting => theme.colorScheme.onSurfaceVariant,
      QueueStatus.called => AppTheme.primary,
      QueueStatus.inProgress => AppTheme.secondary,
      QueueStatus.completed => AppTheme.success,
      QueueStatus.skipped => AppTheme.warning,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing2),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppTheme.spacing3),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '${entry.queueNumber}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ),
        title: Text('Pasient: ${entry.patientId}', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Randevu: ${entry.appointmentId}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isActive)
              IconButton(
                icon: const Icon(Icons.play_arrow_rounded, color: AppTheme.primary),
                onPressed: () async {
                  await context.read<QueueService>().markInProgress(repo, entry.id);
                  if (mounted) setState(() {});
                },
              ),
            if (isActive && entry.status == QueueStatus.inProgress)
              IconButton(
                icon: const Icon(Icons.check_rounded, color: AppTheme.success),
                onPressed: () async {
                  await context.read<QueueService>().markCompleted(repo, entry.id);
                  if (mounted) setState(() {});
                },
              ),
            if (isActive && entry.status == QueueStatus.called)
              IconButton(
                icon: const Icon(Icons.play_arrow_rounded, color: AppTheme.secondary),
                onPressed: () async {
                  await context.read<QueueService>().markInProgress(repo, entry.id);
                  if (mounted) setState(() {});
                },
              ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: AppTheme.error),
              onPressed: () async {
                await context.read<QueueService>().markSkipped(repo, entry.id);
                if (mounted) setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AddToQueueDialog extends StatelessWidget {
  final List<Appointment> appointments;
  final Future<void> Function(String appointmentId) onAdd;

  const _AddToQueueDialog({
    required this.appointments,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Randevu seçin'),
      content: SizedBox(
        width: 400,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appt = appointments[index];
            return ListTile(
              title: Text('Pasient: ${appt.patientId}'),
              subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(appt.dateTime)),
              onTap: () {
                Navigator.pop(context);
                onAdd(appt.id);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ləğv et')),
      ],
    );
  }
}
