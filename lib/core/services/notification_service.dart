import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../exceptions/app_exception.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

class NotificationService {
  static const String _prefsTokenKey = 'fcm_token';
  static const String _channelId = 'clinic_appointments';
  static const String _channelName = 'Randevu xatırlatmaları';
  static const String _channelDescription = 'Klinika randevu xatırlatmaları';

  NotificationService({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    http.Client? client,
  })  : _client = client ?? http.Client(),
        _localNotifications = FlutterLocalNotificationsPlugin();

  final String supabaseUrl;
  final String supabaseAnonKey;
  final http.Client _client;
  final FlutterLocalNotificationsPlugin _localNotifications;

  Future<void> initialize() async {
    if (kIsWeb) return;

    try {
      await _localNotifications.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );

      await _requestPermissions();
      await _saveFcmToken();
    } on Exception catch (e) {
      debugPrint('Notification initialization failed: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> _saveFcmToken() async {
    if (supabaseUrl.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_prefsTokenKey) ?? 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_prefsTokenKey, token);

      await _client.post(
        Uri.parse('$supabaseUrl/rest/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
          'Prefer': 'return=minimal',
        },
        body: jsonEncode({
          'recipient_id': 'system',
          'type': 'general',
          'title': 'FCM Token',
          'message': token,
          'channel': 'fcm',
        }),
      ).timeout(const Duration(seconds: 10));
    } on Exception catch (_) {}
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

    try {
      await _localNotifications.show(
        appointmentTime.millisecondsSinceEpoch ~/ 1000,
        'Randevu xatırlatması',
        message,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } on Exception catch (e) {
      debugPrint('Local notification failed: $e');
    }
  }

  Future<void> scheduleReminder({
    required String appointmentId,
    required DateTime appointmentTime,
  }) async {
    if (supabaseUrl.isEmpty) return;
    try {
      final reminderTime = appointmentTime.subtract(const Duration(hours: 1));
      if (reminderTime.isBefore(DateTime.now())) return;

      await _localNotifications.zonedSchedule(
        appointmentId.hashCode,
        'Randevu xatırlatması',
        'Randevunuza 1 saat qaldı',
        tz.TZDateTime.from(reminderTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

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
    try {
      await _localNotifications.cancel(appointmentId.hashCode);
    } on Exception catch (_) {}

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
