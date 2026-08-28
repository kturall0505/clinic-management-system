import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/models.dart';
import '../repositories/repositories.dart';

class ApprovalService {
  ApprovalService({
    required this.approvals,
    required this.auditLogs,
  });

  final ApprovalRepository approvals;
  final AuditLogRepository auditLogs;

  Future<ApprovalRequest> requestApproval({
    required String clinicId,
    required String requestedBy,
    required ApprovalType type,
    required Map<String, Object?> changes,
  }) async {
    final request = ApprovalRequest.create(
      clinicId: clinicId,
      requestedBy: requestedBy,
      type: type,
      changes: changes,
    );

    await approvals.save(request);

    await auditLogs.save(AuditLog.create(
      userId: requestedBy,
      userName: requestedBy,
      userRole: UserRole.clinicAdmin,
      action: AuditAction.update,
      entityType: 'Approval',
      entityId: request.id,
      entityName: type.name,
      changes: {'status': 'pending'},
    ));

    return request;
  }

  Future<void> approve(String approvalId, String superAdminId, {String? note}) async {
    final request = await approvals.findPending().then((list) => list.firstWhere((r) => r.id == approvalId));
    final updated = request.copyWith(
      status: ApprovalStatus.approved,
      reviewedBy: superAdminId,
      reviewedAt: DateTime.now(),
      reviewNote: note,
    );

    await approvals.save(updated);

    await auditLogs.save(AuditLog.create(
      userId: superAdminId,
      userName: superAdminId,
      userRole: UserRole.superAdmin,
      action: AuditAction.update,
      entityType: 'Approval',
      entityId: approvalId,
      entityName: 'Approved',
      changes: {'status': 'approved', 'note': note},
    ));
  }

  Future<void> reject(String approvalId, String superAdminId, {String? note}) async {
    final request = await approvals.findPending().then((list) => list.firstWhere((r) => r.id == approvalId));
    final updated = request.copyWith(
      status: ApprovalStatus.rejected,
      reviewedBy: superAdminId,
      reviewedAt: DateTime.now(),
      reviewNote: note,
    );

    await approvals.save(updated);

    await auditLogs.save(AuditLog.create(
      userId: superAdminId,
      userName: superAdminId,
      userRole: UserRole.superAdmin,
      action: AuditAction.update,
      entityType: 'Approval',
      entityId: approvalId,
      entityName: 'Rejected',
      changes: {'status': 'rejected', 'note': note},
    ));
  }
}
