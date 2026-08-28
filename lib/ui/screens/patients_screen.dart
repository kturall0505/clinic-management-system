import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/repositories/repositories.dart';
import '../../core/models/models.dart';
import 'patient_detail_screen.dart';

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
  final _searchController = TextEditingController();

  bool _isSaving = false;
  String? _errorMessage;
  String _searchQuery = '';

  Future<void> _addPatient({Patient? patient}) async {
    final isEditing = patient != null;
    if (!isEditing && _nameController.text.isEmpty) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final repo = context.read<PatientRepository>();
      final birthDate = DateTime.tryParse(_birthDateController.text) ?? patient!.birthDate;

      final newPatient = Patient.create(
        id: patient?.id,
        fullName: _nameController.text,
        birthDate: birthDate,
        phone: _phoneController.text,
        fin: _finController.text,
        allergies: _allergiesController.text,
        chronicConditions: _chronicController.text,
        notes: _notesController.text,
      );

      await repo.save(newPatient);

      _nameController.clear();
      _birthDateController.clear();
      _phoneController.clear();
      _finController.clear();
      _allergiesController.clear();
      _chronicController.clear();
      _notesController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? 'Pasient yeniləndi' : 'Pasient uğurla əlavə edildi')),
        );
      }
    } on ValidationException catch (e) {
      setState(() => _errorMessage = e.message);
    } on Exception catch (e) {
      setState(() => _errorMessage = 'Xəta: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _editPatient(Patient patient) async {
    _nameController.text = patient.fullName;
    _birthDateController.text = DateFormat('yyyy-MM-dd').format(patient.birthDate);
    _phoneController.text = patient.phone;
    _finController.text = patient.fin ?? '';
    _allergiesController.text = patient.allergies ?? '';
    _chronicController.text = patient.chronicConditions ?? '';
    _notesController.text = patient.notes ?? '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pasienti redaktə et'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_nameController, 'Ad Soyad', Icons.person),
              const SizedBox(height: 8),
              _buildTextField(_birthDateController, 'Doğum (yyyy-MM-dd)', Icons.cake),
              const SizedBox(height: 8),
              _buildTextField(_phoneController, 'Telefon', Icons.phone),
              const SizedBox(height: 8),
              _buildTextField(_finController, 'FIN', Icons.badge),
              const SizedBox(height: 8),
              _buildTextField(_allergiesController, 'Allergiyalar', Icons.warning_amber),
              const SizedBox(height: 8),
              _buildTextField(_chronicController, 'Xroniki', Icons.health_and_safety),
              const SizedBox(height: 8),
              _buildTextField(_notesController, 'Qeydlər', Icons.note),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ləğv et')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _addPatient(patient: patient);
            },
            child: Text(_isSaving ? 'Yenilənir...' : 'Yadda saxla'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePatient(Patient patient) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pasienti sil'),
        content: Text('${patient.fullName} pasientini silmək istədiyinizə əminsiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ləğv et')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await context.read<PatientRepository>().delete(patient.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pasient silindi')),
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
    final repo = context.read<PatientRepository>();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: Text(
            'Pasientlər',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Axtarış...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
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
                    Expanded(child: _buildTextField(_nameController, 'Ad Soyad', Icons.person)),
                    const SizedBox(width: AppTheme.spacing2),
                    Expanded(child: _buildTextField(_birthDateController, 'Doğum (yyyy-MM-dd)', Icons.cake)),
                    const SizedBox(width: AppTheme.spacing2),
                    Expanded(child: _buildTextField(_phoneController, 'Telefon', Icons.phone)),
                    const SizedBox(width: AppTheme.spacing2),
                    Expanded(child: _buildTextField(_finController, 'FIN', Icons.badge)),
                    const SizedBox(width: AppTheme.spacing2),
                    Expanded(child: _buildTextField(_allergiesController, 'Allergiyalar', Icons.warning_amber)),
                    const SizedBox(width: AppTheme.spacing2),
                    Expanded(child: _buildTextField(_chronicController, 'Xroniki', Icons.health_and_safety)),
                    const SizedBox(width: AppTheme.spacing2),
                    Expanded(child: _buildTextField(_notesController, 'Qeydlər', Icons.note)),
                    const SizedBox(width: AppTheme.spacing2),
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _addPatient,
                      icon: _isSaving
                          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.add_rounded),
                      label: const Text('Əlavə et'),
                    ),
                  ],
                );
              }
              return Wrap(
                spacing: AppTheme.spacing2,
                runSpacing: AppTheme.spacing2,
                children: [
                  SizedBox(width: 160, child: _buildTextField(_nameController, 'Ad Soyad', Icons.person)),
                  SizedBox(width: 150, child: _buildTextField(_birthDateController, 'Doğum (yyyy-MM-dd)', Icons.cake)),
                  SizedBox(width: 140, child: _buildTextField(_phoneController, 'Telefon', Icons.phone)),
                  SizedBox(width: 140, child: _buildTextField(_finController, 'FIN', Icons.badge)),
                  SizedBox(width: 140, child: _buildTextField(_allergiesController, 'Allergiyalar', Icons.warning_amber)),
                  SizedBox(width: 140, child: _buildTextField(_chronicController, 'Xroniki', Icons.health_and_safety)),
                  SizedBox(width: 140, child: _buildTextField(_notesController, 'Qeydlər', Icons.note)),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _addPatient,
                    icon: _isSaving
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.add_rounded),
                    label: const Text('Əlavə et'),
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: repo.all(),
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

              final patients = snapshot.data as List<Patient>? ?? [];

              if (patients.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline_rounded, size: 48, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: AppTheme.spacing3),
                      Text('Pasientlər yoxdur', style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppTheme.spacing2),
                      Text('Yuxarıdakı formadan pasient əlavə edin', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                );
              }

              final filtered = _searchQuery.isEmpty
                  ? patients
                  : patients.where((p) =>
                      p.fullName.toLowerCase().contains(_searchQuery) ||
                      p.phone.contains(_searchQuery) ||
                      (p.fin ?? '').toLowerCase().contains(_searchQuery) ||
                      (p.allergies ?? '').toLowerCase().contains(_searchQuery) ||
                      (p.chronicConditions ?? '').toLowerCase().contains(_searchQuery)
                    ).toList();

              if (filtered.isEmpty && _searchQuery.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: AppTheme.spacing3),
                      Text('Nəticə tapılmadı', style: theme.textTheme.titleMedium),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final patient = filtered[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppTheme.spacing2),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        child: Icon(Icons.person_rounded, color: theme.colorScheme.secondary),
                      ),
                      title: Text(
                        patient.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('${patient.phone} • ${patient.age} yaş'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: AppTheme.primary),
                            onPressed: () => _editPatient(patient),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_rounded, color: AppTheme.error),
                            onPressed: () => _deletePatient(patient),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PatientDetailScreen(patientId: patient.id),
                          ),
                        );
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(AppTheme.spacing4),
                          child: Wrap(
                            spacing: AppTheme.spacing3,
                            runSpacing: AppTheme.spacing2,
                            children: [
                              _InfoChip(label: 'FIN', value: patient.fin ?? 'Göstərilməyib'),
                              _InfoChip(label: 'Doğum', value: DateFormat('yyyy-MM-dd').format(patient.birthDate)),
                              _InfoChip(label: 'Allergiya', value: patient.allergies ?? 'Yox', isWarning: patient.allergies != null),
                              _InfoChip(label: 'Xroniki', value: patient.chronicConditions ?? 'Yox'),
                              if (patient.notes != null)
                                _InfoChip(label: 'Qeydlər', value: patient.notes!),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, [TextInputType? keyboardType]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        isDense: true,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
    this.isWarning = false,
  });

  final String label;
  final String value;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isWarning ? AppTheme.warningContainer : theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppTheme.borderRadiusSmall,
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          )),
          const SizedBox(height: 2),
          Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
