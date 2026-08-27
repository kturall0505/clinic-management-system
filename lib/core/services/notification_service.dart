import 'package:flutter/foundation.dart';

class NotificationService {
  static const String _prefsTokenKey = 'fcm_token';

  Future<void> initialize() async {
    if (kIsWeb) return;
  }

  Future<String?> getToken() async {
    if (kIsWeb) return null;
    return null;
  }

  Future<void> showAppointmentReminder({
    required String patientName,
    required String doctorName,
    required DateTime appointmentTime,
  }) async {
  }

  Future<void> scheduleReminder({
    required String appointmentId,
    required DateTime appointmentTime,
  }) async {
  }

  Future<void> cancelReminder(String appointmentId) async {
  }
}
