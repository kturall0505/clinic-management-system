import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../exceptions/app_exception.dart';
import '../../models/models.dart';
import '../repositories/repositories.dart';

class ReportService {
  ReportService({
    required this.tenantId,
    required this.patientsRepo,
    required this.doctorsRepo,
    required this.appointmentsRepo,
    required this.paymentsRepo,
    required this.invoicesRepo,
    required this.visitsRepo,
  });

  final String tenantId;
  final PatientRepository patientsRepo;
  final DoctorRepository doctorsRepo;
  final AppointmentRepository appointmentsRepo;
  final PaymentRepository paymentsRepo;
  final InvoiceRepository invoicesRepo;
  final MedicalVisitRepository visitsRepo;

  Future<Report> generateDailyReport(DateTime date, String generatedBy) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return generateCustomReport(start, end, ReportType.daily, generatedBy);
  }

  Future<Report> generateWeeklyReport(DateTime weekStart, String generatedBy) async {
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = start.add(const Duration(days: 7));

    return generateCustomReport(start, end, ReportType.weekly, generatedBy);
  }

  Future<Report> generateMonthlyReport(int year, int month, String generatedBy) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);

    return generateCustomReport(start, end, ReportType.monthly, generatedBy);
  }

  Future<Report> generateCustomReport(DateTime start, DateTime end, ReportType type, String generatedBy) async {
    try {
      final patients = await patientsRepo.all();
      final doctors = await doctorsRepo.all();
      final appointments = await appointmentsRepo.all();
      final payments = await paymentsRepo.all();
      final invoices = await invoicesRepo.all();
      final visits = await visitsRepo.all();

      final filteredAppointments = appointments.where((a) {
        return a.dateTime.isAfter(start) && a.dateTime.isBefore(end);
      }).toList();

      final filteredPayments = payments.where((p) {
        return p.createdAt.isAfter(start) && p.createdAt.isBefore(end);
      }).toList();

      final filteredInvoices = invoices.where((i) {
        return i.createdAt.isAfter(start) && i.createdAt.isBefore(end);
      }).toList();

      final filteredVisits = visits.where((v) {
        return v.visitDate.isAfter(start) && v.visitDate.isBefore(end);
      }).toList();

      final totalRevenue = filteredPayments
          .where((p) => p.status == 'completed')
          .fold<double>(0, (sum, p) => sum + p.amount);

      final pendingInvoices = filteredInvoices.where((i) => i.status == 'pending').length;
      final paidInvoices = filteredInvoices.where((i) => i.status == 'paid').length;

      final doctorStats = <String, Map<String, dynamic>>{};
      for (final doctor in doctors) {
        final doctorAppointments = filteredAppointments.where((a) => a.doctorId == doctor.id).toList();
        final completed = doctorAppointments.where((a) => a.status == AppointmentStatus.completed).length;
        final noShow = doctorAppointments.where((a) => a.status == AppointmentStatus.noShow).length;
        doctorStats[doctor.id] = {
          'name': doctor.fullName,
          'specialty': doctor.specialty,
          'total_appointments': doctorAppointments.length,
          'completed': completed,
          'no_show': noShow,
          'completion_rate': doctorAppointments.isEmpty ? 0.0 : completed / doctorAppointments.length,
        };
      }

      final data = {
        'period': {
          'start': start.toIso8601String(),
          'end': end.toIso8601String(),
        },
        'summary': {
          'total_patients': patients.length,
          'total_doctors': doctors.length,
          'total_appointments': filteredAppointments.length,
          'scheduled_appointments': filteredAppointments.where((a) => a.status == AppointmentStatus.scheduled).length,
          'completed_appointments': filteredAppointments.where((a) => a.status == AppointmentStatus.completed).length,
          'cancelled_appointments': filteredAppointments.where((a) => a.status == AppointmentStatus.cancelled).length,
          'no_show_appointments': filteredAppointments.where((a) => a.status == AppointmentStatus.noShow).length,
          'total_visits': filteredVisits.length,
        },
        'financial': {
          'total_revenue': totalRevenue,
          'total_invoices': filteredInvoices.length,
          'paid_invoices': paidInvoices,
          'pending_invoices': pendingInvoices,
          'total_payments': filteredPayments.length,
          'average_payment': filteredPayments.isEmpty ? 0.0 : totalRevenue / filteredPayments.length,
        },
        'doctors': doctorStats,
        'generated_at': DateTime.now().toIso8601String(),
      };

      return Report.create(
        type: type,
        startDate: start,
        endDate: end,
        data: data,
        generatedBy: generatedBy,
      );
    } on Exception catch (e) {
      throw StorageException('Hesabat yaradılması uğursuz oldu: $e');
    }
  }
}
