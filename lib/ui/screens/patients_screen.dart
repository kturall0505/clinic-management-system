import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../core/repositories/repositories.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _finController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _chronicController = TextEditingController();
  final _notesController = TextEditingController();

  Future<void> _addPatient() async {
    if (_nameController.text.isEmpty) return;
    final repo = context.read<PatientRepository>();
    await repo.save(Patient(
      fullName: _nameController.text,
      birthDate: DateTime.tryParse(_birthDateController.text) ?? DateTime.now(),
      phone: _phoneController.text,
      fin: _finController.text,
      allergies: _allergiesController.text,
      chronicConditions: _chronicController.text,
      notes: _notesController.text,
    ));
    _nameController.clear();
    _birthDateController.clear();
    _phoneController.clear();
    _finController.clear();
    _allergiesController.clear();
    _chronicController.clear();
    _notesController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<PatientRepository>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: 180,
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Ad Soyad'),
                ),
              ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _birthDateController,
                  decoration: const InputDecoration(labelText: 'Doğum tarixi'),
                ),
              ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Telefon'),
                ),
              ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _finController,
                  decoration: const InputDecoration(labelText: 'FIN'),
                ),
              ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _allergiesController,
                  decoration: const InputDecoration(labelText: 'Allergiyalar'),
                ),
              ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _chronicController,
                  decoration: const InputDecoration(labelText: 'Xroniki xəstəliklər'),
                ),
              ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Qeydlər'),
                ),
              ),
              ElevatedButton(onPressed: _addPatient, child: const Text('Əlavə et')),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: repo.all(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final patients = snapshot.data as List<Patient>;
              if (patients.isEmpty) {
                return const Center(child: Text('Pasientlər yoxdur'));
              }
              return ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  final patient = patients[index];
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(patient.fullName),
                    subtitle: Text(
                      '${patient.phone} • ${patient.birthDate.year}\n'
                      'FIN: ${patient.fin ?? "Göstərilməyib"}\n'
                      'Allergiya: ${patient.allergies ?? "Yox"}\n'
                      'Xroniki: ${patient.chronicConditions ?? "Yox"}',
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
