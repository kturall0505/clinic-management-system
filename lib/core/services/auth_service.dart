import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../password_hasher.dart';
import '../repositories/repositories.dart';
import '../validators.dart';

/// Authentication service with PBKDF2 password hashing and input validation.
///
/// Seamlessly migrates existing SHA-256 hashes to PBKDF2 on first login
/// after upgrade.
class AuthService extends ChangeNotifier {
  AuthService(this._users, {PasswordHasher? hasher})
      : _hasher = hasher ?? PasswordHasher();

  final UserRepository _users;
  final PasswordHasher _hasher;
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

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
    final usernameErr = Validators.username(username);
    if (usernameErr != null) throw ArgumentError(usernameErr);
    final passwordErr = Validators.password(password);
    if (passwordErr != null) throw ArgumentError(passwordErr);
    final nameErr = Validators.fullName(fullName);
    if (nameErr != null) throw ArgumentError(nameErr);

    if (await _users.findByUsername(username.trim()) != null) {
      throw StateError('Bu istifadəçi adı artıq mövcuddur');
    }
    final salt = _hasher.generateSalt();
    final passwordHash = _hasher.hash(password, salt);
    final user = AppUser(
      username: username.trim(),
      passwordHash: passwordHash,
      salt: salt,
      role: role,
      fullName: fullName.trim(),
    );
    await _users.save(user);
    return user;
  }

  Future<bool> login(String username, String password) async {
    if (username.trim().isEmpty || password.isEmpty) return false;

    final user = await _users.findByUsername(username.trim());
    if (user == null) return false;

    if (_hasher.verify(password, user.passwordHash, user.salt)) {
      _currentUser = user;
      notifyListeners();
      return true;
    }

    if (_legacySha256Check(password, user)) {
      final newSalt = _hasher.generateSalt();
      final newHash = _hasher.hash(password, newSalt);
      final migrated = AppUser(
        id: user.id,
        username: user.username,
        passwordHash: newHash,
        salt: newSalt,
        role: user.role,
        fullName: user.fullName,
      );
      await _users.save(migrated);
      _currentUser = migrated;
      notifyListeners();
      return true;
    }

    return false;
  }

  bool _legacySha256Check(String password, AppUser user) {
    final bytes = utf8.encode('${user.salt}:$password');
    return sha256.convert(bytes).toString() == user.passwordHash;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}