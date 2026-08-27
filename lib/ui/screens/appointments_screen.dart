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
  String? _selectedPatientId;
  String? _selectedDoctorId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  final _reasonController = TextEditingController();

  Future<void> _bookAppointment() async {
    if (_selectedPatientId == null || _selectedDoctorId == null) return;
    final repo = context.read<AppointmentRepository>();
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    await repo.save(Appointment(
      patientId: _selectedPatientId!,
      doctorId: _selectedDoctorId!,
      dateTime: dateTime,
      reason: _reasonController.text,
    ));
    _reasonController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appointmentRepo = context.read<AppointmentRepository>();
    final patientRepo = context.read<PatientRepository>();
    final doctorRepo = context.read<DoctorRepository>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FutureBuilder(
                future: patientRepo.all(),
                builder: (context, snapshot) {
                  final patients = snapshot.data as List<Patient>? ?? [];
                  return SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Pasient'),
                      value: _selectedPatientId,
                      items: patients
                          .map((p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.fullName),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedPatientId = v),
                    ),
                  );
                },
              ),
              FutureBuilder(
                future: doctorRepo.all(),
                builder: (context, snapshot) {
                  final doctors = snapshot.data as List<Doctor>? ?? [];
                  return SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Həkim'),
                      value: _selectedDoctorId,
                      items: doctors
                          .map((d) => DropdownMenuItem(
                                value: d.id,
                                child: Text(d.fullName),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedDoctorId = v),
                    ),
                  );
                },
              ),
              SizedBox(
                width: 140,
                child: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                ),
              ),
              SizedBox(
                width: 120,
                child: TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (picked != null) {
                      setState(() => _selectedTime = picked);
                    }
                  },
                  child: Text(_selectedTime.format(context)),
                ),
              ),
              SizedBox(
                width: 180,
                child: TextField(
                  controller: _reasonController,
                  decoration: const InputDecoration(labelText: 'Səbəb'),
                ),
              ),
              ElevatedButton(onPressed: _bookAppointment, child: const Text('Rezerv et')),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: appointmentRepo.all(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final appointments = snapshot.data as List<Appointment>;
              if (appointments.isEmpty) {
                return const Center(child: Text('Randevular yoxdur'));
              }
              return ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appt = appointments[index];
                  return ListTile(
                    leading: const Icon(Icons.event),
                    title: Text('Pasient: ${appt.patientId} • Həkim: ${appt.doctorId}'),
                    subtitle: Text(
                      '${DateFormat('yyyy-MM-dd HH:mm').format(appt.dateTime)}\n'
                      'Status: ${appt.status.name}${appt.reason != null ? " • ${appt.reason}" : ""}',
                    ),
                    isThreeLine: true,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
