import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../exceptions/app_exception.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

class AuthService extends ChangeNotifier {
  static const int _minPasswordLength = 6;
  static const int _maxLoginAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 5);

  AuthService(this._users);

  final UserRepository _users;
  AppUser? _currentUser;
  int _failedAttempts = 0;
  DateTime? _lockedUntil;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLockedOut => _lockedUntil != null && DateTime.now().isBefore(_lockedUntil!);

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  static String hashPassword(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  static bool isPasswordStrong(String password) {
    if (password.length < _minPasswordLength) return false;
    var hasLetter = false;
    var hasDigit = false;
    for (final char in password.runes) {
      if (char >= 48 && char <= 57) hasDigit = true;
      if ((char >= 65 && char <= 90) || (char >= 97 && char <= 122)) hasLetter = true;
    }
    return hasLetter && hasDigit;
  }

  Future<void> ensureSeedAdmin() async {
    try {
      final existing = await _users.all();
      if (existing.isEmpty) {
        await register(
          username: 'admin',
          password: 'admin123',
          role: UserRole.admin,
          fullName: 'Administrator',
        );
      }
    } on Exception catch (e) {
      debugPrint('Seed admin creation failed: $e');
    }
  }

  Future<AppUser> register({
    required String username,
    required String password,
    required UserRole role,
    required String fullName,
  }) async {
    final trimmedUsername = username.trim();
    final trimmedFullName = fullName.trim();

    if (trimmedUsername.isEmpty) {
      throw const ValidationException('İstifadəçi adı boş ola bilməz');
    }
    if (trimmedFullName.isEmpty) {
      throw const ValidationException('Ad Soyad boş ola bilməz');
    }
    if (!isPasswordStrong(password)) {
      throw const ValidationException(
        'Şifrə ən az 6 simvol olmalıdır və hərf və rəqəm ehtiva etməlidir',
      );
    }
    if (password.length > 72) {
      throw const ValidationException('Şifrə çox uzundur');
    }

    final existing = await _users.findByUsername(trimmedUsername);
    if (existing != null) {
      throw const AuthException('Bu istifadəçi adı artıq mövcuddur');
    }

    final salt = _generateSalt();
    final user = AppUser.create(
      username: trimmedUsername,
      passwordHash: hashPassword(password, salt),
      salt: salt,
      role: role,
      fullName: trimmedFullName,
    );

    try {
      await _users.save(user);
      return user;
    } on Exception catch (e) {
      throw StorageException('İstifadəçi qeydiyyatı uğursuz oldu', e);
    }
  }

  Future<bool> login(String username, String password) async {
    if (isLockedOut) {
      throw AuthException(
        'Hesab müvəqqəti olaraq bloklanıb. '
        '${_lockedUntil!.difference(DateTime.now()).inMinutes} dəqiqə sonra yenidən cəhd edin',
      );
    }

    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty) {
      throw const ValidationException('İstifadəçi adı tələb olunur');
    }

    try {
      final user = await _users.findByUsername(trimmedUsername);
      if (user == null) {
        _handleFailedAttempt();
        return false;
      }

      final isValid = hashPassword(password, user.salt) == user.passwordHash;
      if (!isValid) {
        _handleFailedAttempt();
        return false;
      }

      _resetFailedAttempts();
      _currentUser = user;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  void _handleFailedAttempt() {
    _failedAttempts++;
    if (_failedAttempts >= _maxLoginAttempts) {
      _lockedUntil = DateTime.now().add(_lockoutDuration);
      _failedAttempts = 0;
    }
  }

  void _resetFailedAttempts() {
    _failedAttempts = 0;
    _lockedUntil = null;
  }

  void logout() {
    _currentUser = null;
    _resetFailedAttempts();
    notifyListeners();
  }

  bool hasRole(UserRole role) {
    return _currentUser?.role == role;
  }

  bool hasAnyRole(List<UserRole> roles) {
    if (_currentUser == null) return false;
    return roles.contains(_currentUser!.role);
  }
}
