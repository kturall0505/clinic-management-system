# Təhlükəsizlik Modeli və İcazələr Sənədi

## Açıqlama
Bu sənəd klinika idarəetmə sisteminin təhlükəsizlik modelini, rol əsaslı icazələri və
mühafizə mexanizmlərini konkret olaraq təsvir edir.

---

## 1. SUPER ADMIN (Platform Admin)

### Kimdir?
- Platformun sahibi və ya texniki direktoru
- Bütün klinikaların ümumi idarəçisi
- Sistem konfiqurasiyalarını dəyişir

### Yetki dərəcəsi: 100 (ən yüksək)

### Yalnız Super Admin görür/edir:
- `PlatformSettings` ekranı
- Bütün klinikaların siyahısı
- Bütün klinika adminlərini idarəetmə
- Sistem istifadəçiləri (Super Adminlər)
- Bütün audit jurnalı (cross-clinic)
- Backup/Restore (bütün platform)
- License aktivləri
- API Key-ləri
- Webhook konfiqurasiyaları
- Sistem logları

### Super Admin əməliyyatları:
| Əməliyyat | Təsvır |
|-----------|--------|
| Klinika əlavə et | Yeni klinika qeydiyyatı |
| Klinika sil | Klinikanı və bütün məlumatlarını sil |
| Klinika admini təyin et | Klinika admini yarat/redaktə et |
| Sistem konfiqurasiyası | Email SMTP, SMS gateway, AI endpoint |
| License aktivləri | License key yarat/aktiv et |
| API Key idarəetmə | Yeni API key yarat/revoke et |

---

## 2. CLINIC ADMIN (Klinika Sahibi/Müdürü)

### Kimdir?
- Klinikanın sahibi və ya müdürü
- Öz klinikasının tam idarəçisi
- Klinika işçilərini idarə edir

### Yetki dərəcəsi: 80

### Yalnız Clinic Admin görür/edir:
- Öz klinikasının `Settings` (inteqrasiyalar)
- Öz klinikasının `Users` (işçilər)
- Öz klinikasının `Reports`
- Öz klinikasının `Backup`
- Öz klinikasının `Audit Log`

### Clinic Admin ədiyyatları:
| Əməliyyat | Təsvir |
|-----------|--------|
| İşçi əlavə et | Doctor, Receptionist, Patient əlavə et |
| İşçi redaktə et | İşçi məlumatlarını yenilə |
| İşçi sil | İşçini sistemdən sil |
| Şifrə sıfırla | İşçinin şifrəsini sıfırla |
| Rol dəyiş | İşçinin rolunu dəyiş (admin tərəfindən) |
| Klinika ayarları | Öz klinikasının konfiqurasiyası |
| Backup | Öz klinikasının backup-ını al |
| Audit | Öz klinikasının audit logları |

### Clinic Admin ədiyyatları YOXDUR:
- Digər klinikaların məlumatlarına giriş
- Sistem konfiqurasiyaları (SMTP, SMS, AI)
- License aktivləri
- API Key idarəetmə
- Digər klinikaların backup-ı

---

## 3. DOCTOR (Həkim)

### Kimdir?
- Klinikada çalışan həkim
- Xəstələrə tibbi xidmət göstərir

### Yetki dərəcəsi: 60

### Doctor görür/edir:
- Öz randevuları
- Öz reseptləri
- Öz hesabatları
- Xəstə tibbi tarixçəsi
- Bildirişlər

### Doctor ədiyyatları:
| Əməliyyat | Təsvır |
|-----------|--------|
| Randevu yarat | Yeni randevu yarat |
| Randevu redaktə et | Öz randevularını redaktə et |
| Resept yarat | Yeni resept yarat |
| Resept redaktə et | Öz reseptlərini redaktə et |
| Hesabat | Öz performans hesabatı |
| Tibbi tarixçə | Xəstənin tibbi məlumatlarını görüş |

### Doctor ədiyyatları YOXDUR:
- Pasient əlavə et/sil
- Faktura yarat
- Növbə idarəetmə
- İstifadəçilər idarəetmə
- Backup/Restore
- Audit log
- İnteqrasiyalar

---

## 4. RECEPTIONIST (Resepşn)

### Kimdir?
- Klinikada resepsiyon işçisi
- Xəstə qəbulu və admin işlərini görür

### Yetki dərəcəsi: 40

### Receptionist görür/edir:
- Pasient siyahısı
- Randevular
- Fakturalar
- Növbə
- Bildirişlər

### Receptionist ədiyyatları:
| Əməliyyat | Təsvır |
|-----------|--------|
| Pasient əlavə et | Yeni pasient qeydiyyatı |
| Pasient redaktə et | Pasient məlumatlarını yenilə |
| Randevu yarat | Yeni randevu yarat |
| Randevu redaktə et | Randevu məlumatlarını yenilə |
| Faktura yarat | Yeni faktura yarat |
| Faktura sil | Fakturanı sil |
| Növbə idarəetmə | Növbə statusunu dəyiş |
| Bildirişlər | Oxunmuş/oxunmamış bildirişlər |

### Receptionist ədiyyatları YOXDUR:
- Resept yarat/redaktə et
- Hesabatlar
- İstifadəçilər idarəetmə
- Backup/Restore
- Audit log
- İnteqrasiyalar
- Tənzimləmələr (inteqrasiyalar)

---

## 5. PATIENT (Pasient)

### Kimdir?
- Klinikaya gələn xəstə
- Yalnız öz məlumatlarına giriş hüququ var

### Yetki dərəcəsi: 20

