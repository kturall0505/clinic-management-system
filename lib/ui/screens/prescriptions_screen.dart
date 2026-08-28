import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/repositories/repositories.dart';
import '../../core/models/models.dart';

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  String? _selectedAppointmentId;
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();
  final List<Map<String, String>> _medications = [];
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addPrescription({Prescription? prescription}) async {
    final isEditing = prescription != null;
    if (_selectedAppointmentId == null) {
      setState(() => _errorMessage = 'Randevu seçin');
      return;
    }
    if (_medications.isEmpty) {
      setState(() => _errorMessage = 'Ən az bir dərman əlavə edin');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final prescriptionRepo = context.read<PrescriptionRepository>();
      final prescriptionItemsRepo = context.read<PrescriptionItemRepository>();
      final appointmentRepo = context.read<AppointmentRepository>();
      final appointments = await appointmentRepo.all();
      final appointment = appointments.firstWhere((a) => a.id == _selectedAppointmentId);

      final newPrescription = Prescription.create(
        id: prescription?.id,
        appointmentId: _selectedAppointmentId!,
        patientId: appointment.patientId,
        doctorId: appointment.doctorId,
        medications: _medications.map((m) => m['name']!).join(', '),
        diagnosis: _diagnosisController.text,
        notes: _notesController.text,
      );
      await prescriptionRepo.save(newPrescription);

      if (!isEditing) {
        for (final med in _medications) {
          final item = PrescriptionItem.create(
            prescriptionId: newPrescription.id,
            medicationId: med['id']!,
            medicationName: med['name']!,
            dosage: med['dosage'],
            frequency: med['frequency'],
            duration: med['duration'],
            instructions: med['instructions'],
          );
          await prescriptionItemsRepo.save(item);
        }

        await appointmentRepo.save(appointment.copyWith(
          status: AppointmentStatus.completed,
        ));
      }

      _selectedAppointmentId = null;
      _diagnosisController.clear();
      _notesController.clear();
      _medications.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? 'Resept yeniləndi' : 'Resept uğurla yaradıldı')),
        );
      }
    } on Exception catch (e) {
      setState(() => _errorMessage = 'Xəta: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _editPrescription(Prescription prescription) async {
    _selectedAppointmentId = prescription.appointmentId;
    _diagnosisController.text = prescription.diagnosis ?? '';
    _notesController.text = prescription.notes ?? '';

    final itemsRepo = context.read<PrescriptionItemRepository>();
    final items = await itemsRepo.findByPrescriptionId(prescription.id);
    _medications.clear();
    for (final item in items) {
      _medications.add({
        'id': item.medicationId,
        'name': item.medicationName,
        'dosage': item.dosage ?? '',
        'frequency': item.frequency ?? '',
        'duration': item.duration ?? '',
        'instructions': item.instructions ?? '',
      });
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resepti redaktə et'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder(
                future: context.read<AppointmentRepository>().all(),
                builder: (context, snapshot) {
                  final appointments = snapshot.data as List<Appointment>? ?? [];
                  final scheduled = appointments.where((a) => a.status == AppointmentStatus.scheduled).toList();
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Randevu seçin', prefixIcon: Icon(Icons.event_note_rounded)),
                    value: _selectedAppointmentId,
                    items: scheduled.map((a) => DropdownMenuItem(value: a.id, child: Text('Pasient: ${a.patientId}'))).toList(),
                    onChanged: (v) => setState(() => _selectedAppointmentId = v),
                  );
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _diagnosisController,
                decoration: const InputDecoration(labelText: 'Diaqnoz', prefixIcon: Icon(Icons.medical_information_rounded)),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Qeydlər', prefixIcon: Icon(Icons.note_rounded)),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ləğv et')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _addPrescription(prescription: prescription);
            },
            child: const Text('Yadda saxla'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePrescription(Prescription prescription) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resepti sil'),
        content: Text('Bu resepti silmək istədiyinizə əminsiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ləğv et')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await context.read<PrescriptionRepository>().delete(prescription.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resept silindi')),
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

  void _addMedication() {
    setState(() {
      _medications.add({
        'id': 'med_${DateTime.now().millisecondsSinceEpoch}',
        'name': '',
        'dosage': '',
        'frequency': '',
        'duration': '',
        'instructions': '',
      });
    });
  }

  void _removeMedication(int index) {
    setState(() => _medications.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appointmentRepo = context.read<AppointmentRepository>();
    final medicationRepo = context.read<MedicationRepository>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: Text(
            'Resept',
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
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            children: [
              FutureBuilder(
                future: appointmentRepo.all(),
                builder: (context, snapshot) {
                  final appointments = snapshot.data as List<Appointment>? ?? [];
                  final scheduled = appointments.where((a) => a.status == AppointmentStatus.scheduled).toList();
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Randevu seçin',
                      prefixIcon: Icon(Icons.event_note_rounded),
                    ),
                    value: _selectedAppointmentId,
                    items: scheduled
                        .map((a) => DropdownMenuItem(
                              value: a.id,
                              child: Text('Pasient: ${a.patientId} - ${DateFormat('yyyy-MM-dd HH:mm').format(a.dateTime)}'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedAppointmentId = v),
                  );
                },
              ),
              const SizedBox(height: AppTheme.spacing3),
              TextFormField(
                controller: _diagnosisController,
                decoration: const InputDecoration(
                  labelText: 'Diaqnoz',
                  prefixIcon: Icon(Icons.medical_information_rounded),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppTheme.spacing3),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Qeydlər',
                  prefixIcon: Icon(Icons.note_rounded),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppTheme.spacing4),
              Row(
                children: [
                  const Text('Dərmanlar:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _addMedication,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Əlavə et'),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing2),
              if (_medications.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.spacing4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: AppTheme.borderRadiusMedium,
                  ),
                  child: Text(
                    'Hələ dərman əlavə edilməyib',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ...List.generate(_medications.length, (index) {
                final med = _medications[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacing2),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing3),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: med['name'],
                                decoration: const InputDecoration(
                                  labelText: 'Dərman adı',
                                  isDense: true,
                                ),
                                onChanged: (v) => med['name'] = v,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_rounded, color: AppTheme.error),
                              onPressed: () => _removeMedication(index),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing2),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: med['dosage'],
                                decoration: const InputDecoration(labelText: 'Dozaj', isDense: true),
                                onChanged: (v) => med['dosage'] = v,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacing2),
                            Expanded(
                              child: TextFormField(
                                initialValue: med['frequency'],
                                decoration: const InputDecoration(labelText: 'Tezlik', isDense: true),
                                onChanged: (v) => med['frequency'] = v,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing2),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: med['duration'],
                                decoration: const InputDecoration(labelText: 'Müddət', isDense: true),
                                onChanged: (v) => med['duration'] = v,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacing2),
                            Expanded(
                              child: TextFormField(
                                initialValue: med['instructions'],
                                decoration: const InputDecoration(labelText: 'İstər', isDense: true),
                                onChanged: (v) => med['instructions'] = v,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppTheme.spacing4),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _addPrescription,
                  icon: _isSaving
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_rounded),
                  label: Text(_selectedAppointmentId != null && _isSaving == false && _diagnosisController.text.isNotEmpty ? 'Resepti yadda saxla' : 'Resepti yadda saxla'),
                ),
              ),
              const SizedBox(height: AppTheme.spacing4),
              const Divider(),
              const SizedBox(height: AppTheme.spacing2),
              Text('Reseptlər', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppTheme.spacing2),
              FutureBuilder(
                future: context.read<PrescriptionRepository>().all(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final prescriptions = snapshot.data as List<Prescription>? ?? [];
                  if (prescriptions.isEmpty) {
                    return Text('Hələ resept yoxdur', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: prescriptions.length,
                    itemBuilder: (context, index) {
                      final p = prescriptions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacing2),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(AppTheme.spacing3),
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(Icons.medication_rounded, color: theme.colorScheme.primary),
                          ),
                          title: Text('Pasient: ${p.patientId}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Dərmanlar: ${p.medications}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_rounded, color: AppTheme.primary),
                                onPressed: () => _editPrescription(p),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_rounded, color: AppTheme.error),
                                onPressed: () => _deletePrescription(p),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
