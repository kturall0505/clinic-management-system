import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../exceptions/app_exception.dart';
import '../../models/models.dart';
import '../repositories/repositories.dart';

class QueueService {
  QueueService({required this.tenantId});

  final String tenantId;

  Future<QueueEntry> createQueueEntry({
    required QueueEntryRepository repo,
    required String patientId,
    required String doctorId,
    required String appointmentId,
  }) async {
    final existing = await repo.findActiveByPatientId(patientId);
    if (existing != null) {
      throw ValidationException('Pasientin artıq aktiv növbəsi var');
    }

    final doctorEntries = await repo.findByDoctorId(doctorId);
    final activeEntries = doctorEntries.where((e) =>
      e.status == QueueStatus.waiting ||
      e.status == QueueStatus.called ||
      e.status == QueueStatus.inProgress
    ).toList();

    final nextNumber = activeEntries.isEmpty ? 1 : (activeEntries.map((e) => e.queueNumber).reduce((a, b) => a > b ? a : b) + 1);

    return QueueEntry.create(
      patientId: patientId,
      doctorId: doctorId,
      appointmentId: appointmentId,
      queueNumber: nextNumber,
      status: QueueStatus.waiting,
    );
  }

  Future<void> callNext(QueueEntryRepository repo, String doctorId) async {
    final entries = await repo.findByDoctorId(doctorId);
    final waiting = entries.where((e) => e.status == QueueStatus.waiting).toList();
    if (waiting.isEmpty) return;

    waiting.sort((a, b) => a.queueNumber.compareTo(b.queueNumber));
    final next = waiting.first;

    await repo.save(next.copyWith(
      status: QueueStatus.called,
      calledAt: DateTime.now(),
    ));
  }

  Future<void> markInProgress(QueueEntryRepository repo, String entryId) async {
    final entries = await repo.all();
    final entry = entries.firstWhereOrNull((e) => e.id == entryId);
    if (entry == null) return;

    await repo.save(entry.copyWith(
      status: QueueStatus.inProgress,
    ));
  }

  Future<void> markCompleted(QueueEntryRepository repo, String entryId) async {
    final entries = await repo.all();
    final entry = entries.firstWhereOrNull((e) => e.id == entryId);
    if (entry == null) return;

    await repo.save(entry.copyWith(
      status: QueueStatus.completed,
      completedAt: DateTime.now(),
    ));
  }

  Future<void> markSkipped(QueueEntryRepository repo, String entryId) async {
    final entries = await repo.all();
    final entry = entries.firstWhereOrNull((e) => e.id == entryId);
    if (entry == null) return;

    await repo.save(entry.copyWith(
      status: QueueStatus.skipped,
      completedAt: DateTime.now(),
    ));
  }
}
