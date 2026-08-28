import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../models/models.dart';
import '../repositories/repositories.dart';

class TwoFactorService {
  TwoFactorService(this._twoFactors);

  final TwoFactorRepository _twoFactors;

  Future<String> generateSecret(String userId) async {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final secret = base64Url.encode(bytes);

    await _twoFactors.save(TwoFactorSecret.create(
      userId: userId,
      secretKey: secret,
    ));

    return secret;
  }

  Future<bool> verifyCode(String userId, String code) async {
    final secret = await _twoFactors.findByUserId(userId);
    if (secret == null || !secret.isEnabled) return true;

    final expected = _generateTOTP(secret.secretKey);
    return expected == code;
  }

  Future<void> enable(String userId) async {
    final secret = await _twoFactors.findByUserId(userId);
    if (secret == null) return;

    await _twoFactors.save(secret.copyWith(isEnabled: true));
  }

  Future<void> disable(String userId) async {
    final secret = await _twoFactors.findByUserId(userId);
    if (secret == null) return;

    await _twoFactors.save(secret.copyWith(isEnabled: false));
  }

  Future<bool> isEnabled(String userId) async {
    final secret = await _twoFactors.findByUserId(userId);
    return secret?.isEnabled ?? false;
  }

  String _generateTOTP(String secret) {
    final key = base64Decode(secret);
    final epoch = DateTime.now().millisecondsSinceEpoch ~/ 30000;
    final bytes = <int>[];
    while (epoch > 0) {
      bytes.add(epoch & 0xFF);
      epoch >>= 8;
    }
    final hmac = Hmac(sha1, key);
    final digest = hmac.convert(bytes.reversed.toList());
    final offset = digest.bytes[digest.bytes.length - 1] & 0x0F;
    final code = ((digest.bytes[offset] & 0x7F) << 24) |
        ((digest.bytes[offset + 1] & 0xFF) << 16) |
        ((digest.bytes[offset + 2] & 0xFF) << 8) |
        (digest.bytes[offset + 3] & 0xFF);
    return ((code % 1000000).toString().padLeft(6, '0'));
  }
}
