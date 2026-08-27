import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/license_service.dart';

class LicenseLockScreen extends StatelessWidget {
  const LicenseLockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final license = context.watch<LicenseService>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppTheme.errorContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(Icons.lock_rounded, size: 48, color: theme.colorScheme.error),
                ),
                const SizedBox(height: AppTheme.spacing6),
                Text(
                  'Lisenziya müddəti bitib',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing3),
                Text(
                  'Sistemdən istifadə etmək üçün internetə qoşun və '
                  'lisenziya serveri ilə əlaqə tənzimləyin.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                if (license.lastError != null) ...[
                  const SizedBox(height: AppTheme.spacing4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spacing3),
                    decoration: BoxDecoration(
                      color: AppTheme.warningContainer,
                      borderRadius: AppTheme.borderRadiusMedium,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 20),
                        const SizedBox(width: AppTheme.spacing2),
                        Expanded(
                          child: Text(
                            license.lastError!,
                            style: const TextStyle(color: AppTheme.warning, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppTheme.spacing4),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      await license.checkNow();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Yenidən yoxla'),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing3),
                Text(
                  'Son uğurlu yoxlanış: ${license.lastSuccess != null ? DateFormat('yyyy-MM-dd HH:mm').format(license.lastSuccess!) : "Heç vaxt"}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing2),
                Text(
                  'Müddət: ${(license.gracePeriod.inHours / 24).toStringAsFixed(0)} gün',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
