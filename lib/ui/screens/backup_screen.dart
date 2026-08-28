import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/backup_service.dart';
import '../../core/repositories/repositories.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/audit_log_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isCreating = false;
  bool _isRestoring = false;
  List<BackupRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await context.read<BackupRecordRepository>().all();
    setState(() => _records = records);
  }

  Future<void> _createBackup() async {
    setState(() => _isCreating = true);
    try {
      final service = context.read<BackupService>();
      final record = await service.createBackup();
      await context.read<BackupRecordRepository>().save(record);

      final auth = context.read<AuthService>();
      final audit = context.read<AuditLogService>();
      await audit.log(
        userId: auth.currentUser?.id ?? '',
        userName: auth.currentUser?.fullName ?? 'System',
        userRole: auth.currentUser?.role ?? UserRole.admin,
        action: AuditAction.create,
        entityType: 'Backup',
        entityId: record.id,
        entityName: 'Backup ${record.recordsCount} records',
        changes: {'recordsCount': record.recordsCount, 'sizeBytes': record.sizeBytes},
      );

      await _loadRecords();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup uğurla yaradıldı')),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xəta: $e')),
        );
      }
    } finally {
      setState(() => _isCreating = false);
    }
  }

  Future<void> _restoreBackup(BackupRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backupdan bərpa et'),
        content: Text('${DateFormat('yyyy-MM-dd HH:mm').format(record.createdAt)} backupdan bərpa etmək istədiyinizə əminsiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ləğv et')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Bərpa et')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isRestoring = true);
    try {
      final service = context.read<BackupService>();
      await service.restoreBackup(record);

      final auth = context.read<AuthService>();
      final audit = context.read<AuditLogService>();
      await audit.log(
        userId: auth.currentUser?.id ?? '',
        userName: auth.currentUser?.fullName ?? 'System',
        userRole: auth.currentUser?.role ?? UserRole.admin,
        action: AuditAction.update,
        entityType: 'Backup',
        entityId: record.id,
        entityName: 'Restore',
        changes: {'recordsCount': record.recordsCount},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backupdan bərpa edildi')),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xəta: $e')),
        );
      }
    } finally {
      setState(() => _isRestoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup və Bərpa'),
        actions: [
          IconButton(
            icon: _isCreating
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.backup_rounded),
            onPressed: _isCreating ? null : _createBackup,
            tooltip: 'Yeni backup yarat',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Backup yarat', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppTheme.spacing2),
                  Text('Bütün məlumatları yedəkləyin və lazım olduqda bərpa edin.', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: AppTheme.spacing3),
                  FilledButton.icon(
                    onPressed: _isCreating ? null : _createBackup,
                    icon: _isCreating
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.backup_rounded),
                    label: Text(_isCreating ? 'Yaradılır...' : 'Backup yarat'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text('Backup tarixçəsi', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppTheme.spacing2),
          if (_records.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing4),
                child: Text('Hələ backup yoxdur', style: theme.textTheme.bodyMedium),
              ),
            )
          else
            ...List.generate(_records.length, (index) {
              final record = _records[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppTheme.spacing2),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppTheme.spacing3),
                  leading: CircleAvatar(
                    backgroundColor: record.isSuccessful ? AppTheme.successContainer : AppTheme.errorContainer,
                    child: Icon(record.isSuccessful ? Icons.check_rounded : Icons.error_rounded, color: record.isSuccessful ? AppTheme.success : AppTheme.error),
                  ),
                  title: Text('${record.recordsCount} qeyd', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${DateFormat('yyyy-MM-dd HH:mm').format(record.createdAt)} • ${_formatBytes(record.sizeBytes)}'),
                  trailing: FilledButton.tonalIcon(
                    onPressed: _isRestoring ? null : () => _restoreBackup(record),
                    icon: const Icon(Icons.restore_rounded, size: 18),
                    label: const Text('Bərpa et'),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
