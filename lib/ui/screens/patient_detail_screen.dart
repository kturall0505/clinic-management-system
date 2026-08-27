import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';
import '../../core/repositories/repositories.dart';
import '../../core/models/models.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final patientRepo = context.read<PatientRepository>();
    final medicalInfoRepo = context.read<PatientMedicalInfoRepository>();
    final visitRepo = context.read<MedicalVisitRepository>();

    return FutureBuilder(
      future: Future.wait([
        patientRepo.all(),
        medicalInfoRepo.all(),
        visitRepo.all(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final patients = snapshot.data![0] as List<Patient>;
        final medicalInfos = snapshot.data![1] as List<PatientMedicalInfo>;
        final visits = snapshot.data![2] as List<MedicalVisit>;

        final patient = patients.firstWhere((p) => p.id == widget.patientId);
        final medicalInfo = medicalInfos.firstWhereOrNull((m) => m.patientId == widget.patientId);
        final patientVisits = visits.where((v) => v.patientId == widget.patientId).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(patient.fullName),
            actions: [
              IconButton(
                icon: const Icon(Icons.upload_file_rounded),
                onPressed: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Fayl seçildi: ${picked.name}')),
                    );
                  }
                },
                tooltip: 'Fayl yüklə',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPatientCard(patient, theme),
                const SizedBox(height: AppTheme.spacing4),
                if (medicalInfo != null) _buildMedicalInfoCard(medicalInfo, theme),
                const SizedBox(height: AppTheme.spacing4),
                _buildVisitHistoryCard(patientVisits, theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatientCard(Patient patient, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(Icons.person_rounded, size: 40, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: AppTheme.spacing4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.fullName,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('${patient.age} yaş • ${patient.phone}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing4),
            Wrap(
              spacing: AppTheme.spacing2,
              runSpacing: AppTheme.spacing2,
              children: [
                if (patient.fin != null)
                  _InfoChip(label: 'FIN', value: patient.fin!),
                _InfoChip(
                  label: 'Doğum',
                  value: '${patient.birthDate.year}-${patient.birthDate.month.toString().padLeft(2, '0')}',
                ),
              ],
            ),
            if (patient.allergies != null) ...[
              const SizedBox(height: AppTheme.spacing2),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing3),
                decoration: BoxDecoration(
                  color: AppTheme.warningContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Allergiya: ${patient.allergies}',
                        style: const TextStyle(color: AppTheme.warning),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (patient.chronicConditions != null) ...[
              const SizedBox(height: AppTheme.spacing2),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing3),
                decoration: BoxDecoration(
                  color: AppTheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.health_and_safety_rounded, color: AppTheme.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Xroniki: ${patient.chronicConditions}',
                        style: const TextStyle(color: AppTheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalInfoCard(PatientMedicalInfo info, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tibbi Məlumat',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacing3),
            Wrap(
              spacing: AppTheme.spacing2,
              runSpacing: AppTheme.spacing2,
              children: [
                if (info.gender != null) _InfoChip(label: 'Cins', value: info.gender!.label),
                if (info.bloodType != null) _InfoChip(label: 'Qan qrupu', value: info.bloodType!.label),
                if (info.heightCm != null) _InfoChip(label: 'Boy', value: '${info.heightCm!.toStringAsFixed(0)} sm'),
                if (info.weightKg != null) _InfoChip(label: 'Çəki', value: '${info.weightKg!.toStringAsFixed(1)} kq'),
                if (info.bmi != null) _InfoChip(label: 'VTK', value: info.bmi!.toStringAsFixed(1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitHistoryCard(List<MedicalVisit> visits, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ziyarət Tarixçəsi',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacing3),
            if (visits.isEmpty)
              Text('Hələ ziyarət yoxdur', style: theme.textTheme.bodyMedium),
            ...visits.map((visit) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacing3),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing2),
                  Expanded(
                    child: Text(
                      '${visit.visitDate.year}-${visit.visitDate.month.toString().padLeft(2, '0')}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  if (visit.diagnosis != null)
                    Expanded(
                      flex: 2,
                      child: Text(
                        visit.diagnosis!,
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _InfoChip({required String label, required String value}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
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
