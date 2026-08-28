import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/models.dart';
import '../repositories/repositories.dart';

class PaymentService {
  PaymentService({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.paymentRepo,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String supabaseUrl;
  final String supabaseAnonKey;
  final PaymentRepository? paymentRepo;
  final http.Client _client;

  Future<Map<String, dynamic>?> createPaymentIntent({
    required double amount,
    required String currency,
    required String appointmentId,
  }) async {
    if (supabaseUrl.isEmpty) return null;
    try {
      final response = await _client
          .post(
            Uri.parse('$supabaseUrl/rest/v1/rpc/create_payment_intent'),
            headers: {
              'Content-Type': 'application/json',
              'apikey': supabaseAnonKey,
              'Authorization': 'Bearer $supabaseAnonKey',
            },
            body: jsonEncode({
              'amount': amount,
              'currency': currency,
              'appointment_id': appointmentId,
            }),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  Future<bool> processCashPayment({
    required String appointmentId,
    required double amount,
    required String patientId,
  }) async {
    if (amount <= 0) return false;
    if (paymentRepo == null) return true;

    try {
      final payment = Payment.create(
        appointmentId: appointmentId,
        patientId: patientId,
        amount: amount,
        method: 'cash',
        status: 'completed',
      );
      await paymentRepo!.save(payment);
      return true;
    } on Exception catch (_) {
      return false;
    }
  }
}
