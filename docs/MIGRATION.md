# Migration to scalable structure

Use this as a step-by-step plan to move from the current layout to the target structure in `ARCHITECTURE.md`. Do **one phase at a time** and run the app + tests after each step.

---

## Current → target map

| Current location | Target location |
|-----------------|-----------------|
| `lib/core/app_constants.dart` | `lib/core/config/app_constants.dart` |
| `lib/core/api_config.dart` | `lib/core/config/api_config.dart` |
| `lib/api/api_client.dart` | `lib/data/api/api_client.dart` |
| `lib/api/models/*.dart` | `lib/data/models/*.dart` |
| `lib/api/auth_repository.dart` | `lib/data/repositories/auth_repository.dart` |
| `lib/api/profile_repository.dart` | `lib/data/repositories/profile_repository.dart` |
| `lib/api/token_storage.dart` | `lib/data/local/token_storage.dart` |
| `lib/auth/auth_provider.dart` | `lib/features/auth/providers/auth_provider.dart` |
| `lib/screens/signup/*.dart` | `lib/features/auth/screens/` (welcome, second, otp) + `lib/features/onboarding/screens/` (setup2–7) |
| `lib/screens/root_screen.dart` | `lib/shared/router/root_screen.dart` |
| `lib/screens/home_screen.dart` | `lib/features/home/screens/home_screen.dart` |
| `lib/screens/bracelet/*.dart` | `lib/features/bracelet/screens/*.dart` |
| `lib/bracelet/*.dart` | `lib/features/bracelet/` (channel, debug page) |
| `lib/widgets/*.dart` | `lib/shared/widgets/*.dart` |
| `lib/painters/*.dart` | `lib/shared/painters/*.dart` |
| `lib/screens/stub_screen.dart` | `lib/features/home/screens/stub_screen.dart` or `lib/shared/widgets/` |

---

## Phase 1: Core and config (low risk)

1. Create folders:
   - `lib/core/config/`
2. Move (and fix imports that reference them):
   - `lib/core/app_constants.dart` → `lib/core/config/app_constants.dart`
   - `lib/core/api_config.dart` → `lib/core/config/api_config.dart`
3. Update every file that imports `app_constants.dart` or `api_config.dart` to use the new paths (e.g. `core/config/app_constants.dart`, `core/config/api_config.dart`).
4. Run `flutter analyze` and the app; fix any broken imports.

---

## Phase 2: Data layer

1. Create:
   - `lib/data/api/`
   - `lib/data/models/`
   - `lib/data/repositories/`
   - `lib/data/local/`
2. Move:
   - `lib/api/api_client.dart` → `lib/data/api/api_client.dart`
   - `lib/api/models/api_error.dart` → `lib/data/models/api_error.dart`
   - `lib/api/models/api_response.dart` → `lib/data/models/api_response.dart`
   - `lib/api/models/auth_models.dart` → `lib/data/models/auth_models.dart`
   - `lib/api/models/profile_models.dart` → `lib/data/models/profile_models.dart`
   - `lib/api/auth_repository.dart` → `lib/data/repositories/auth_repository.dart`
   - `lib/api/profile_repository.dart` → `lib/data/repositories/profile_repository.dart`
   - `lib/api/token_storage.dart` → `lib/data/local/token_storage.dart`
3. Inside moved files, fix **internal** imports (e.g. `api_response.dart` → `models/api_response.dart` or relative paths). Then update **external** imports in:
   - `lib/auth/auth_provider.dart`
   - `lib/main.dart`
   - Any screen that imports api/ or auth.
4. Run `flutter analyze` and the app.

---

## Phase 3: Auth feature

1. Create:
   - `lib/features/auth/providers/`
   - `lib/features/auth/screens/`
2. Move:
   - `lib/auth/auth_provider.dart` → `lib/features/auth/providers/auth_provider.dart`
   - `lib/screens/signup/welcome_screen.dart` → `lib/features/auth/screens/welcome_screen.dart`
   - `lib/screens/signup/second_screen.dart` → `lib/features/auth/screens/login_screen.dart` (optional rename)
   - `lib/screens/signup/otp_screen.dart` → `lib/features/auth/screens/otp_screen.dart`
3. Update imports in moved files (e.g. `../../auth/` → `../../data/`, `../../core/`, `../../shared/`). Update `main.dart` and any route that references these screens.
4. Run the app; test login and OTP flow.

---

## Phase 4: Onboarding feature

1. Create `lib/features/onboarding/screens/`.
2. Move:
   - `lib/screens/signup/sign_up_setup2.dart` … `sign_up_setup7.dart` → `lib/features/onboarding/screens/sign_up_setup2.dart` … `sign_up_setup7.dart`.
3. Fix imports (shared widgets, painters, profile repo, auth provider). Update navigation in setup2→3→…→7 and in `main.dart` routes.
4. Run the app; test full onboarding.

---

## Phase 5: Home and shared router

1. Create `lib/features/home/screens/` and `lib/shared/router/`.
2. Move:
   - `lib/screens/home_screen.dart` → `lib/features/home/screens/home_screen.dart`
   - `lib/screens/stub_screen.dart` → `lib/features/home/screens/stub_screen.dart` (or `lib/shared/widgets/`)
   - `lib/screens/root_screen.dart` → `lib/shared/router/root_screen.dart`
3. Update imports in these files and in `main.dart` (home, root, routes).
4. Run the app; test root → home and navigation.

---

## Phase 6: Bracelet feature

1. Create `lib/features/bracelet/screens/` and `lib/features/bracelet/channel/` (if you keep channel separate).
2. Move:
   - `lib/bracelet/bracelet_channel.dart` → `lib/features/bracelet/channel/bracelet_channel.dart`
   - `lib/bracelet/debug_bracelet_page.dart` → `lib/features/bracelet/screens/debug_bracelet_page.dart` (or `lib/features/bracelet/debug_bracelet_page.dart`)
   - All `lib/screens/bracelet/*.dart` → `lib/features/bracelet/screens/*.dart`
3. Fix imports (shared widgets, painters, channel, core).
4. Run the app; test bracelet and related screens.

---

## Phase 7: Shared UI

1. Create `lib/shared/widgets/` and `lib/shared/painters/`.
2. Move:
   - All `lib/widgets/*.dart` → `lib/shared/widgets/*.dart`
   - All `lib/painters/*.dart` → `lib/shared/painters/*.dart`
3. Update every import in `lib/` that referenced `widgets/` or `painters/` to `shared/widgets/` or `shared/painters/`.
4. Run `flutter analyze` and full app test.

---

## After migration

- Delete empty old folders (`lib/api/`, `lib/auth/`, `lib/screens/`, `lib/widgets/`, `lib/painters/`, `lib/bracelet/` if fully moved).
- Add `lib/core/theme/app_theme.dart` and `lib/core/router/app_router.dart` when you’re ready (see ARCHITECTURE.md).
- Introduce env/flavors (e.g. `lib/core/config/env.dart`) and use it in `api_config.dart` for base URL per environment.

---

## Tips

- Use **Find and Replace** (or IDE “Move”) to update imports after each move.
- Prefer **relative imports** within the same feature; **package imports** (e.g. `package:kivi_24/core/...`) for cross-feature/core to avoid long `../` chains.
- Run tests after each phase; add a few tests for repos and auth if you don’t have them yet.
