import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../repositories/repositories.dart';

class AuthService extends ChangeNotifier {
  AuthService(this._users);

  final UserRepository _users;
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  static String hashPassword(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  Future<void> ensureSeedAdmin() async {
    if ((await _users.all()).isEmpty) {
      await register(
        username: 'admin',
        password: 'admin123',
        role: UserRole.admin,
        fullName: 'Administrator',
      );
    }
  }

  Future<AppUser> register({
    required String username,
    required String password,
    required UserRole role,
    required String fullName,
  }) async {
    if (await _users.findByUsername(username) != null) {
      throw StateError('Bu istifadəçi adı artıq mövcuddur');
    }
    final salt = _generateSalt();
    final user = AppUser(
      username: username,
      passwordHash: hashPassword(password, salt),
      salt: salt,
      role: role,
      fullName: fullName,
    );
    await _users.save(user);
    return user;
  }

  Future<bool> login(String username, String password) async {
    final user = await _users.findByUsername(username);
    if (user == null) return false;
    if (hashPassword(password, user.salt) != user.passwordHash) return false;
    _currentUser = user;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
