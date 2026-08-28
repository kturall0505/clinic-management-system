import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/repositories/repositories.dart';
import '../../core/models/models.dart';
import 'appointment_detail_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  String? _selectedPatientId;
  String? _selectedDoctorId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  final _reasonController = TextEditingController();

  bool _isBooking = false;
  String? _errorMessage;

  Future<void> _bookAppointment({Appointment? appointment}) async {
    final isEditing = appointment != null;
    if (_selectedPatientId == null || _selectedDoctorId == null) {
      setState(() => _errorMessage = 'Pasient və həkim seçin');
      return;
    }

    if (isEditing) {
      _selectedPatientId = appointment.patientId;
      _selectedDoctorId = appointment.doctorId;
      _selectedDate = appointment.dateTime;
      _selectedTime = TimeOfDay(hour: appointment.dateTime.hour, minute: appointment.dateTime.minute);
      _reasonController.text = appointment.reason ?? '';
    }

    setState(() {
      _isBooking = true;
      _errorMessage = null;
    });

    try {
      final repo = context.read<AppointmentRepository>();
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await repo.save(Appointment.create(
        id: appointment?.id,
        patientId: _selectedPatientId!,
        doctorId: _selectedDoctorId!,
        dateTime: dateTime,
        reason: _reasonController.text,
        status: appointment?.status ?? AppointmentStatus.scheduled,
      ));

      _reasonController.clear();
      _selectedPatientId = null;
      _selectedDoctorId = null;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? 'Randevu yeniləndi' : 'Randevu uğurla yaradıldı')),
        );
      }
    } on ValidationException catch (e) {
      setState(() => _errorMessage = e.message);
    } on Exception catch (e) {
      setState(() => _errorMessage = 'Xəta: $e');
    } finally {
      setState(() => _isBooking = false);
    }
  }

  Future<void> _editAppointment(Appointment appt) async {
    _selectedPatientId = appt.patientId;
    _selectedDoctorId = appt.doctorId;
    _selectedDate = appt.dateTime;
    _selectedTime = TimeOfDay(hour: appt.dateTime.hour, minute: appt.dateTime.minute);
    _reasonController.text = appt.reason ?? '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Randevunu redaktə et'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPatientDropdown(context.read<PatientRepository>()),
              const SizedBox(height: 8),
              _buildDoctorDropdown(context.read<DoctorRepository>()),
              const SizedBox(height: 8),
              _buildDatePicker(),
              const SizedBox(height: 8),
              _buildTimePicker(),
              const SizedBox(height: 8),
              _buildReasonField(),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ləğv et')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _bookAppointment(appointment: appt);
            },
            child: const Text('Yadda saxla'),
          ),
        ],
      ),
    );
  }

  void _showCalendarView() {
    final appointmentRepo = context.read<AppointmentRepository>();
    final patientRepo = context.read<PatientRepository>();
    final doctorRepo = context.read<DoctorRepository>();
    DateTime selectedMonth = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () {
                  setDialogState(() {
                    selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
                  });
                },
              ),
              Expanded(
                child: Text(DateFormat('MMMM yyyy', 'az').format(selectedMonth)),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () {
                  setDialogState(() {
                    selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
                  });
                },
              ),
            ],
          ),
          content: SizedBox(
            width: 350,
            height: 400,
            child: FutureBuilder(
              future: appointmentRepo.all(),
              builder: (context, snapshot) {
                final appointments = snapshot.data as List<Appointment>? ?? [];
                final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
                final lastDay = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
                final daysInMonth = lastDay.day;
                final firstWeekday = firstDay.weekday % 7;

                final appointmentDates = <int>{};
                for (final appt in appointments) {
                  if (appt.dateTime.isAfter(firstDay.subtract(const Duration(days: 1))) &&
                      appt.dateTime.isBefore(lastDay.add(const Duration(days: 1)))) {
                    appointmentDates.add(appt.dateTime.day);
                  }
                }

                return Column(
                  children: [
                    Row(
                      children: ['Su', 'Sa', 'Ç', 'Pe', 'Cu', 'Ş', 'Ba']
                          .map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)))))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        itemCount: firstWeekday + daysInMonth,
                        itemBuilder: (context, index) {
                          if (index < firstWeekday) {
                            return const SizedBox.shrink();
                          }
                          final day = index - firstWeekday + 1;
                          final hasAppointment = appointmentDates.contains(day);
                          return Container(
                            decoration: BoxDecoration(
                              color: hasAppointment ? AppTheme.primary.withValues(alpha: 0.15) : null,
                              borderRadius: BorderRadius.circular(8),
                              border: hasAppointment ? Border.all(color: AppTheme.primary, width: 1) : null,
                            ),
                            child: Center(
                              child: Text(
                                '$day',
                                style: TextStyle(
                                  fontWeight: hasAppointment ? FontWeight.w700 : FontWeight.normal,
                                  color: hasAppointment ? AppTheme.primary : null,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bağla')),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAppointment(Appointment appt) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Randevunu sil'),
        content: Text('Bu randevunu silmək istədiyinizə əminsiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ləğv et')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await context.read<AppointmentRepository>().delete(appt.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Randevu silindi')),
        );
        setState(() {});
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xəta: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointmentRepo = context.read<AppointmentRepository>();
    final patientRepo = context.read<PatientRepository>();
    final doctorRepo = context.read<DoctorRepository>();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: Text(
            'Randevular',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacing3),
              decoration: BoxDecoration(
                color: AppTheme.errorContainer,
                borderRadius: AppTheme.borderRadiusMedium,
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: AppTheme.error),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: _buildPatientDropdown(patientRepo)),
                    const SizedBox(width: AppTheme.spacing2),
                    Expanded(child: _buildDoctorDropdown(doctorRepo)),
                    const SizedBox(width: AppTheme.spacing2),
                    Expanded(child: _buildDatePicker()),
                    const SizedBox(width: AppTheme.spacing2),
                    Expanded(child: _buildTimePicker()),
                    const SizedBox(width: AppTheme.spacing2),
                    Expanded(child: _buildReasonField()),
                    const SizedBox(width: AppTheme.spacing2),
                    FilledButton.icon(
                      onPressed: _isBooking ? null : _bookAppointment,
                      icon: _isBooking
                          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.calendar_month_rounded),
                      label: const Text('Rezerv et'),
                    ),
                  ],
                );
              }
              return Wrap(
                spacing: AppTheme.spacing2,
                runSpacing: AppTheme.spacing2,
                children: [
                  SizedBox(width: 180, child: _buildPatientDropdown(patientRepo)),
                  SizedBox(width: 180, child: _buildDoctorDropdown(doctorRepo)),
                  SizedBox(width: 150, child: _buildDatePicker()),
                  SizedBox(width: 120, child: _buildTimePicker()),
                  SizedBox(width: 180, child: _buildReasonField()),
                  FilledButton.icon(
                    onPressed: _isBooking ? null : _bookAppointment,
                    icon: _isBooking
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.calendar_month_rounded),
                    label: const Text('Rezerv et'),
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: appointmentRepo.all(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error),
                      const SizedBox(height: AppTheme.spacing3),
                      Text('Xəta baş verdi', style: theme.textTheme.titleMedium),
                    ],
                  ),
                );
              }

              final appointments = snapshot.data as List<Appointment>? ?? [];

              if (appointments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: AppTheme.spacing3),
                      Text('Randevular yoxdur', style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppTheme.spacing2),
                      Text('Yuxarıdakı formadan randevu yaradın', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appt = appointments[index];
                  final statusColor = switch (appt.status) {
                    AppointmentStatus.scheduled => AppTheme.primary,
                    AppointmentStatus.completed => AppTheme.success,
                    AppointmentStatus.cancelled => AppTheme.error,
                    AppointmentStatus.noShow => AppTheme.warning,
                  };

                  return Card(
                    margin: const EdgeInsets.only(bottom: AppTheme.spacing2),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(AppTheme.spacing3),
                      leading: CircleAvatar(
                        backgroundColor: statusColor.withValues(alpha: 0.12),
                        child: Icon(Icons.event_rounded, color: statusColor),
                      ),
                      title: Text(
                        'Pasient: ${appt.patientId}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Həkim: ${appt.doctorId}'),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(DateFormat('yyyy-MM-dd HH:mm').format(appt.dateTime)),
                              if (appt.reason != null) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '• ${appt.reason!}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              appt.status.label,
                              style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AppointmentDetailScreen(appointmentId: appt.id),
                          ),
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: AppTheme.primary),
                onPressed: () => _editAppointment(appt),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month_rounded, color: AppTheme.secondary),
                onPressed: () => _showCalendarView(),
              ),
              IconButton(
                icon: const Icon(Icons.delete_rounded, color: AppTheme.error),
                onPressed: () => _deleteAppointment(appt),
              ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPatientDropdown(PatientRepository repo) {
    return FutureBuilder(
      future: repo.all(),
      builder: (context, snapshot) {
        final patients = snapshot.data as List<Patient>? ?? [];
        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Pasient', prefixIcon: Icon(Icons.person_outline)),
          value: _selectedPatientId,
          items: patients
              .map((p) => DropdownMenuItem(value: p.id, child: Text(p.fullName)))
              .toList(),
          onChanged: (v) => setState(() => _selectedPatientId = v),
        );
      },
    );
  }

  Widget _buildDoctorDropdown(DoctorRepository repo) {
    return FutureBuilder(
      future: repo.all(),
      builder: (context, snapshot) {
        final doctors = snapshot.data as List<Doctor>? ?? [];
        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Həkim', prefixIcon: Icon(Icons.medical_services_outlined)),
          value: _selectedDoctorId,
          items: doctors
              .map((d) => DropdownMenuItem(value: d.id, child: Text(d.fullName)))
              .toList(),
          onChanged: (v) => setState(() => _selectedDoctorId = v),
        );
      },
    );
  }

  Widget _buildDatePicker() {
    return TextButton(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null && mounted) {
          setState(() => _selectedDate = picked);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_rounded, size: 18),
          const SizedBox(width: 8),
          Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
        ],
      ),
    );
  }

  Widget _buildTimePicker() {
    return TextButton(
      onPressed: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
        );
        if (picked != null && mounted) {
          setState(() => _selectedTime = picked);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule_rounded, size: 18),
          const SizedBox(width: 8),
          Text(_selectedTime.format(context)),
        ],
      ),
    );
  }

  Widget _buildReasonField() {
    return TextField(
      controller: _reasonController,
      decoration: const InputDecoration(
        labelText: 'Səbəb',
        prefixIcon: Icon(Icons.subject_rounded),
        isDense: true,
      ),
    );
  }
}
