import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../core/repositories/repositories.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _feeController = TextEditingController();
  final _scheduleController = TextEditingController();
  final _experienceController = TextEditingController();

  Future<void> _addDoctor() async {
    if (_nameController.text.isEmpty) return;
    final repo = context.read<DoctorRepository>();
    await repo.save(Doctor(
      fullName: _nameController.text,
      specialty: _specialtyController.text,
      phone: _phoneController.text,
      consultationFee: double.tryParse(_feeController.text) ?? 0,
      schedule: _scheduleController.text,
      experience: _experienceController.text,
    ));
    _nameController.clear();
    _specialtyController.clear();
    _phoneController.clear();
    _feeController.clear();
    _scheduleController.clear();
    _experienceController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<DoctorRepository>();
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
                width: 180,
                child: TextField(
                  controller: _specialtyController,
                  decoration: const InputDecoration(labelText: 'İxtisas'),
                ),
              ),
              SizedBox(
                width: 180,
                child: TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Telefon'),
                ),
              ),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _feeController,
                  decoration: const InputDecoration(labelText: 'Haqq'),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(
                width: 180,
                child: TextField(
                  controller: _experienceController,
                  decoration: const InputDecoration(labelText: 'Təcrübə'),
                ),
              ),
              ElevatedButton(onPressed: _addDoctor, child: const Text('Əlavə et')),
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
              final doctors = snapshot.data as List<Doctor>;
              if (doctors.isEmpty) {
                return const Center(child: Text('Həkimlər yoxdur'));
              }
              return ListView.builder(
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  return ListTile(
                    leading: const Icon(Icons.medical_services),
                    title: Text(doctor.fullName),
                    subtitle: Text(
                      '${doctor.specialty} • ${doctor.phone}\n'
                      'Haqq: ${doctor.consultationFee.toStringAsFixed(2)} AZN\n'
                      'Təcrübə: ${doctor.experience ?? "Göstərilməyib"}',
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
