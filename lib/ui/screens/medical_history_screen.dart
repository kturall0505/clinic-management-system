import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/repositories/repositories.dart';
import '../../core/models/models.dart';

class MedicalHistoryScreen extends StatefulWidget {
  final String patientId;

  const MedicalHistoryScreen({super.key, required this.patientId});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addVisit() async {
    setState(() => _isLoading = true);
    try {
      final visitRepo = context.read<MedicalVisitRepository>();
      final visit = MedicalVisit.create(
        patientId: widget.patientId,
        doctorId: 'current_doctor',
        visitDate: DateTime.now(),
        diagnosis: '',
        symptoms: '',
        treatment: '',
        notes: '',
      );
      await visitRepo.save(visit);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ziyarət əlavə edildi')),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xəta: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visitRepo = context.read<MedicalVisitRepository>();
    final medicalInfoRepo = context.read<PatientMedicalInfoRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tibbi Tarixçə'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ziyarətlər'),
            Tab(text: 'Tibbi Məlumat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVisitsTab(visitRepo, theme),
          _buildMedicalInfoTab(medicalInfoRepo, theme),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _addVisit,
        child: _isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildVisitsTab(MedicalVisitRepository repo, ThemeData theme) {
    return FutureBuilder(
      future: repo.findByPatientId(widget.patientId),
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

        final visits = snapshot.data as List<MedicalVisit>? ?? [];

        if (visits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_rounded, size: 48, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(height: AppTheme.spacing3),
                Text('Ziyarət tarixçəsi boşdur', style: theme.textTheme.titleMedium),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          itemCount: visits.length,
          itemBuilder: (context, index) {
            final visit = visits[index];
            return Card(
              margin: const EdgeInsets.only(bottom: AppTheme.spacing2),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(Icons.medical_services_rounded, color: theme.colorScheme.primary),
                ),
                title: Text(
                  'Ziyarət #${visits.length - index}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(visit.visitDate)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (visit.diagnosis != null) ...[
                          _InfoRow(label: 'Diaqnoz', value: visit.diagnosis!),
                          const SizedBox(height: AppTheme.spacing2),
                        ],
                        if (visit.symptoms != null) ...[
                          _InfoRow(label: 'Simptomlar', value: visit.symptoms!),
                          const SizedBox(height: AppTheme.spacing2),
                        ],
                        if (visit.treatment != null) ...[
                          _InfoRow(label: 'Müalicə', value: visit.treatment!),
                          const SizedBox(height: AppTheme.spacing2),
                        ],
                        if (visit.notes != null) _InfoRow(label: 'Qeydlər', value: visit.notes!),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMedicalInfoTab(PatientMedicalInfoRepository repo, ThemeData theme) {
    return FutureBuilder(
      future: repo.findByPatientId(widget.patientId),
      builder: (context, snapshot) {
        final info = snapshot.data as PatientMedicalInfo?;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (info == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline_rounded, size: 48, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(height: AppTheme.spacing3),
                Text('Tibbi məlumat yoxdur', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppTheme.spacing2),
                FilledButton.icon(
                  onPressed: () => _showMedicalInfoForm(repo),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Əlavə et'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(AppTheme.spacing4),
              children: [
                if (info.gender != null) _InfoRow(label: 'Cins', value: info.gender!.label),
                if (info.bloodType != null) _InfoRow(label: 'Qan qrupu', value: info.bloodType!.label),
                if (info.heightCm != null) _InfoRow(label: 'Boy', value: '${info.heightCm!.toStringAsFixed(1)} sm'),
                if (info.weightKg != null) _InfoRow(label: 'Çəki', value: '${info.weightKg!.toStringAsFixed(1)} kq'),
                if (info.bmi != null) _InfoRow(label: 'VTK', value: info.bmi!.toStringAsFixed(1)),
                if (info.emergencyContact != null) _InfoRow(label: 'Təcili əlaqə', value: info.emergencyContact!),
                if (info.emergencyContactPhone != null) _InfoRow(label: 'Təcili telefon', value: info.emergencyContactPhone!),
                if (info.insuranceProvider != null) _InfoRow(label: 'Sığorta', value: info.insuranceProvider!),
                if (info.insuranceNumber != null) _InfoRow(label: 'Sığorta nömrəsi', value: info.insuranceNumber!),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
              child: FilledButton.icon(
                onPressed: () => _showMedicalInfoForm(repo, info),
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Redaktə et'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMedicalInfoForm(PatientMedicalInfoRepository repo, [PatientMedicalInfo? existing]) async {
    final gender = existing?.gender ?? Gender.male;
    final bloodType = existing?.bloodType;
    final heightController = TextEditingController(text: existing?.heightCm?.toString() ?? '');
    final weightController = TextEditingController(text: existing?.weightKg?.toString() ?? '');
    final emergencyContactController = TextEditingController(text: existing?.emergencyContact ?? '');
    final emergencyPhoneController = TextEditingController(text: existing?.emergencyContactPhone ?? '');
    final insuranceProviderController = TextEditingController(text: existing?.insuranceProvider ?? '');
    final insuranceNumberController = TextEditingController(text: existing?.insuranceNumber ?? '');

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Tibbi məlumat əlavə et' : 'Tibbi məlumatı redaktə et'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Gender>(
                  decoration: const InputDecoration(labelText: 'Cins'),
                  value: gender,
                  items: Gender.values.map((g) => DropdownMenuItem(value: g, child: Text(g.label))).toList(),
                  onChanged: (v) {},
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<BloodType>(
                  decoration: const InputDecoration(labelText: 'Qan qrupu'),
                  value: bloodType,
                  items: BloodType.values.map((b) => DropdownMenuItem(value: b, child: Text(b.label))).toList(),
                  onChanged: (v) {},
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: heightController,
                  decoration: const InputDecoration(labelText: 'Boy (sm)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: weightController,
                  decoration: const InputDecoration(labelText: 'Çəki (kq)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: emergencyContactController,
                  decoration: const InputDecoration(labelText: 'Təcili əlaqə'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: emergencyPhoneController,
                  decoration: const InputDecoration(labelText: 'Təcili telefon'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: insuranceProviderController,
                  decoration: const InputDecoration(labelText: 'Sığorta şirkəti'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: insuranceNumberController,
                  decoration: const InputDecoration(labelText: 'Sığorta nömrəsi'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ləğv et')),
            FilledButton(
              onPressed: () async {
                final height = double.tryParse(heightController.text);
                final weight = double.tryParse(weightController.text);
                final info = PatientMedicalInfo.create(
                  id: existing?.id,
                  patientId: widget.patientId,
                  gender: gender,
                  bloodType: bloodType,
                  heightCm: height,
                  weightKg: weight,
                  emergencyContact: emergencyContactController.text,
                  emergencyContactPhone: emergencyPhoneController.text,
                  insuranceProvider: insuranceProviderController.text,
                  insuranceNumber: insuranceNumberController.text,
                );
                await repo.save(info);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(existing == null ? 'Tibbi məlumat əlavə edildi' : 'Tibbi məlumat yeniləndi')),
                  );
                  setState(() {});
                }
              },
              child: const Text('Yadda saxla'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _InfoRow({required String label, required String value}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
