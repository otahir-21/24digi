# 24Kivi App — Scalable Architecture (Million-User Ready)

This doc defines how to structure the Flutter app so it stays maintainable, testable, and scalable as the user base and team grow.

---

## 1. Principles

| Principle | Why it matters at scale |
|-----------|-------------------------|
| **Feature-first** | Teams own vertical slices; fewer merge conflicts and clearer ownership. |
| **Single responsibility** | Each folder/class has one job; changes are local and safe. |
| **Dependency direction** | Core ← Data ← Features. Features never import other features directly. |
| **Explicit dependencies** | Inject repos and services (e.g. via Provider/Riverpod); easy to test and swap. |
| **Environment-aware** | Dev / staging / prod config and API URLs; no secrets in code. |

---

## 2. Target folder structure

```
lib/
├── main.dart                    # Bootstrap: providers, MaterialApp, initial route
├── app.dart                     # (optional) MaterialApp + theme + routes
│
├── core/                        # App-wide, no feature logic
│   ├── config/
│   │   ├── env.dart             # Flavor / env (dev, staging, prod)
│   │   ├── api_config.dart      # Base URL, timeouts (uses env)
│   │   └── app_constants.dart   # Figma scale, colors, gradients
│   ├── theme/
│   │   └── app_theme.dart       # ThemeData, text styles
│   ├── router/
│   │   └── app_router.dart       # Named routes or go_router
│   ├── errors/
│   │   └── app_exceptions.dart  # Domain/API error types
│   └── utils/                   # Pure helpers (no UI, no I/O)
│       └── (e.g. date_utils.dart)
│
├── data/                        # All I/O and “how we get/store data”
│   ├── api/
│   │   ├── api_client.dart      # Dio instance, interceptors
│   │   ├── api_response.dart    # Envelope (success, data, error)
│   │   └── api_error.dart
│   ├── repositories/           # Implementations (call API, map to models)
│   │   ├── auth_repository.dart
│   │   └── profile_repository.dart
│   ├── models/                  # DTOs (request/response shapes)
│   │   ├── auth_models.dart
│   │   └── profile_models.dart
│   └── local/
│       └── token_storage.dart   # Secure storage, prefs, etc.
│
├── features/                    # One folder per feature (vertical slice)
│   ├── auth/
│   │   ├── providers/
│   │   │   └── auth_provider.dart
│   │   ├── screens/
│   │   │   ├── welcome_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   └── otp_screen.dart
│   │   └── widgets/             # Feature-specific widgets (optional)
│   │
│   ├── onboarding/
│   │   ├── screens/
│   │   │   ├── sign_up_setup2.dart … sign_up_setup7.dart
│   │   │   └── review_screen.dart
│   │   └── widgets/
│   │
│   ├── home/
│   │   ├── screens/
│   │   │   └── home_screen.dart
│   │   └── widgets/
│   │
│   ├── bracelet/                # Bracelet / device feature
│   │   ├── channel/
│   │   │   └── bracelet_channel.dart
│   │   ├── screens/
│   │   │   ├── bracelet_screen.dart
│   │   │   ├── heart_screen.dart
│   │   │   ├── sleep_screen.dart
│   │   │   └── …
│   │   ├── widgets/
│   │   └── debug_bracelet_page.dart (or under screens/)
│   │
│   └── profile/                 # (optional) Settings, edit profile
│       ├── screens/
│       └── widgets/
│
└── shared/                      # Shared UI and helpers used by multiple features
    ├── widgets/
    │   ├── screen_shell.dart
    │   ├── primary_button.dart
    │   ├── digi_text.dart
    │   ├── digi_background.dart
    │   ├── glass_card.dart
    │   └── setup_widgets.dart
    ├── painters/
    │   ├── smooth_gradient_border.dart
    │   ├── stress_icon_painter.dart
    │   └── spo2_icon_painter.dart
    └── router/
        └── root_screen.dart     # Decides home vs login vs onboarding
```

---

## 3. Dependency rules

- **core** — No imports from `data/`, `features/`, or `shared/`. Only Dart/Flutter and env/config.
- **data** — Imports only `core/` (config, errors). No `features/` or `shared/`.
- **features/xxx** — Can import `core/`, `data/`, and `shared/`. Prefer not importing other features; use events or shared state (e.g. `AuthProvider`) instead.
- **shared** — Can import only `core/`. No `data/` or `features/` (keeps shared UI dumb and reusable).

---

## 4. Naming and files

- **Screens**: `*_screen.dart` (e.g. `login_screen.dart`, `home_screen.dart`).
- **Widgets**: `snake_case.dart`; reusable ones in `shared/widgets/` or `features/xxx/widgets/`.
- **Repositories**: `*_repository.dart` in `data/repositories/`.
- **Models/DTOs**: `*_models.dart` or single-purpose files in `data/models/`.
- **Providers/state**: `*_provider.dart` in `features/xxx/providers/` (or a single `state/` folder per feature).

---

## 5. Config and environment (million-user readiness)

- **Environments**: Use **build flavors** (e.g. dev, staging, prod) so each build has its own API base URL and feature flags.
- **Secrets**: Never commit API keys or secrets. Use env files (e.g. `.env.development`, `.env.production`) with `flutter_dotenv` or code generation, and keep `.env*` in `.gitignore`.
- **API base URL**: Read from `core/config/` (e.g. `ApiConfig.baseUrl` from `Env.current`).
- **Feature flags**: Optional; can live in `core/config/feature_flags.dart` and be toggled per env for gradual rollouts.

---

## 6. State management at scale

- **Current**: Provider is fine for small/medium apps.
- **As you grow**: Consider **Riverpod** (testable, compile-safe, no `BuildContext` for business logic) or **Bloc** (clear events/states, good for complex flows). Migrate one feature at a time.
- **Rules**:
  - Global auth/session: one place (e.g. `AuthProvider` in `features/auth/providers/`).
  - Feature-specific state: inside that feature folder.
  - Avoid passing `BuildContext` into repositories or use cases; keep UI and business logic separate.

---

## 7. Testing layout

Mirror `lib/` under `test/`:

```
test/
├── core/
├── data/
│   ├── api/
│   ├── repositories/
│   └── local/
├── features/
│   ├── auth/
│   ├── onboarding/
│   └── …
└── shared/
```

- **Unit**: Repositories (mock API client), providers (mock repo), utils.
- **Widget**: Screens and key shared widgets.
- **Integration**: Critical flows (login → home, onboarding → finish).

---

## 8. Checklist for “million users”

- [ ] Env-based config (dev/staging/prod) and no hardcoded secrets
- [ ] Feature-first `lib/` structure with clear dependency direction
- [ ] Single place for auth/session state; 401 → refresh or logout
- [ ] Repositories as the only place that talks to API/local storage
- [ ] Router in one place (named routes or go_router)
- [ ] Tests for repos and critical flows
- [ ] Error handling and user-facing messages from a single place (e.g. `AppExceptions` + snackbar/dialog)
- [ ] Logging (e.g. crash reporting) without PII in production
- [ ] Optional: split large features into packages for build speed and team ownership

You can migrate toward this structure step by step using `docs/MIGRATION.md`.
