import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/services/license_service.dart';

class LicenseLockScreen extends StatelessWidget {
  const LicenseLockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final license = context.watch<LicenseService>();
    final last = license.lastSuccess;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off,
                      size: 48, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Lisenziya yoxlaması tələb olunur',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    last == null
                        ? 'Sistem hələ lisenziya serveri ilə əlaqə qura bilməyib. '
                            'Davam etmək üçün internet bağlantısı lazımdır.'
                        : 'Son uğurlu yoxlama: '
                            '${DateFormat('dd.MM.yyyy HH:mm').format(last)}. '
                            'Sistem gündə ən azı bir dəfə onlayn olmalıdır.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => license.checkNow(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Yenidən yoxla'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
