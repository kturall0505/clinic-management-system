import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/license_service.dart';

class LicenseLockScreen extends StatelessWidget {
  const LicenseLockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final license = context.watch<LicenseService>();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              Text(
                'Lisenziya müddəti bitib',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Sistemdən istifadə etmək üçün internetə qoşun və '
                'lisenziya serveri ilə əlaqə tənzimləyin.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  await license.checkNow();
                },
                child: const Text('Yenidən yoxla'),
              ),
              const SizedBox(height: 16),
              Text(
                'Son uğurlu yoxlanış: ${license.lastSuccess != null ? license.lastSuccess!.toString() : "Heç vaxt"}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
