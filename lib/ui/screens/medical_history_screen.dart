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
              ],
            ),
          );
        }

        return ListView(
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
        );
      },
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
