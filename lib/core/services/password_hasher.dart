import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  static const int _iterations = 600000;
  static const int _saltLength = 16;
  static const int _keyLength = 32;

  static String hash(String password) {
    final random = Random.secure();
    final saltBytes = List<int>.generate(_saltLength, (_) => random.nextInt(256));
    final hashBytes = _pbkdf2(password, saltBytes, _iterations, _keyLength);
    final saltBase64 = base64Encode(saltBytes);
    final hashBase64 = base64Encode(hashBytes);
    return 'pbkdf2_sha256$${_iterations}$${saltBase64}$$hashBase64';
  }

  static bool verify(String password, String storedHash) {
    if (!storedHash.startsWith('pbkdf2_sha256$')) return false;
    
    final parts = storedHash.split('$');
    if (parts.length != 4) return false;
    
    final iterations = int.parse(parts[1]);
    final saltBytes = base64Decode(parts[2]);
    final expectedHash = base64Decode(parts[3]);
    
    final actualHash = _pbkdf2(password, saltBytes, iterations, expectedHash.length);
    return _constantTimeEquals(expectedHash, actualHash);
  }

  static List<int> _pbkdf2(String password, List<int> salt, int iterations, int keyLength) {
    final passwordBytes = utf8.encode(password);
    final hmac = Hmac(sha256, passwordBytes);
    
    List<int> u = hmac.convert([...salt, 0, 0]).bytes;
    List<int> t = List<int>.from(u);
    
    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < t.length && j < u.length; j++) {
        t[j] ^= u[j];
      }
    }
    
    return t.sublist(0, keyLength);
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}
