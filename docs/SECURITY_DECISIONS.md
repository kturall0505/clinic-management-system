# Sistem Təhlükəsizliyi və Arxitektura Qərarları

## Tarix: 2026-08-28
## Versiya: 1.0
## Müəllif: Kilo AI

---

## 1. SUPER ADMIN MODELİ

### 1.1. Super Admin tipləri
- **Super Admin** (Level 100) — Tam platform idarəetməsi, bütün klinikaları görür
- **Moderator** (Level 90) — Super Admin tərəfindən təyin edilir, limitli səlahiyyətlər
- **Auditor** (Level 85) — Yalnız audit logları və hesabatları görür, dəyişiklik edə bilməz

### 1.2. Super Admin sayı: 2-3 nəfər
- Minimum: 1 Super Admin
- Maksimum: 3 nəfər (Super Admin + Moderator + Auditor)
- Yeni Super Admin əlavə etmək yalnız mövcud Super Admin tərəfindən mümkün

### 1.3. Super Admin məsuliyyətləri:
| Rol | Məsuliyyət |
|-----|-----------|
| Super Admin | Bütün platform idarəetməsi, kritik qərarlar |
| Moderator | İstifadəçiləri müdaxilə, şikayətləri baxmaq |
| Auditor | Audit logları, hesabatlar, yoxlamalar |

---

## 2. DOMAIN/SUBDOMAIN ARXİTEKTURU

### 2.1. Ayrı domainlər:
```
Super Admin: https://admin.clinique.com ( və ya superadmin.clinique.com )
Klinika App: https://app.clinique.com ( və ya klinika adı ilə subdomain )
```

### 2.2. Domain təsnifatı:
- `admin.clinique.com` — Super Admin paneli
- `app.clinique.com` — Klinika tətbiqi
- `clinic1.clinique.com` — Klinika 1 öz paneli (opsional)
- `clinic2.clinique.com` — Klinika 2 öz paneli (opsional)

### 2.3. Faydaları:
- Təhlükəsizlik: Super Admin paneli ayrı, daha mühafizəli
- Performance: Ayrı server/subdomain üzərində yüklənmə
- Branding: Hər klinika öz subdomain-i ilə işləyə bilər

---

## 3. KLINİKA QEYDİYYATI və ABUNƏ

### 3.1. Qeydiyyat prosesi:
```
1. Klinika özünü qeydiyyatdan keçir
   ↓
2. Super Admin təsdiq edir
   ↓
3. Klinika aktiv olur, abunə başlayır
   ↓
4. Klinika Admini öz işçilərini əlavə edir
```

### 3.2. Abunə modelləri:
| Plan | Qiymət | Məhdudiyyət |
|------|--------|-------------|
| Free | 0 AZN | 5 həkim, 50 pasient |
| Pro | 99 AZN/ay | Limitsiz həkim, limitsiz pasient |
| Enterprise | 299 AZN/ay | Bütün funksiyalar, priority support |

### 3.3. Abunə statusları:
- `pending` — Qeydiyyatdan keçib, təsdiq gözləyir
- `active` — Aktiv abunə
- `expired` — Abunə müddəti bitib
- `suspended` — Super Admin tərəfindən dayandırılıb

---

## 4. CLİNİK ADMİN MƏSÜLİYYƏTLƏRİ

### 4.1. Yalnız öz klinikasını idarə edir:
- Öz klinikasının istifadəçiləri
- Öz klinikasının ayarları
- Öz klinikasının backup-ı
- Öz klinikasının audit logları

### 4.2. Dəyişikliklər Super Admin təsdiqi tələb edir:
| Dəyişiklik | Təsdiq tələb edir |
|------------|-------------------|
| Klinika adı dəyişmə | ✅ |
| Klinika adresi dəyişmə | ✅ |
| Abunə planı dəyişmə | ✅ |
| Yeni həkim əlavə etmə | ❌ |
| Şifrə sıfırlama | ❌ |
| Öz profilini dəyişmə | ❌ |

### 4.3. Clinic Admin icazələri:
- ✅ Öz klinikasının istifadəçilərini idarə et
- ✅ Öz klinikasının ayarlarını dəyiş (təsdiq gözləyir)
- ✅ Öz klinikasının backup-ını al
- ✅ Öz klinikasının audit loglarını gör
- ❌ Digər klinikaların məlumatlarına giriş YOXDUR
- ❌ Sistem konfiqurasiyalarını dəyiş YOXDUR

---

## 5. SUPER ADMİN GÖRÜNÜŞLƏRİ

### 5.1. Super Admin paneli:
- **Dashboard**: Bütün klinikaların statistikası
- **Klinikalar**: Bütün klinikaların siyahısı, statusları
- **İstifadəçilər**: Bütün istifadəçilər (Super Admin, Clinic Admin, Doctor, və s.)
- **Abunələr**: Bütün abunələr, ödəmələr
- **Sistem Ayarları**: Email SMTP, SMS gateway, AI endpoint
- **License Aktivləri**: License key yarat, aktiv et
- **API Keys**: API açarı idarəetməsi
- **Audit Log**: Bütün platform audit logları
- **Backup**: Bütün platform backup-ı

