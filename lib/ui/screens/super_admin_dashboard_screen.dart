import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../core/repositories/repositories.dart';
import 'clinics_management_screen.dart';
import 'approvals_screen.dart';
import 'settings_screen.dart';

class SuperAdminDashboardScreen extends StatelessWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthService>();
    final clinicsRepo = context.read<ClinicRepository>();
    final approvalsRepo = context.read<ApprovalRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Çıxış',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Çıxış'),
                  content: const Text('Hesabdan çıxmaq istədiyinizə əminsiniz?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ləğv et')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Çıx')),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                context.read<AuthService>().logout();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([
          clinicsRepo.all(),
          approvalsRepo.findPending(),
        ]),
        builder: (context, snapshot) {
          final clinics = snapshot.data?[0] as List<Clinic>? ?? [];
          final pendingApprovals = snapshot.data?[1] as List<ApprovalRequest>? ?? [];

          return ListView(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Klinikalar',
                      value: '${clinics.length}',
                      icon: Icons.local_hospital_rounded,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing2),
                  Expanded(
                    child: _StatCard(
                      title: 'Təsdiq Gözləyir',
                      value: '${pendingApprovals.length}',
                      icon: Icons.pending_rounded,
                      color: AppTheme.warning,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing2),
                  Expanded(
                    child: _StatCard(
                      title: 'Aktiv Abunələr',
                      value: '${clinics.where((c) => c.status == SubscriptionStatus.active).length}',
                      icon: Icons.verified_rounded,
                      color: AppTheme.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing4),
              _buildSectionTitle(theme, 'İdarəetmə'),
              const SizedBox(height: AppTheme.spacing3),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.local_hospital_rounded),
                      title: const Text('Klinikalar'),
                      subtitle: const Text('Bütün klinikaları idarə et'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ClinicsManagementScreen()));
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.approval_rounded),
                      title: const Text('Təsdiqlər'),
                      subtitle: Text('${pendingApprovals.length} təsdiq gözləyir'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ApprovalsScreen()));
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.people_rounded),
                      title: const Text('İstifadəçilər'),
                      subtitle: const Text('Bütün istifadəçiləri idarə et'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const UsersScreen()));
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.history_rounded),
                      title: const Text('Audit Jurnalı'),
                      subtitle: const Text('Bütün platform logları'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AuditLogScreen()));
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.backup_rounded),
                      title: const Text('Backup'),
                      subtitle: const Text('Platform backup'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupScreen()));
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.settings_rounded),
                      title: const Text('Sistem Ayarları'),
                      subtitle: const Text('SMTP, SMS, AI, API keys'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing3),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppTheme.spacing2),
            Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
            Text(title, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
