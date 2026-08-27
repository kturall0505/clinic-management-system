import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/repositories/repositories.dart';
import '../../core/models/models.dart';

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

  Future<void> _bookAppointment() async {
    if (_selectedPatientId == null || _selectedDoctorId == null) {
      setState(() => _errorMessage = 'Pasient və həkim seçin');
      return;
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
        patientId: _selectedPatientId!,
        doctorId: _selectedDoctorId!,
        dateTime: dateTime,
        reason: _reasonController.text,
      ));

      _reasonController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Randevu uğurla yaradıldı')),
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
                        ],
                      ),
                      isThreeLine: true,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          appt.status.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
