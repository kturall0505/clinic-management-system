import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/repositories/repositories.dart';
import '../../core/models/models.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  String? _selectedEntityType;
  String? _selectedAction;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auditRepo = context.read<AuditLogRepository>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          child: Text(
            'Audit Jurnalı',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
          child: Wrap(
            spacing: AppTheme.spacing2,
            runSpacing: AppTheme.spacing2,
            children: [
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Axtarış',
                    prefixIcon: Icon(Icons.search_rounded),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Entity',
                    prefixIcon: Icon(Icons.category_rounded),
                    isDense: true,
                  ),
                  value: _selectedEntityType,
                  items: const [
                    DropdownMenuItem(value: 'User', child: Text('İstifadəçi')),
                    DropdownMenuItem(value: 'Patient', child: Text('Pasient')),
                    DropdownMenuItem(value: 'Doctor', child: Text('Həkim')),
                    DropdownMenuItem(value: 'Appointment', child: Text('Randevu')),
                    DropdownMenuItem(value: 'Prescription', child: Text('Resept')),
                    DropdownMenuItem(value: 'Invoice', child: Text('Faktura')),
                    DropdownMenuItem(value: 'Auth', child: Text('Giriş')),
                  ],
                  onChanged: (v) => setState(() => _selectedEntityType = v),
                ),
              ),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Əməliyyat',
                    prefixIcon: Icon(Icons.history_rounded),
                    isDense: true,
                  ),
                  value: _selectedAction,
                  items: AuditAction.values.map((a) => DropdownMenuItem(value: a.name, child: Text(a.label))).toList(),
                  onChanged: (v) => setState(() => _selectedAction = v),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing3),
        Expanded(
          child: FutureBuilder(
            future: auditRepo.all(),
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
                      Text('Xəta baş verdi', style: theme.textScheme.titleMedium),
                    ],
                  ),
                );
              }

              var logs = snapshot.data as List<AuditLog>? ?? [];

              if (_selectedEntityType != null) {
                logs = logs.where((l) => l.entityType == _selectedEntityType).toList();
              }
              if (_selectedAction != null) {
                logs = logs.where((l) => l.action.name == _selectedAction).toList();
              }
              if (_searchController.text.isNotEmpty) {
                final query = _searchController.text.toLowerCase();
                logs = logs.where((l) =>
                  l.userName.toLowerCase().contains(query) ||
                  l.entityName?.toLowerCase().contains(query) == true ||
                  l.entityType.toLowerCase().contains(query)
                ).toList();
              }

              if (logs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_rounded, size: 48, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: AppTheme.spacing3),
                      Text('Audit log yoxdur', style: theme.textTheme.titleMedium),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final actionColor = switch (log.action) {
                    AuditAction.create => AppTheme.success,
                    AuditAction.update => AppTheme.primary,
                    AuditAction.delete => AppTheme.error,
                    AuditAction.login => AppTheme.secondary,
                    AuditAction.logout => theme.colorScheme.onSurfaceVariant,
                    AuditAction.view => theme.colorScheme.onSurfaceVariant,
                    AuditAction.export => AppTheme.warning,
                    AuditAction.print => theme.colorScheme.onSurfaceVariant,
                  };

                  return Card(
                    margin: const EdgeInsets.only(bottom: AppTheme.spacing2),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(AppTheme.spacing3),
                      leading: CircleAvatar(
                        backgroundColor: actionColor.withValues(alpha: 0.12),
                        child: Icon(_getActionIcon(log.action), color: actionColor, size: 20),
                      ),
                      title: Text(
                        '${log.userName} - ${log.action.label}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${log.entityType}${log.entityName != null ? ': ${log.entityName}' : ''}'),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('yyyy-MM-dd HH:mm:ss').format(log.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: actionColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          log.userRole.label,
                          style: TextStyle(fontSize: 12, color: actionColor),
                        ),
                      ),
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

  IconData _getActionIcon(AuditAction action) {
    switch (action) {
      case AuditAction.create:
        return Icons.add_rounded;
      case AuditAction.update:
        return Icons.edit_rounded;
      case AuditAction.delete:
        return Icons.delete_rounded;
      case AuditAction.login:
        return Icons.login_rounded;
      case AuditAction.logout:
        return Icons.logout_rounded;
      case AuditAction.view:
        return Icons.visibility_rounded;
      case AuditAction.export:
        return Icons.download_rounded;
      case AuditAction.print:
        return Icons.print_rounded;
    }
  }
}
