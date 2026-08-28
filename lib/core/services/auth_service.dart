import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../exceptions/app_exception.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import 'password_hasher.dart';

class AuthService extends ChangeNotifier {
  static const int _minPasswordLength = 8;
  static const int _maxLoginAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 5);

  AuthService(this._users, {AuditLogRepository? auditLogs})
      : _auditLogs = auditLogs;

  final UserRepository _users;
  final AuditLogRepository? _auditLogs;
  AppUser? _currentUser;
  int _failedAttempts = 0;
  DateTime? _lockedUntil;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLockedOut => _lockedUntil != null && DateTime.now().isBefore(_lockedUntil!);
  String? get currentClinicId => _currentUser?.clinicId;
  bool get isSuperAdmin => _currentUser?.role == UserRole.superAdmin || _currentUser?.role == UserRole.moderator || _currentUser?.role == UserRole.auditor;
  bool get isClinicAdmin => _currentUser?.role == UserRole.clinicAdmin;
  bool get requiresPasswordChange => _currentUser?.requiresPasswordChange ?? false;

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  static String generateSalt() => _generateSalt();

  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt:$password');
    return sha256.convert(bytes).toString();
  }

  static bool verifyPassword(String password, String salt, String hash) {
    final bytes = utf8.encode('$salt:$password');
    final expected = sha256.convert(bytes).toString();
    return expected == hash;
  }

  static bool isPasswordStrong(String password) {
    if (password.length < _minPasswordLength) return false;
    var hasLetter = false;
    var hasDigit = false;
    var hasSpecial = false;
    for (final char in password.runes) {
      if (char >= 48 && char <= 57) hasDigit = true;
      if ((char >= 65 && char <= 90) || (char >= 97 && char <= 122)) hasLetter = true;
      if ((char >= 33 && char <= 47) || (char >= 58 && char <= 64) || (char >= 91 && char <= 96) || (char >= 123 && char <= 126)) hasSpecial = true;
    }
    return hasLetter && hasDigit && hasSpecial;
  }

  Future<void> ensureSeedAdmin() async {
    try {
      final existing = await _users.all();
      if (existing.isEmpty) {
        final random = Random.secure();
        final tempPassword = List<int>.generate(12, (_) => random.nextInt(36)).map((i) => 'abcdefghijklmnopqrstuvwxyz0123456789'[i]).join();
        await register(
          username: 'admin',
          password: tempPassword,
          role: UserRole.superAdmin,
          fullName: 'Super Admin',
          requiresPasswordChange: true,
        );
        debugPrint('SEED ADMIN CREATED - Username: admin, Temporary Password: $tempPassword');
        debugPrint('IMPORTANT: Save this password securely. User must change it on first login.');
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
    String? clinicId,
    bool isActive = true,
    String? ipAddress,
    bool requiresPasswordChange = false,
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
        'Şifrə ən az 8 simvol olmalıdır, hərf, rəqəm və xüsusi simvollardan ibarət olmalıdır',
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
    final passwordHash = PasswordHasher.hash(password);
    
    final user = AppUser.create(
      username: trimmedUsername,
      passwordHash: passwordHash,
      salt: salt,
      role: role,
      fullName: trimmedFullName,
      clinicId: clinicId,
      isActive: isActive,
      ipAddress: ipAddress,
      requiresPasswordChange: requiresPasswordChange,
    );

    try {
      await _users.save(user);
      await _logAudit(
        userId: user.id,
        userName: user.fullName,
        userRole: user.role,
        action: AuditAction.create,
        entityType: 'User',
        entityId: user.id,
        entityName: user.username,
      );
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

      bool isValid;
      if (user.passwordHash.startsWith('pbkdf2_sha256$')) {
        isValid = PasswordHasher.verify(password, user.passwordHash);
      } else {
        isValid = verifyPassword(password, user.salt, user.passwordHash);
      }
      
      if (!isValid) {
        _handleFailedAttempt();
        return false;
      }

      _resetFailedAttempts();
      _currentUser = user;
      notifyListeners();

      await _logAudit(
        userId: user.id,
        userName: user.fullName,
        userRole: user.role,
        action: AuditAction.login,
        entityType: 'Auth',
        entityName: 'Login',
      );

      return true;
    } on Exception catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  void logout() {
    final user = _currentUser;
    _currentUser = null;
    _resetFailedAttempts();
    notifyListeners();

    if (user != null) {
      _logAudit(
        userId: user.id,
        userName: user.fullName,
        userRole: user.role,
        action: AuditAction.logout,
        entityType: 'Auth',
        entityName: 'Logout',
      );
    }
  }

  bool hasRole(UserRole role) {
    return _currentUser?.role == role;
  }

  bool hasAnyRole(List<UserRole> roles) {
    if (_currentUser == null) return false;
    return roles.contains(_currentUser!.role);
  }

  bool hasMinimumLevel(int level) {
    if (_currentUser == null) return false;
    return _currentUser!.role.level >= level;
  }

  bool canAccessClinic(String clinicId) {
    if (_currentUser == null) return false;
    if (_currentUser!.role.level >= 100) return true;
    return _currentUser!.clinicId == clinicId;
  }

  Future<void> _logAudit({
    required String userId,
    required String userName,
    required UserRole userRole,
    required AuditAction action,
    required String entityType,
    String? entityId,
    String? entityName,
    Map<String, Object?>? changes,
  }) async {
    if (_auditLogs == null) return;
    try {
      final log = AuditLog.create(
        userId: userId,
        userName: userName,
        userRole: userRole,
        action: action,
        entityType: entityType,
        entityId: entityId,
        entityName: entityName,
        changes: changes,
      );
      await _auditLogs.save(log);
    } on Exception catch (e) {
      debugPrint('Audit log failed: $e');
    }
  }
}
