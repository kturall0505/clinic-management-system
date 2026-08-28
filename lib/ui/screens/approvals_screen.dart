import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/repositories/repositories.dart';
import '../../core/models/models.dart';
import '../../core/services/approval_service.dart';
import '../../core/services/auth_service.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final approvalsRepo = context.read<ApprovalRepository>();
    final approvalService = context.read<ApprovalService>();
    final auth = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Təsdiqlər'),
      ),
      body: FutureBuilder(
        future: approvalsRepo.findPending(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pending = snapshot.data as List<ApprovalRequest>? ?? [];

          if (pending.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.approval_rounded, size: 48, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: AppTheme.spacing3),
                  Text('Gözləyən təsdiq yoxdur', style: theme.textTheme.titleMedium),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            itemCount: pending.length,
            itemBuilder: (context, index) {
              final approval = pending[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppTheme.spacing2),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.pending_rounded, color: AppTheme.warning, size: 20),
                          const SizedBox(width: AppTheme.spacing2),
                          Expanded(
                            child: Text(
                              approval.type.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            DateFormat('yyyy-MM-dd HH:mm').format(approval.createdAt),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacing2),
                      Text('Klinika: ${approval.clinicId}', style: theme.textTheme.bodyMedium),
                      const SizedBox(height: AppTheme.spacing1),
                      Text('Tələb edən: ${approval.requestedBy}', style: theme.textTheme.bodySmall),
                      const SizedBox(height: AppTheme.spacing3),
                      Row(
                        children: [
                          FilledButton.icon(
                            onPressed: () async {
                              await approvalService.approve(approval.id, auth.currentUser?.id ?? '');
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Təsdiq edildi')),
                                );
                                setState(() {});
                              }
                            },
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Təsdiq et'),
                          ),
                          const SizedBox(width: AppTheme.spacing2),
                          FilledButton.tonalIcon(
                            onPressed: () async {
                              await approvalService.reject(approval.id, auth.currentUser?.id ?? '');
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Rədd edildi')),
                                );
                                setState(() {});
                              }
                            },
                            icon: const Icon(Icons.close_rounded),
                            label: const Text('Rədd et'),
                          ),
                        ],
                      ),
                    ],
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
