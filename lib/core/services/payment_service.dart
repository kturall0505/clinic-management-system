import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/models.dart';
import '../repositories/repositories.dart';

enum PaymentGateway { none, stripe, paytr, local }

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

  Future<Map<String, dynamic>?> processCardPayment({
    required double amount,
    required String currency,
    required String appointmentId,
    required String patientId,
    required String gateway,
  }) async {
    if (gateway == 'stripe') {
      return _processStripePayment(amount, currency, appointmentId, patientId);
    } else if (gateway == 'paytr') {
      return _processPaytrPayment(amount, currency, appointmentId, patientId);
    }
    return null;
  }

  Future<Map<String, dynamic>?> _processStripePayment(
    double amount,
    String currency,
    String appointmentId,
    String patientId,
  ) async {
    if (supabaseUrl.isEmpty) return null;
    try {
      final response = await _client
          .post(
            Uri.parse('$supabaseUrl/rest/v1/rpc/stripe_payment_intent'),
            headers: {
              'Content-Type': 'application/json',
              'apikey': supabaseAnonKey,
              'Authorization': 'Bearer $supabaseAnonKey',
            },
            body: jsonEncode({
              'amount': (amount * 100).toInt(),
              'currency': currency.toLowerCase(),
              'appointment_id': appointmentId,
              'patient_id': patientId,
            }),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> _processPaytrPayment(
    double amount,
    String currency,
    String appointmentId,
    String patientId,
  ) async {
    if (supabaseUrl.isEmpty) return null;
    try {
      final response = await _client
          .post(
            Uri.parse('$supabaseUrl/rest/v1/rpc/paytr_payment'),
            headers: {
              'Content-Type': 'application/json',
              'apikey': supabaseAnonKey,
              'Authorization': 'Bearer $supabaseAnonKey',
            },
            body: jsonEncode({
              'amount': amount,
              'currency': currency,
              'appointment_id': appointmentId,
              'patient_id': patientId,
            }),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  Future<bool> refundPayment(String paymentId, {double? amount}) async {
    if (supabaseUrl.isEmpty) return false;
    try {
      final response = await _client
          .post(
            Uri.parse('$supabaseUrl/rest/v1/rpc/refund_payment'),
            headers: {
              'Content-Type': 'application/json',
              'apikey': supabaseAnonKey,
              'Authorization': 'Bearer $supabaseAnonKey',
            },
            body: jsonEncode({
              'payment_id': paymentId,
              'amount': amount,
            }),
          )
          .timeout(const Duration(seconds: 30));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
