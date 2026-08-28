import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/repositories/repositories.dart';
import '../../core/models/models.dart';
import '../../core/services/approval_service.dart';

class ClinicsManagementScreen extends StatefulWidget {
  const ClinicsManagementScreen({super.key});

  @override
  State<ClinicsManagementScreen> createState() => _ClinicsManagementScreenState();
}

class _ClinicsManagementScreenState extends State<ClinicsManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clinicsRepo = context.read<ClinicRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Klinikalar'),
      ),
      body: FutureBuilder(
        future: clinicsRepo.all(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final clinics = snapshot.data as List<Clinic>? ?? [];

          if (clinics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_hospital_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: AppTheme.spacing3),
                  Text('Klinika yoxdur', style: theme.textTheme.titleMedium),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            itemCount: clinics.length,
            itemBuilder: (context, index) {
              final clinic = clinics[index];
              final statusColor = switch (clinic.status) {
                SubscriptionStatus.active => AppTheme.success,
                SubscriptionStatus.pending => AppTheme.warning,
                SubscriptionStatus.expired => AppTheme.error,
                SubscriptionStatus.suspended => AppTheme.error,
              };

              return Card(
                margin: const EdgeInsets.only(bottom: AppTheme.spacing2),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppTheme.spacing3),
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withValues(alpha: 0.12),
                    child: Icon(Icons.local_hospital_rounded, color: statusColor),
                  ),
                  title: Text(clinic.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(clinic.email),
                      if (clinic.approvedAt != null)
                        Text('Təsdiq: ${DateFormat('yyyy-MM-dd').format(clinic.approvedAt!)}', style: theme.textTheme.bodySmall),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      clinic.status.label,
                      style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
