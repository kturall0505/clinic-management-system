# Klinika İdarəetmə Sistemi — Design & Architecture

## 1. Technology Stack Decisions

| Component | Choice | Rationale |
|-----------|--------|-----------|
| **Framework** | Flutter 3.x | Cross-platform (Web, Linux, Android, iOS), single codebase |
| **Language** | Dart 3.x | Null safety, pattern matching, records |
| **State Management** | Provider | Simple, well-documented, sufficient for this scope |
| **Database** | Sembast (local-first) | NoSQL document store, no server needed, privacy-preserving |
| **Password Hashing** | PBKDF2-HMAC-SHA256 | OWASP recommended, no additional package dependency |
| **CI/CD** | GitHub Actions | Free tier, Flutter action available |
| **UUID** | `uuid` package | Standard v4 UUIDs for all entities |

## 2. Architecture Overview

```
┌─────────────────────────────────────────────┐
│                  UI Layer                    │
│  HomeShell (RBAC NavigationRail)            │
│  ├── DashboardScreen                        │
│  ├── PatientsScreen (search, paginate)      │
│  ├── DoctorsScreen (search, filter)         │
│  ├── AppointmentsScreen (collision check)   │
│  └── AssistantScreen (AI chat)              │
├─────────────────────────────────────────────┤
│              Service Layer                  │
│  ├── AuthService (PBKDF2, validation)       │
│  ├── LicenseService (heartbeat)             │
│  └── AiService (assistant API)              │
├─────────────────────────────────────────────┤
│            Repository Layer                 │
│  ├── PatientRepository (CRUD)               │
│  ├── DoctorRepository (CRUD)                │
│  ├── AppointmentRepository (CRUD, query)    │
│  └── UserRepository (CRUD, lookup)          │
├─────────────────────────────────────────────┤
│               Data Layer                    │
│  └── Sembast (local document store)         │
└─────────────────────────────────────────────┘
```

## 3. Security Design

### Password Security (PBKDF2)
- **Algorithm**: PBKDF2-HMAC-SHA256 (RFC 2898)
- **Iterations**: 100,000 (OWASP 2023 minimum)
- **Salt**: 16 cryptographically random bytes per user
- **Output format**: `PBKDF2$iterations$saltBase64$hashBase64`
- **Timing attack protection**: Constant-time comparison
- **Migration path**: Legacy SHA-256 hashes auto-migrated on first login

### Input Validation
- **Prevention targets**: Storage abuse, data corruption, prompt injection
- **All fields validated**: username (3-30 chars), password (6-128), name (2-100), phone (+994 format)
- **Sanitisation**: Trim whitespace, strip control characters
- **Defence-in-depth**: Client-side + service-layer validation

### RBAC (Role-Based Access Control)
- **4 roles**: admin, doctor, receptionist, patient
- **Admin**: Full access to all 5 screens
- **Doctor**: Doctors, Patients, Appointments, AI Assistant
- **Receptionist**: Patients, Appointments, AI Assistant
- **Patient**: Appointments, AI Assistant only

## 4. Data Model Design

### AppUser
| Field | Type | Notes |
|-------|------|-------|
| id | String (UUID) | Primary key |
| username | String | Unique, indexed |
| passwordHash | String | PBKDF2 hash |
| salt | String | Random 16 bytes, base64 |
| role | UserRole | admin/doctor/receptionist/patient |
| fullName | String | Display name |
| createdAt | DateTime | Auto-set on creation |

### Patient
| Field | Type | Notes |
|-------|------|-------|
| id | String (UUID) | Primary key |
| fullName | String | Required |
| birthDate | DateTime | Required |
| phone | String | Required, validated |
| allergies | String? | Optional |
| chronicConditions | String? | Optional |
| notes | String? | Optional |
| createdAt | DateTime | Auto-set |
| updatedAt | DateTime | Auto-updated |

### Doctor
| Field | Type | Notes |
|-------|------|-------|
| id | String (UUID) | Primary key |
| fullName | String | Required |
| specialty | String | Required |
| phone | String | Required |
| consultationFee | double | Required |
| schedule | String? | Optional JSON |
| createdAt | DateTime | Auto-set |
| updatedAt | DateTime | Auto-updated |

### Appointment
| Field | Type | Notes |
|-------|------|-------|
| id | String (UUID) | Primary key |
| patientId | String (UUID) | FK to Patient |
| doctorId | String (UUID) | FK to Doctor |
| dateTime | DateTime | Appointment time |
| status | AppointmentStatus | scheduled/completed/cancelled/noShow |
| reason | String? | Reason for visit |
| createdAt | DateTime | Auto-set |
| updatedAt | DateTime | Auto-updated |

## 5. UI/UX Design Decisions

### Layout
- **Navigation**: NavigationRail (Material 3) — space-efficient sidebar
- **Responsive**: ConstrainedBox with maxWidth 380 for login
- **Loading states**: CircularProgressIndicator
- **Error states**: Text with error colour + SnackBars
- **Delete protection**: AlertDialog confirmation before any destructive action

### Search & Pagination
- **Live search**: onChanged triggers immediate filter
- **Pagination**: 50 items per page, "Load More" pattern

### Locale
- **Language**: Azerbaijani (Azərbaycan dili)
- **Validation messages**: Azerbaijani with clear, friendly tone

## 6. CI/CD Pipeline

### GitHub Actions Workflows
- `flutter.yml` — separate test + analyze jobs (parallel)
- `flutter_ci.yml` — combined analyze + test job (faster)

### Pre-commit checklist
1. `flutter pub get` — dependencies resolved
2. `flutter analyze` — no lint errors
3. `flutter test` — all tests passing

## 7. Deployment Strategy

### Build targets
- **Web**: `flutter build web` (recommended for cloud deployment)
- **Linux**: `flutter build linux` (desktop clinic use)
- **Android**: `flutter build apk` (mobile access)

### Environment variables
- `TENANT_ID` — Unique clinic identifier
- `LICENSE_SERVER_URL` — License validation endpoint
- `AI_ENDPOINT` — AI assistant API URL

## 8. Performance Considerations

### Local-first architecture
- All data stored locally via Sembast
- No network dependency for CRUD operations
- Privacy-preserving: clinical data never leaves the device

### Query optimisation
- Indexed queries via Sembast filters
- Pagination prevents memory overload
- Appointment sorting by dateTime

## 9. Future Roadmap

### Short-term (next sprint)
- Export patient/doctor data (CSV/PDF)
- Advanced appointment filtering (by date range, doctor)
- Audit log for security events

### Medium-term
- Cloud sync with conflict resolution
- Multi-language support (English, Russian)
- Push notifications for appointment reminders

### Long-term
- Telemedicine integration
- Insurance claim processing
- Billing & invoicing module

---

*Document version: 1.0 — Last updated: August 2026*