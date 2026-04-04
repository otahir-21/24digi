# RevenueCat + Firebase Auth + Flutter + CRM (C BY AI)

This app links **Firebase Auth UID** to **RevenueCat** (`Purchases.logIn(uid)`), unlocks C BY AI when the RevenueCat entitlement **`c_by_ai`** is active (or when Firestore `user_entitlements/{uid}` allows access as a fallback).

---

## 1. RevenueCat dashboard

1. Create a project at [app.revenuecat.com](https://app.revenuecat.com).
2. **Apps**: add **iOS** (bundle id from Xcode) and **Android** (application id from `android/app/build.gradle`).
3. **App Store Connect** / **Google Play Console**: create a **subscription** product (e.g. monthly). Note the **product id**.
4. In RevenueCat → **Products**: import that store product.
5. **Entitlements**: create entitlement id **`c_by_ai`** (must match `ApiConfig.revenueCatCByAiEntitlementId` in code).
6. **Offerings**: create an offering, set it as **Current**, attach a **package** (e.g. monthly) linked to the product, and ensure that package **grants** entitlement **`c_by_ai`**.

Optional: set `ApiConfig.revenueCatCByAiPackageIdentifier` to your package id (e.g. `$rc_monthly`) if you do not want the default “monthly or first package” logic.

---

## 2. API keys (Flutter)

Use **public** SDK keys from RevenueCat → **API keys** (platform-specific).

**Local / CI:**

```bash
flutter run \
  --dart-define=REVENUECAT_IOS_KEY=appl_xxxxxxxx \
  --dart-define=REVENUECAT_ANDROID_KEY=goog_xxxxxxxx
```

**Xcode archive / Android release:** pass the same `--dart-define` values in your build pipeline (or wrap `main()` with flavors that supply keys).

If keys are missing, RevenueCat is skipped; C BY AI paywall then relies only on **Firestore** `user_entitlements` (when `cByAiPaywallEnabled` is true).

---

## 3. App configuration (`lib/core/api_config.dart`)

| Constant | Purpose |
|----------|--------|
| `cByAiPaywallEnabled` | `true` = require entitlement (RevenueCat **or** Firestore) for C BY AI welcome / recovery. |
| `revenueCatCByAiEntitlementId` | Default `c_by_ai` — must match RevenueCat entitlement id. |
| `revenueCatCByAiPackageIdentifier` | Optional; empty = use monthly / first package on current offering. |

---

## 4. Firebase

- **Authentication**: unchanged; UID is the app user id everywhere.
- **Firestore** `user_entitlements/{uid}` (optional): manual grants or backend mirror; see field names in `lib/subscriptions/c_by_ai_entitlement.dart`.

---

## 5. CRM: show or post data

**You do not read CRM from the mobile app.** Use one of these:

### Option A — RevenueCat → your CRM (fastest)

1. RevenueCat → **Integrations** → connect **HubSpot**, **Segment**, **Slack**, etc., or **Webhooks**.
2. Webhook payload includes `app_user_id` (your Firebase UID), product, expiration, event type.
3. Your CRM (or Zapier/Make) receives events → create/update contact; map `app_user_id` to your CRM custom field.

### Option B — RevenueCat webhook → Cloud Function → Firestore + CRM

1. RevenueCat **Webhooks** → HTTPS Cloud Function.
2. Function validates signature, then:
   - Updates `user_entitlements/{uid}` for reporting/other backends, and/or
   - POSTs to CRM API (HubSpot/Zoho/Salesforce) using a **server-side** API key.

### Option C — Firebase-only CRM view

- If you only need internal reporting, sync webhook → Firestore collection `crm_subscriptions` and build a **Retool / Looker / BigQuery** view later.

---

## 6. Store checklist

- **Apple**: Paid Applications Agreement, tax/banking, subscription group, sandbox tester.
- **Google**: Merchant account, subscription active in Play Console.
- **Xcode**: enable **In-App Purchase** capability for the Runner target.
- **Privacy**: App Privacy / Data safety forms; disclose purchase-related identifiers as required.

---

## 7. In-app UI

- **Subscription** screen (`Subscription`): **Subscribe to C BY AI** and **Restore purchases** appear when RevenueCat is configured (keys present).
- **C BY AI welcome**: **CONTINUE** opens this screen if paywall is on and user has no access; after purchase, **CONTINUE** again (or reopen) picks up RevenueCat entitlement.

---

## 8. Files touched (reference)

- `lib/subscriptions/revenuecat_service.dart` — configure, logIn/logOut, purchase, restore.
- `lib/core/revenuecat_keys.dart` — `--dart-define` keys.
- `lib/subscriptions/c_by_ai_entitlement.dart` — RevenueCat **or** Firestore.
- `lib/main.dart` — `RevenueCatService.initialize()` after Firebase.
- `lib/auth/auth_provider.dart` — `identifyUser` / `logOutUser`.
- `lib/screens/subscribe/widgets/c_by_ai_revenuecat_purchase_section.dart` — purchase UI.
