# Klinika İdarəetmə Sistemi — Deployment

## Environment Variables (--dart-define)

| Variable | Default | Description |
|---|---|---|
| `TENANT_ID` | `demo-clinic` | Unique clinic/tenant identifier |
| `LICENSE_SERVER_URL` | `https://license.example.com/api` | License heartbeat endpoint |
| `AI_ENDPOINT` | (none) | AI assistant API URL |

Example build:
```bash
flutter build web --dart-define=TENANT_ID=clinic-01 --dart-define=LICENSE_SERVER_URL=https://lic.myvendor.com/api
```

## Build Commands

```bash
# Web (recommended for deployment)
flutter build web

# Linux desktop
flutter build linux

# Android (requires Android SDK)
flutter build apk

# iOS (requires macOS + Xcode)
flutter build ios
```

## Project Architecture

```
lib/
├── main.dart                  # Entry point + MultiProvider
├── core/
│   ├── app_config.dart        # Environment config
│   ├── db/app_database.dart   # Sembast local DB
│   ├── models/models.dart     # Data models with timestamps
│   ├── password_hasher.dart   # PBKDF2 password hashing
│   ├── repositories/          # CRUD with pagination
│   ├── services/              # Auth, License, AI services
│   └── validators.dart        # Input validation helpers
├── ui/
│   ├── home_shell.dart        # NavigationRail + RBAC
│   └── screens/               # All screens
test/
└── security/                  # Security-specific tests
```

## Security Notes

- Passwords hashed with PBKDF2-HMAC-SHA256 (600,000 iterations)
- All forms validated client-side before submission
- Role-based access enforced in navigation
- Legacy SHA-256 hashes migrated to PBKDF2 on first login
- Local-first architecture — no clinical data leaves the device