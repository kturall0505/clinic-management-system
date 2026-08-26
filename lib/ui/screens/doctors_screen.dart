import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/models.dart';
import '../../core/repositories/repositories.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  late Future<List<Doctor>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _future = context.read<DoctorRepository>().all();
  }

  Future<void> _openForm([Doctor? existing]) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _DoctorFormDialog(existing: existing),
    );
    if (saved == true && mounted) setState(_refresh);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Yeni həkim',
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Doctor>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final doctors = snapshot.data!;
          if (doctors.isEmpty) {
            return const Center(
                child: Text('Hələ həkim yoxdur. "+" ilə əlavə edin.'));
          }
          return ListView.builder(
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final d = doctors[index];
              return ListTile(
                leading:
                    const CircleAvatar(child: Icon(Icons.medical_services)),
                title: Text(d.fullName),
                subtitle: Text(
                    '${d.specialty} · ${d.phone} · ${d.consultationFee.toStringAsFixed(2)} AZN'),
                onTap: () => _openForm(d),
                trailing: IconButton(
                  tooltip: 'Sil',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await context.read<DoctorRepository>().delete(d.id);
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

class _DoctorFormDialog extends StatefulWidget {
  const _DoctorFormDialog({this.existing});

  final Doctor? existing;

  @override
  State<_DoctorFormDialog> createState() => _DoctorFormDialogState();
}

class _DoctorFormDialogState extends State<_DoctorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.fullName);
  late final _specialty =
      TextEditingController(text: widget.existing?.specialty);
  late final _phone = TextEditingController(text: widget.existing?.phone);
  late final _fee = TextEditingController(
      text: widget.existing?.consultationFee.toStringAsFixed(2));
  late final _schedule = TextEditingController(text: widget.existing?.schedule);

  @override
  void dispose() {
    _name.dispose();
    _specialty.dispose();
    _phone.dispose();
    _fee.dispose();
    _schedule.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final doctor = Doctor(
      id: widget.existing?.id,
      fullName: _name.text.trim(),
      specialty: _specialty.text.trim(),
      phone: _phone.text.trim(),
      consultationFee: double.parse(_fee.text.trim()),
      schedule: _schedule.text.trim().isEmpty ? null : _schedule.text.trim(),
    );
    await context.read<DoctorRepository>().save(doctor);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Yeni həkim' : 'Həkim'),
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
                  controller: _specialty,
                  decoration: const InputDecoration(labelText: 'İxtisas'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'İxtisas daxil edin'
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
                  controller: _fee,
                  decoration: const InputDecoration(
                      labelText: 'Konsultasiya haqqı (AZN)'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    final parsed = double.tryParse(v?.trim() ?? '');
                    if (parsed == null || parsed < 0) {
                      return 'Düzgün məbləğ daxil edin';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _schedule,
                  decoration: const InputDecoration(
                      labelText: 'İş qrafiki (məs. B.e–Cümə 09:00–17:00)'),
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