### 5.2. Super Admin görür:
- Bütün klinikaların bütün məlumatları
- Bütün istifadəçilərin şifrə hash-ləri (plain text YOXDUR)
- Bütün ödəmələr və fakturalar
- Bütün randevular və reseptlər
- Bütün audit qeydləri

---

## 6. ROL SƏVİYYƏLƏRİ (5 SƏVİYYƏ)

| Rol | Level | Təsvir |
|-----|-------|--------|
| SUPER_ADMIN | 100 | Platform admini |
| MODERATOR | 90 | Super Admin tərəfindən təyin edilir, limitli səlahiyyətlər |
| AUDITOR | 85 | Yalnız oxumaq, dəyişiklik edə bilməz |
| CLINIC_ADMIN | 80 | Klinika sahibi/müdürü |
| DOCTOR | 60 | Həkim |
| RECEPTIONIST | 40 | Resepşn |
| PATIENT | 20 | Xəstə |

### 6.1. Rol dəyişmə qaydaları:
- Super Admin → Clinic Admin təyin edə bilər
- Clinic Admin → Doctor/Receptionist/Patient əlavə edə bilər
- Doctor/Receptionist/Patient → rol dəyişə BİLMƏZ
- Super Admin → Moderator/Auditor təyin edə bilər

---

## 7. TƏHLÜKƏSİZLİK MEXANİZMLƏRİ

### 7.1. 2FA (Two-Factor Authentication)
- Bütün Super Admin və Clinic Admin üçün MƏCburi
- Google Authenticator və ya SMS ilə
- Əgər 2FA deaktiv edilsə, Super Admin tərəfindən təsdiq tələb edir

### 7.2. IP Whitelist
- Yalnız Super Admin üçün
- Müəyyən edilmiş IP-lərdən giriş mümkün
- Yeni IP əlavə etmək yalnız mövcud Super Admin tərəfindən mümkün

### 7.3. Session Management
- Maksimum 5 aktiv session (Super Admin üçün 3)
- Uzun müddət fəaliyyətsizlikdən sonra avtomatik çıxış (30 dəqiqə)
- Aktiv sessionları görüntüləyə və bağlaya bilər

### 7.4. Audit Logging
- Bütün kritik əməliyyatlar qeyd edilir:
  - Giriş/çıxış
  - Dəyişiklik edən şəxs
  - Dəyişiklik vaxtı
  - Dəyişiklik məzmunu
  - IP ünvanı
- Super Admin panelində bütün loglar görünür
- Clinic Admin yalnız öz klinikasının loglarını görür

### 7.5. Kritik dəyişikliklər təsdiq mexanizmi:
```
1. Clinic Admin dəyişiklik təklif edir
   ↓
2. Sistem "Pending Approval" statusuna qoyur
   ↓
3. Super Admin təsdiq edir və ya rədd edir
   ↓
4. Təsdiq edilərsə, dəyişiklik icra olunur
```

---

## 8. DATA ISOLATION (Klinika Məhdudiyyəti)

### 8.1. Məhdudiyyət qaydaları:
- Hər klinika yalnız öz məlumatlarını görür
- Klinikalar arası məlumat mübadiləsi YOXDUR
- Clinic Admin yalnız öz klinikasının məlumatlarına giriş edir
- Super Admin bütün klinikaların məlumatlarını görür

### 8.2. Məhdudiyyət mexanizmi:
- Hər sorğu `clinicId` ilə təsdiqlənir
- Repository-də məhdudiyyət filteri tətbiq edilir
- Super Admin istisna olaraq bütün məlumatları görür

---

## 9. KOD TƏKLİFLƏRİ

### 9.1. Yeni UserRole enum:
```dart
enum UserRole {
  superAdmin,    // Level 100
  moderator,     // Level 90
  auditor,       // Level 85
  clinicAdmin,   // Level 80
  doctor,        // Level 60
  receptionist,  // Level 40
  patient,       // Level 20
}
```

### 9.2. User modelinə əlavə:
```dart
class User {
  final String id;
  final String username;
  final String fullName;
  final UserRole role;
  final String? clinicId; // Super Admin üçün null
  final bool isActive;
  final DateTime? lastLogin;
  final String? ipAddress;
}
```

### 9.3. Clinic modeli:
```dart
class Clinic {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final SubscriptionStatus status;
  final SubscriptionPlan plan;
  final DateTime? trialEndsAt;
  final DateTime? subscriptionEndsAt;
  final String? approvedBy; // Super Admin ID
  final DateTime? approvedAt;
}
```

---

## 10. TƏHDİDLƏR və HƏLLƏR

| Təhlükə | Həll |
|---------|------|
| Super Admin məlumatlarını əldə edir | IP Whitelist + 2FA |
| Klinika məlumatlarını korlayır | Data Isolation + Encryption |
| Dəyişikliklər təsdiqsiz icra olunur | Approval Workflow |
| Yetkisiz giriş | RBAC + Session Timeout |
| API abuse | Rate Limiting + API Key |

---

## 11. DƏYİŞİKLİK TARİXİ

- 2026-08-28: İlk versiya yaradıldı
- Müəllif: Kilo AI
- Status: Təsdiq gözləyir

---

## 12. TƏSDİQ

Bu sənəd təsdiq edildikdən sonra implementasiyaya başlanılacaq.

Təsdiq edən: _______________
Tarix: _______________
