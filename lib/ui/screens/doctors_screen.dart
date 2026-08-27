import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/repositories/repositories.dart';
import '../../core/models/models.dart';

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
  final _searchController = TextEditingController();

  bool _isSaving = false;
  String? _errorMessage;
  String _searchQuery = '';

  Future<void> _addDoctor() async {
    if (_nameController.text.isEmpty) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final repo = context.read<DoctorRepository>();
      final fee = double.tryParse(_feeController.text);
      if (fee == null || fee < 0) {
        throw const ValidationException('Konsultasiya haqqı düzgün deyil');
      }

      await repo.save(Doctor.create(
        fullName: _nameController.text,
        specialty: _specialtyController.text,
        phone: _phoneController.text,
        consultationFee: fee,
        schedule: _scheduleController.text,
        experience: _experienceController.text,
      ));

      _nameController.clear();
      _specialtyController.clear();
      _phoneController.clear();
      _feeController.clear();
      _scheduleController.clear();
      _experienceController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Həkim uğurla əlavə edildi')),
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

  @override
  Widget build(BuildContext context) {
    final repo = context.read<DoctorRepository>();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: Text(
            'Həkimlər',
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
              final isWide = constraints.maxWidth >= 800;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: _buildTextField(_nameController, 'Ad Soyad', Icons.person)),
                    const SizedBox(width: AppTheme.spacing2),
                    Expanded(child: _buildTextField(_specialtyController, 'İxtisas', Icons.medical_services)),
                    const SizedBox(width: AppTheme.spacing2),
                    Expanded(child: _buildTextField(_phoneController, 'Telefon', Icons.phone)),
                    const SizedBox(width: AppTheme.spacing2),
                    Expanded(child: _buildTextField(_feeController, 'Haqq (AZN)', Icons.attach_money, TextInputType.number)),
                    const SizedBox(width: AppTheme.spacing2),
                    Expanded(child: _buildTextField(_experienceController, 'Təcrübə', Icons.work)),
                    const SizedBox(width: AppTheme.spacing2),
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _addDoctor,
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
                  SizedBox(width: 160, child: _buildTextField(_specialtyController, 'İxtisas', Icons.medical_services)),
                  SizedBox(width: 140, child: _buildTextField(_phoneController, 'Telefon', Icons.phone)),
                  SizedBox(width: 120, child: _buildTextField(_feeController, 'Haqq (AZN)', Icons.attach_money, TextInputType.number)),
                  SizedBox(width: 140, child: _buildTextField(_experienceController, 'Təcrübə', Icons.work)),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _addDoctor,
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

              final doctors = snapshot.data as List<Doctor>? ?? [];

              if (doctors.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.medical_services_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: AppTheme.spacing3),
                      Text('Həkimlər yoxdur', style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppTheme.spacing2),
                      Text('Yuxarıdakı formadan həkim əlavə edin', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                );
              }

              final filtered = _searchQuery.isEmpty
                  ? doctors
                  : doctors.where((d) =>
                      d.fullName.toLowerCase().contains(_searchQuery) ||
                      d.specialty.toLowerCase().contains(_searchQuery) ||
                      d.phone.contains(_searchQuery)
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
                  final doctor = filtered[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppTheme.spacing2),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(AppTheme.spacing3),
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(Icons.person_rounded, color: theme.colorScheme.primary),
                      ),
                      title: Text(
                        doctor.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${doctor.specialty} • ${doctor.phone}'),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.successContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${doctor.consultationFee.toStringAsFixed(2)} AZN',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.success),
                                ),
                              ),
                              if (doctor.experience != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.warningContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    doctor.experience!,
                                    style: const TextStyle(fontSize: 12, color: AppTheme.warning),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      isThreeLine: true,
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, [
    TextInputType? keyboardType,
  ]) {
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
