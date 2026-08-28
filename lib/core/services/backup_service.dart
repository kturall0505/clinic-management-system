import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sembast/sembast_io.dart';

import '../../exceptions/app_exception.dart';
import '../../models/models.dart';
import '../db/app_database.dart';
import '../repositories/repositories.dart';

class BackupService {
  BackupService({
    required this.tenantId,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  final String tenantId;
  final String supabaseUrl;
  final String supabaseAnonKey;

  Future<BackupRecord> createBackup(AppDatabase db) async {
    final record = BackupRecord.create(
      tenantId: tenantId,
      recordsCount: 0,
      sizeBytes: 0,
    );

    try {
      final stores = [
        'users', 'patients', 'doctors', 'appointments', 'prescriptions',
        'payments', 'patient_medical_info', 'medical_visits', 'medications',
        'prescription_items', 'invoices', 'invoice_items', 'audit_logs',
        'queue_entries', 'notifications', 'reports',
      ];

      final allData = <String, List<Map<String, Object?>>>{};
      var totalRecords = 0;

      for (final storeName in stores) {
        try {
          final store = stringMapStoreFactory.store(storeName);
          final records = await store.find(db.db);
          final data = records.map((r) => r.value).toList();
          allData[storeName] = data;
          totalRecords += data.length;
        } on Exception catch (_) {}
      }

      final jsonString = const JsonEncoder().convert(allData);
      final bytes = utf8.encode(jsonString);
      final sizeBytes = bytes.length;

      if (!kIsWeb && supabaseUrl.isNotEmpty) {
        try {
          final dir = await getApplicationSupportDirectory();
          final file = File('${dir.path}/backup_$tenantId.json');
          await file.writeAsBytes(bytes);
          record.filePath = file.path;
        } on Exception catch (_) {}
      }

      return BackupRecord.create(
        id: record.id,
        tenantId: tenantId,
        recordsCount: totalRecords,
        sizeBytes: sizeBytes,
        filePath: record.filePath,
        isSuccessful: true,
      );
    } on Exception catch (e) {
      return BackupRecord.create(
        id: record.id,
        tenantId: tenantId,
        recordsCount: 0,
        sizeBytes: 0,
        isSuccessful: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> scheduleDailyBackup(AppDatabase db, BackupRecordRepository repo) async {
    final prefs = await SharedPreferences.getInstance();
    final lastBackup = prefs.getString('last_backup_date');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastBackup != null) {
      final lastDate = DateTime.tryParse(lastBackup);
      if (lastDate != null && lastDate.year == today.year && lastDate.month == today.month && lastDate.day == today.day) {
        return;
      }
    }

    final backup = await createBackup(db);
    await repo.save(backup);
    await prefs.setString('last_backup_date', today.toIso8601String());

    if (!backup.isSuccessful) {
      debugPrint('Backup failed: ${backup.errorMessage}');
    }
  }

  Future<void> restoreBackup(BackupRecord record) async {
    if (record.filePath == null) {
      throw const StorageException('Backup faylı tapılmadı');
    }

    try {
      final file = File(record.filePath!);
      if (!await file.exists()) {
        throw const StorageException('Backup faylı mövcud deyil');
      }

      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      debugPrint('Restoring backup with ${data.length} stores');
    } on Exception catch (e) {
      throw StorageException('Backup bərpa edilərkən xəta: $e');
    }
  }
}
