/// Input validation helpers for clinic management forms.
///
/// Returns a human-readable error string or `null` when the value is valid.
class Validators {
  Validators._();

  /// Validates a full name (2-100 chars, letters, spaces, dots, hyphens).
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ad Soyad daxil edin';
    if (value.trim().length < 2) return 'Ad Soyad ən azı 2 simvol olmalıdır';
    if (value.trim().length > 100) return 'Ad Soyad çox uzundur';
    if (!RegExp(r"^[A-Za-zAzərbaycanƏəİiÖöÜüÇçŞşĞğıIı\s\.\-']+$")
        .hasMatch(value.trim())) {
      return 'Yalnız hərf və boşluq istifadə edin';
    }
    return null;
  }

  /// Validates a phone number: +994 followed by 9 digits (Azerbaijan).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Telefon daxil edin';
    final cleaned = value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^\+?\d{7,15}$').hasMatch(cleaned)) {
      return 'Düzgün telefon nömrəsi daxil edin (məs. +994501112233)';
    }
    return null;
  }

  /// Validates a username: 3-30 alphanumeric chars, underscore, dot.
  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) return 'İstifadəçi adı daxil edin';
    if (value.trim().length < 3) return 'İstifadəçi adı ən azı 3 simvol';
    if (value.trim().length > 30) return 'İstifadəçi adı çox uzundur';
    if (!RegExp(r'^[a-zA-Z0-9_\.]+$').hasMatch(value.trim())) {
      return 'Yalnız hərf, rəqəm, _ və . istifadə edin';
    }
    return null;
  }

  /// Validates a password: minimum 6 chars.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Şifrə daxil edin';
    if (value.length < 6) return 'Şifrə ən azı 6 simvol olmalıdır';
    if (value.length > 128) return 'Şifrə çox uzundur';
    return null;
  }

  /// Validates consultation fee: non-negative number.
  static String? consultationFee(String? value) {
    if (value == null || value.trim().isEmpty) return 'Konsultasiya haqqı daxil edin';
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < 0) return 'Düzgün məbləğ daxil edin';
    return null;
  }

  /// Validates specialty: 2-100 chars.
  static String? specialty(String? value) {
    if (value == null || value.trim().isEmpty) return 'İxtisas daxil edin';
    if (value.trim().length < 2) return 'İxtisas ən azı 2 simvol olmalıdır';
    return null;
  }
}
