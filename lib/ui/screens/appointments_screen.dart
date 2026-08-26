import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/models/models.dart';
import '../../core/repositories/repositories.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  late Future<List<Object>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _future = Future.wait([
      context.read<AppointmentRepository>().all(),
      context.read<PatientRepository>().all(),
      context.read<DoctorRepository>().all(),
    ]);
  }

  Future<void> _openForm(List<Patient> patients, List<Doctor> doctors) async {
    if (patients.isEmpty || doctors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Əvvəlcə ən azı bir pasient və bir həkim əlavə edin')));
      return;
    }
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) =>
          _AppointmentFormDialog(patients: patients, doctors: doctors),
    );
    if (saved == true && mounted) setState(_refresh);
  }

  String _statusLabel(AppointmentStatus status) => switch (status) {
        AppointmentStatus.scheduled => 'Planlaşdırılıb',
        AppointmentStatus.completed => 'Tamamlanıb',
        AppointmentStatus.cancelled => 'Ləğv edilib',
        AppointmentStatus.noShow => 'Gəlmədi',
      };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Object>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final appointments = snapshot.data![0] as List<Appointment>;
        final patients = snapshot.data![1] as List<Patient>;
        final doctors = snapshot.data![2] as List<Doctor>;
        final patientById = {for (final p in patients) p.id: p};
        final doctorById = {for (final d in doctors) d.id: d};
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            tooltip: 'Yeni randevu',
            onPressed: () => _openForm(patients, doctors),
            child: const Icon(Icons.add),
          ),
          body: appointments.isEmpty
              ? const Center(
                  child: Text('Hələ randevu yoxdur. "+" ilə əlavə edin.'))
              : ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final a = appointments[index];
                    final patient = patientById[a.patientId];
                    final doctor = doctorById[a.doctorId];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.event)),
                      title: Text(
                          '${patient?.fullName ?? 'Naməlum pasient'} → '
                          '${doctor?.fullName ?? 'Naməlum həkim'}'),
                      subtitle: Text(
                          '${DateFormat('dd.MM.yyyy HH:mm').format(a.dateTime)}'
                          ' · ${_statusLabel(a.status)}'
                          '${a.reason?.isNotEmpty == true ? ' · ${a.reason}' : ''}'),
                      trailing: PopupMenuButton<AppointmentStatus>(
                        tooltip: 'Statusu dəyiş',
                        onSelected: (status) async {
                          await context
                              .read<AppointmentRepository>()
                              .save(a.copyWith(status: status));
                          if (mounted) setState(_refresh);
                        },
                        itemBuilder: (_) => AppointmentStatus.values
                            .map((s) => PopupMenuItem(
                                value: s, child: Text(_statusLabel(s))))
                            .toList(),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _AppointmentFormDialog extends StatefulWidget {
  const _AppointmentFormDialog(
      {required this.patients, required this.doctors});

  final List<Patient> patients;
  final List<Doctor> doctors;

  @override
  State<_AppointmentFormDialog> createState() => _AppointmentFormDialogState();
}

class _AppointmentFormDialogState extends State<_AppointmentFormDialog> {
  final _reason = TextEditingController();
  String? _patientId;
  String? _doctorId;
  DateTime _dateTime = DateTime.now().add(const Duration(hours: 1));

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(_dateTime));
    if (time == null) return;
    setState(() {
      _dateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (_patientId == null || _doctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pasient və həkim seçin')));
      return;
    }
    await context.read<AppointmentRepository>().save(Appointment(
          patientId: _patientId!,
          doctorId: _doctorId!,
          dateTime: _dateTime,
          reason: _reason.text.trim().isEmpty ? null : _reason.text.trim(),
        ));
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni randevu'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Pasient'),
              items: widget.patients
                  .map((p) =>
                      DropdownMenuItem(value: p.id, child: Text(p.fullName)))
                  .toList(),
              onChanged: (v) => setState(() => _patientId = v),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Həkim'),
              items: widget.doctors
                  .map((d) => DropdownMenuItem(
                      value: d.id,
                      child: Text('${d.fullName} (${d.specialty})')))
                  .toList(),
              onChanged: (v) => setState(() => _doctorId = v),
            ),
            TextFormField(
              controller: _reason,
              decoration: const InputDecoration(labelText: 'Səbəb (istəyə görə)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text('Vaxt: '
                      '${DateFormat('dd.MM.yyyy HH:mm').format(_dateTime)}'),
                ),
                TextButton(
                    onPressed: _pickDateTime, child: const Text('Seç')),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Ləğv et'),
        ),
        FilledButton(onPressed: _save, child: const Text('Yadda saxla')),
      ],
    );
  }
}
