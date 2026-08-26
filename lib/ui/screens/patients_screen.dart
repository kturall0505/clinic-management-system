import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/models/models.dart';
import '../../core/repositories/repositories.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  late Future<List<Patient>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _future = context.read<PatientRepository>().all();
  }

  Future<void> _openForm([Patient? existing]) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _PatientFormDialog(existing: existing),
    );
    if (saved == true && mounted) setState(_refresh);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Yeni pasient',
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Patient>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final patients = snapshot.data!;
          if (patients.isEmpty) {
            return const Center(
                child: Text('Hələ pasient yoxdur. "+" ilə əlavə edin.'));
          }
          return ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final p = patients[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(p.fullName),
                subtitle: Text(
                    '${DateFormat('dd.MM.yyyy').format(p.birthDate)} · ${p.phone}'
                    '${p.allergies?.isNotEmpty == true ? ' · Allergiya: ${p.allergies}' : ''}'),
                onTap: () => _openForm(p),
                trailing: IconButton(
                  tooltip: 'Sil',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await context.read<PatientRepository>().delete(p.id);
                    if (mounted) setState(_refresh);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PatientFormDialog extends StatefulWidget {
  const _PatientFormDialog({this.existing});

  final Patient? existing;

  @override
  State<_PatientFormDialog> createState() => _PatientFormDialogState();
}

class _PatientFormDialogState extends State<_PatientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.fullName);
  late final _phone = TextEditingController(text: widget.existing?.phone);
  late final _allergies =
      TextEditingController(text: widget.existing?.allergies);
  late final _chronic =
      TextEditingController(text: widget.existing?.chronicConditions);
  late DateTime _birthDate = widget.existing?.birthDate ?? DateTime(1990);

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _allergies.dispose();
    _chronic.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final patient = Patient(
      id: widget.existing?.id,
      fullName: _name.text.trim(),
      birthDate: _birthDate,
      phone: _phone.text.trim(),
      allergies: _allergies.text.trim().isEmpty ? null : _allergies.text.trim(),
      chronicConditions:
          _chronic.text.trim().isEmpty ? null : _chronic.text.trim(),
    );
    await context.read<PatientRepository>().save(patient);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Yeni pasient' : 'Pasient'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Ad Soyad'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ad Soyad daxil edin'
                      : null,
                ),
                TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: 'Telefon'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Telefon daxil edin'
                      : null,
                ),
                TextFormField(
                  controller: _allergies,
                  decoration: const InputDecoration(labelText: 'Allergiyalar'),
                ),
                TextFormField(
                  controller: _chronic,
                  decoration:
                      const InputDecoration(labelText: 'Xroniki xəstəliklər'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text('Doğum tarixi: '
                          '${DateFormat('dd.MM.yyyy').format(_birthDate)}'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _birthDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) setState(() => _birthDate = picked);
                      },
                      child: const Text('Seç'),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
