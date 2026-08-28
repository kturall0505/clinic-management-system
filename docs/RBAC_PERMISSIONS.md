# Rol Əsaslı Giriş Nəzarəti (RBAC)

## Açıqlama
Bu sənəd klinika idarəetmə sistemindəki rol əsaslı giriş nəzarətini (RBAC) təsvir edir.
Hər bir rolun hansı funksiyalara giriş hüququ olduğunu və hansı əməliyyatları yerinə yetirə biləcəyini müəyyən edir.

---

## Rollar

### 1. Admin (Administrator)
**Tam giriş hüququ var**

| Bölmə | Giriş | Əməliyyatlar |
|-------|-------|--------------|
| Panel | ✅ | Baxış |
| Həkimlər | ✅ | Yarat, Redaktə, Sil, Bax |
| Pasientlər | ✅ | Yarat, Redaktə, Sil, Bax |
| Randevular | ✅ | Yarat, Redaktə, Sil, Bax, Status dəyiş |
| Resept | ✅ | Yarat, Redaktə, Sil, Bax |
| Faktura | ✅ | Yarat, Redaktə, Sil, Bax, Ödəniş |
| Hesabat | ✅ | Generasiya, Eksport |
| Assistent | ✅ | Sual ver, Cavab al |
| İstifadəçilər | ✅ | Yarat, Sil, Şifrə sıfırla |
| Audit Jurnalı | ✅ | Bax, Filter |
| Növbə | ✅ | İdarə et, Status dəyiş |
| Fayl Yükləmə | ✅ | Yüklə, Sil |
| Backup | ✅ | Yarat, Bərpa et |
| Bildirişlər | ✅ | Bax, Oxunmuş işarələ |
| Tənzimləmələr | ✅ | Bütün ayarlar, İnteqrasiyalar |
| Tibbi Tarixçə | ✅ | Bax, Redaktə |

### 2. Həkim (Doctor)
**Müəyyənli giriş hüququ var**

| Bölmə | Giriş | Əməliyyatlar |
|-------|-------|--------------|
| Panel | ✅ | Baxış |
| Həkimlər | ❌ | - |
| Pasientlər | ❌ | - |
| Randevular | ✅ | Bax, Redaktə (özü üçün), Status dəyiş |
| Resept | ✅ | Yarat, Redaktə, Sil, Bax |
| Faktura | ❌ | - |
| Hesabat | ✅ | Generasiya, Eksport |
| Assistent | ✅ | Sual ver, Cavab al |
| İstifadəçilər | ❌ | - |
| Audit Jurnalı | ❌ | - |
| Növbə | ❌ | - |
| Fayl Yükləmə | ✅ | Yüklə |
| Backup | ❌ | - |
| Bildirişlər | ✅ | Bax |
| Tənzimləmələr | ⚠️ | Yalnız şifrə dəyişmə |
| Tibbi Tarixçə | ✅ | Bax, Redaktə |

### 3. Resepşn (Receptionist)
**Operativ giriş hüququ var**

| Bölmə | Giriş | Əməliyyatlar |
|-------|-------|--------------|
| Panel | ✅ | Baxış |
| Həkimlər | ❌ | - |
| Pasientlər | ✅ | Yarat, Redaktə, Sil, Bax |
| Randevular | ✅ | Yarat, Redaktə, Sil, Bax, Status dəyiş |
| Resept | ❌ | - |
| Faktura | ✅ | Yarat, Sil, Bax, Ödəniş qeyd et |
| Hesabat | ❌ | - |
| Assistent | ✅ | Sual ver, Cavab al |
| İstifadəçilər | ❌ | - |
| Audit Jurnalı | ❌ | - |
| Növbə | ✅ | İdarə et, Status dəyiş |
| Fayl Yükləmə | ✅ | Yüklə |
| Backup | ❌ | - |
| Bildirişlər | ✅ | Bax, Oxunmuş işarələ |
| Tənzimləmələr | ⚠️ | Yalnız bildiriş ayarları |
| Tibbi Tarixçə | ❌ | - |

### 4. Pasient (Patient)
**Məhdud giriş hüququ var**

| Bölmə | Giriş | Əməliyyatlar |
|-------|-------|--------------|
| Panel | ✅ | Baxış (öz məlumatları) |
| Həkimlər | ❌ | - |
| Pasientlər | ❌ | - |
| Randevular | ✅ | Bax, Yarat (özü üçün) |
| Resept | ✅ | Bax (özü üçün) |
| Faktura | ✅ | Bax (özü üçün) |
| Hesabat | ❌ | - |
| Assistent | ✅ | Sual ver, Cavab al |
| İstifadəçilər | ❌ | - |
| Audit Jurnalı | ❌ | - |
| Növbə | ❌ | - |
| Fayl Yükləmə | ❌ | - |
| Backup | ❌ | - |
| Bildirişlər | ✅ | Bax (özü üçün) |
| Tənzimləmələr | ⚠️ | Yalnız şifrə dəyişmə |
| Tibbi Tarixçə | ✅ | Bax (özü üçün) |

---

## Implementasiya

### Kod Nümunəsi
```dart
class _PatientsScreenState extends State<PatientsScreen> {
  bool get _canCreate => context.read<AuthService>().hasAnyRole([UserRole.admin, UserRole.receptionist]);
  bool get _canEdit => context.read<AuthService>().hasAnyRole([UserRole.admin]);
  bool get _canDelete => context.read<AuthService>().hasAnyRole([UserRole.admin]);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_canCreate) _buildAddButton(),
        Expanded(child: _buildPatientList()),
      ],
    );
  }
}
```

### RBAC Guard Widget
```dart
RbacGuard(
  allowedRoles: [UserRole.admin],
  child: AdminOnlyWidget(),
  fallback: AccessDeniedWidget(),
)
```

---

## Təhlükəsizlik Qaydaları

1. **Minimum Priy sipi**: İstifadəçilərə ən az hüquq ver
2. **Need-to-know**: Yalnız lazım olan məlumatlara giriş imkanı
3. **Audit logging**: Bütün kritik əməliyyatlar qeyd edilir
4. **Session timeout**: Uzun müddət fəaliyyətsizlikdən sonra avtomatik çıxış
5. **Password policy**: Şifrə gücü tələbləri (ən az 6 simvol, hərf və rəqəm)

---

## Dəyişiklik Tarix
- Tarix: 2026-08-28
- Versiya: 1.0
- Müəllif: Kilo AI