### Patient görür/edir:
- Öz paneli ( Dashboard )
- Öz randevuları
- Öz reseptləri
- Öz fakturaları
- Öz tibbi tarixçəsi
- Bildirişlər (öz üçün)

### Patient ədiyyatları:
| Əməliyyat | Təsvır |
|-----------|--------|
| Randevu yarat | Özü üçün yeni randevu yarat |
| Resept görüntülə | Öz reseptlərini görüntülə |
| Faktura görüntülə | Öz fakturalarını görüntülə |
| Tibbi tarixçə görüntülə | Öz tibbi məlumatlarını görüntülə |

### Patient ədiyyatları YOXDUR:
- Digər pasientlərin məlumatları
- Həkim/resepşn funksiyaları
- İdarəetmə funksiyaları
- Backup/Restore
- Audit log
- İnteqrasiyalar

---

## 6. MÜHƏFİZƏ MEXANİZMLƏRİ

### 6.1. Yetki Səviyyələri (Permission Levels)

| Yetki | Səviyyə | Təsvir |
|-------|---------|--------|
| SUPER_ADMIN | 100 | Tam platform idarəetməsi |
| CLINIC_ADMIN | 80 | Klinika idarəetməsi |
| DOCTOR | 60 | Tibbi funksiyalar |
| RECEPTIONIST | 40 | Operativ funksiyalar |
| PATIENT | 20 | Məhdud giriş |

### 6.2. Mühafizə qaydaları

1. **Minimum Priy Sip**: İstifadəçilərə ən az hüquq ver
2. **Need-to-know**: Yalnız lazım olan məlumatlara giriş imkanı
3. **Audit Logging**: Bütün kritik əməliyyatlar qeyd edilir
4. **Session Timeout**: Uzun müddət fəaliyyətsizlikdən sonra avtomatik çıxış
5. **Password Policy**: Şifrə gücü tələbləri
6. **RBAC Guard**: Hər ekranda icazə yoxlaması
7. **Data Isolation**: Klinika məlumatları bir-birindən ayrılır

### 6.3. Data Isolation (Klinika Məhdudiyyəti)

```
Klinika A -> Xəstələr, Randevular, Fakturalar
Klinika B -> Xəstələr, Randevular, Fakturalar
```

- Hər klinika öz məlumatlarını görür
- Klinikalar arası məlumat mübadiləsi YOXDUR
- Clinic Admin yalnız öz klinikasının məlumatlarına giriş edir

### 6.4. API Qoruma

- Bütün API sorğuları token ilə təsdiqlənir
- Token hər 24 saata yenilənir
- Rate limiting: 100 sorğu/dəqiqə
- IP whitelist (Super Admin üçün)

---

## 7. KOD NÜMUNƏSİ

### 7.1. RBAC Guard

```dart
class RbacGuard extends StatelessWidget {
  final int requiredLevel;
  final String? requiredRole;
  final Widget child;
  final Widget? fallback;

  const RbacGuard({
    required this.requiredLevel,
    this.requiredRole,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    
    if (user == null) return fallback ?? _buildAccessDenied();
    
    final hasLevel = _getRoleLevel(user.role) >= requiredLevel;
    final hasRole = requiredRole == null || user.role.name == requiredRole;
    
    if (!hasLevel || !hasRole) return fallback ?? _buildAccessDenied();
    
    return child;
  }
}
```

### 7.2. Yetki Səviyyəsi Funksiyası

```dart
int _getRoleLevel(UserRole role) {
  switch (role) {
    case UserRole.superAdmin: return 100;
    case UserRole.clinicAdmin: return 80;
    case UserRole.doctor: return 60;
    case UserRole.receptionist: return 40;
    case UserRole.patient: return 20;
  }
}
```

### 7.3. Ekran Qoruma

```dart
class PatientsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RbacGuard(
      requiredLevel: 40,
      child: _PatientsScreenContent(),
      fallback: const AccessDeniedScreen(),
    );
  }
}
```

---

## 8. TƏHLÜKƏSİZLİK TƏKLİFLƏRİ

### Yüksək prioritet:
1. **Super Admin/Clinic Admin ayrımı** — UserRole enum-u genişlət
2. **Data Isolation** — Hər klinika öz məlumatlarını görür
3. **API Token** — JWT və ya session token
4. **Rate Limiting** — API sorğu limiti
5. **Password Policy** — Şifrə gücü tələbləri

### Orta prioritet:
6. **Two-Factor Authentication** — 2FA
7. **Session Management** — Aktiv sessionları görüntülə/bağla
8. **Login History** — Giriş tarixçəsi
9. **IP Whitelist** — Super Admin üçün IP məhdudiyyəti

### Aşağı prioritet:
10. **Biometric Login** — Parmak izi/üzlük tanıma
11. **Single Sign-On** — SSO
12. **LDAP/Active Directory** — Korporativ inteqrasiya

---

## 9. TƏHLÜKƏSİZLİK TƏSDİQLİMƏSİ

| Təsvər | Təhlükəsizlik | Tətbiq |
|--------|--------------|--------|
| Input Validation | ✅ | Bütün formlar |
| SQL Injection Protection | ✅ | Sembast ORM |
| XSS Protection | ✅ | Flutter built-in |
| CSRF Protection | ⚠️ | Tətbiq edilməyib |
| Rate Limiting | ⚠️ | Tətbiq edilməyib |
| HTTPS Only | ⚠️ | Production-da tətbiq et |
| Token Refresh | ⚠️ | Tətbiq edilməyib |

---

## 10. DƏYİŞİKLİK TARİXİ

- Tarix: 2026-08-28
- Versiya: 1.0
- Müəllif: Kilo AI
