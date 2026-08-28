import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../exceptions/app_exception.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

class NotificationService {
  static const String _prefsTokenKey = 'fcm_token';

  NotificationService({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String supabaseUrl;
  final String supabaseAnonKey;
  final http.Client _client;

  Future<void> initialize() async {
    if (kIsWeb) return;
  }

  Future<String?> getToken() async {
    if (kIsWeb) return null;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsTokenKey);
  }

  Future<void> showAppointmentReminder({
    required String patientName,
    required String doctorName,
    required DateTime appointmentTime,
  }) async {
    final message = 'Xatırlatma: ${DateFormat('dd.MM.yyyy HH:mm').format(appointmentTime)} '
        'tarixində ${doctorName} ilə randevunuz var.';
    debugPrint('Notification: $message');
  }

  Future<void> scheduleReminder({
    required String appointmentId,
    required DateTime appointmentTime,
  }) async {
    if (supabaseUrl.isEmpty) return;
    try {
      final reminderTime = appointmentTime.subtract(const Duration(hours: 1));
      if (reminderTime.isBefore(DateTime.now())) return;

      await _client
          .post(
            Uri.parse('$supabaseUrl/rest/v1/rpc/schedule_notification'),
            headers: {
              'Content-Type': 'application/json',
              'apikey': supabaseAnonKey,
              'Authorization': 'Bearer $supabaseAnonKey',
            },
            body: jsonEncode({
              'appointment_id': appointmentId,
              'scheduled_at': reminderTime.toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 15));
    } on Exception catch (_) {}
  }

  Future<void> cancelReminder(String appointmentId) async {
    if (supabaseUrl.isEmpty) return;
    try {
      await _client
          .post(
            Uri.parse('$supabaseUrl/rest/v1/rpc/cancel_notification'),
            headers: {
              'Content-Type': 'application/json',
              'apikey': supabaseAnonKey,
              'Authorization': 'Bearer $supabaseAnonKey',
            },
            body: jsonEncode({'appointment_id': appointmentId}),
          )
          .timeout(const Duration(seconds: 15));
    } on Exception catch (_) {}
  }

  Future<void> sendNotification(AppNotification notification) async {
    if (supabaseUrl.isEmpty) return;
    try {
      await _client
          .post(
            Uri.parse('$supabaseUrl/rest/v1/notifications'),
            headers: {
              'Content-Type': 'application/json',
              'apikey': supabaseAnonKey,
              'Authorization': 'Bearer $supabaseAnonKey',
              'Prefer': 'return=minimal',
            },
            body: jsonEncode(notification.toMap()),
          )
          .timeout(const Duration(seconds: 15));
    } on Exception catch (_) {}
  }
}
