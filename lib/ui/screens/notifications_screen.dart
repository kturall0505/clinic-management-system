import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/repositories/repositories.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = context.read<AppNotificationRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirişlər'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_chat_read_rounded),
            tooltip: 'Hamısını oxunmuş kimi işarələ',
            onPressed: () async {
              final notifications = await repo.all();
              for (final n in notifications) {
                if (!n.isRead) {
                  await repo.save(n.copyWith(isRead: true, readAt: DateTime.now()));
                }
              }
              setState(() {});
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bildirişlər oxunmuş kimi işarələndi')),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: repo.all(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data as List<AppNotification>? ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_rounded, size: 48, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: AppTheme.spacing3),
                  Text('Bildiriş yoxdur', style: theme.textTheme.titleMedium),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              final typeColor = switch (n.type) {
                NotificationType.appointmentReminder => AppTheme.primary,
                NotificationType.appointmentConfirmation => AppTheme.success,
                NotificationType.paymentDue => AppTheme.warning,
                NotificationType.labResult => AppTheme.secondary,
                NotificationType.general => theme.colorScheme.onSurfaceVariant,
              };

              return Card(
                margin: const EdgeInsets.only(bottom: AppTheme.spacing2),
                color: n.isRead ? null : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppTheme.spacing3),
                  leading: CircleAvatar(
                    backgroundColor: typeColor.withValues(alpha: 0.12),
                    child: Icon(_getTypeIcon(n.type), color: typeColor, size: 20),
                  ),
                  title: Text(
                    n.title,
                    style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.message),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('yyyy-MM-dd HH:mm').format(n.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  trailing: n.isRead
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.check_rounded, color: AppTheme.success),
                          onPressed: () async {
                            await repo.save(n.copyWith(isRead: true, readAt: DateTime.now()));
                            setState(() {});
                          },
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.appointmentReminder:
        return Icons.event_available_rounded;
      case NotificationType.appointmentConfirmation:
        return Icons.event_rounded;
      case NotificationType.paymentDue:
        return Icons.payment_rounded;
      case NotificationType.labResult:
        return Icons.science_rounded;
      case NotificationType.general:
        return Icons.notifications_rounded;
    }
  }
}
