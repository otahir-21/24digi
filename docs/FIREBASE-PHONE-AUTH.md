# Firebase Phone Auth — Backend & Flutter Plan

Use this when you want to switch (or add) Firebase Phone Auth so the app uses Firebase for SMS/verification and your backend still issues your own tokens.

---

## How soon can you implement?

| Step | Who | Effort |
|------|-----|--------|
| 1. Backend: new endpoint + Firebase Admin | Backend | ~2–4 hours |
| 2. Flutter: add Firebase, new login flow | You | ~2–4 hours |
| 3. Testing (dev + staging) | Both | ~1–2 hours |

**Total:** about **1 day** once the backend endpoint is ready. Flutter can be done in parallel once the contract (request/response) is agreed.

---

## What you need the backend to change

### 1. New endpoint (recommended)

Add a **single new route** that accepts a **Firebase ID token** and returns your **existing auth response** (same as `verify-otp`).

**Suggested route:** `POST /auth/login/verify-firebase`  
*(or re-use `/auth/login/verify-otp` with a body that can be either `challenge_id + otp_code` or `firebase_id_token` — your choice.)*

**Request body:**

```json
{
  "firebase_id_token": "<idToken from Firebase Auth>",
  "device": {
    "device_id": "string",
    "platform": "android",
    "app_version": "1.0.0",
    "push_token": "optional"
  }
}
```

**Response (200):** same as current verify-otp:

```json
{
  "success": true,
  "data": {
    "access_token": "...",
    "refresh_token": "...",
    "user": {
      "user_id": "...",
      "is_profile_complete": false
    }
  },
  "error": null
}
```

So the **only** change in the response shape is: **none**. Re-use the same DTOs.

---

### 2. Backend logic for the new endpoint

1. Read `firebase_id_token` from the request body.
2. **Verify the token** with the **Firebase Admin SDK**:
   - **Node:** `admin.auth().verifyIdToken(firebase_id_token)`
   - Returns decoded claims: `uid`, `phone_number` (e.g. `+971501234567`), etc.
3. **Find or create your user** by `phone_number` (or by Firebase `uid` if you store it).
4. **Issue your own tokens** (same as you do after verify-otp): create session, generate `access_token` and `refresh_token`.
5. Return `{ success: true, data: { access_token, refresh_token, user } }`.
6. On invalid/expired Firebase token → return `401` or `400` with a clear error (e.g. `invalid_firebase_token`).

**Backend dependencies:**

- **Firebase Admin SDK** (e.g. `firebase-admin` in Node).
- **Service account key** (JSON) for your Firebase project (from Firebase Console → Project settings → Service accounts). Store it securely (env var path or secret manager); never commit it.

**Optional:** Keep existing `login/start` + `login/verify-otp` for **email** (or as fallback). Use Firebase only for **phone**.

---

### 3. Summary: what to ask the backend to do

| Item | Detail |
|------|--------|
| **New route** | `POST /auth/login/verify-firebase` (or extend verify-otp). |
| **Request** | Body: `firebase_id_token` (string), optional `device` (same as now). |
| **Response** | Same as verify-otp: `access_token`, `refresh_token`, `user` (with `user_id`, `is_profile_complete`). |
| **Backend logic** | Verify `firebase_id_token` with Firebase Admin → get phone (and optionally uid) → find/create user → issue your tokens. |
| **No change** | Refresh token, logout, profile APIs stay as they are. |

---

## What you will change in Flutter

1. **Add packages:** `firebase_core`, `firebase_auth`.
2. **Configure Firebase:**  
   - Android: `google-services.json`, add SHA-1 in Firebase Console.  
   - iOS: `GoogleService-Info.plist`, enable Phone in Sign-in methods.
3. **New auth flow for phone:**
   - User enters phone number (with country code, e.g. +971…).
   - Call `FirebaseAuth.instance.verifyPhoneNumber(...)` (reCAPTCHA/SMS is handled by Firebase).
   - On success, get `PhoneAuthCredential` → sign in with it → get `User` → `user.getIdToken(true)` to get the **Firebase ID token**.
   - Send that token to your backend: `POST /auth/login/verify-firebase` with `{ "firebase_id_token": idToken, "device": {...} }`.
   - Backend returns your `access_token` and `refresh_token` → store them (e.g. `SecureTokenStorage`) and fetch profile; then navigate to home or onboarding (same as current flow).
4. **AuthProvider:** add a method like `loginWithFirebasePhone(String idToken)` that calls the new backend endpoint and then applies the same “store tokens + load profile + notify” logic as after verify-otp.
5. **UI:** Login screen (SecondScreen) for phone: after user taps “Send code”, run Firebase `verifyPhoneNumber`; on code sent, show your OTP screen; on verification success, get ID token and call `loginWithFirebasePhone(idToken)` then navigate to setup2 or home.  
   You can keep the **email** path as-is (current backend OTP) or later add Firebase Email Link if you want.

No changes are needed to your profile, refresh, or logout APIs — only how you obtain the first token (Firebase ID token → backend → your tokens).

---

## Minimal backend contract (copy-paste for backend team)

```
New endpoint: POST /auth/login/verify-firebase

Request body (JSON):
  - firebase_id_token (string, required): ID token from Firebase Auth after phone sign-in
  - device (object, optional): same as current auth (device_id, platform, app_version, push_token)

Response (200): same as POST /auth/login/verify-otp
  - success: true
  - data.access_token (string)
  - data.refresh_token (string)
  - data.user.user_id (string)
  - data.user.is_profile_complete (boolean)

Errors:
  - 400/401 if firebase_id_token is missing, invalid, or expired
  - Same error envelope as rest of API: { success: false, error: { message, code, details } }

Backend must:
  1. Verify firebase_id_token with Firebase Admin SDK (verifyIdToken).
  2. From decoded token: get phone_number (and optionally firebase uid).
  3. Find or create user by phone (or uid), create session, issue access_token and refresh_token.
  4. Return the same payload as verify-otp.
```

---

## Timeline again

- **Backend:** Implement the one endpoint and Firebase Admin verification (~half day).
- **You:** As soon as the endpoint is ready (or even with a mock), add Firebase to the app and the new phone flow (~half day).  
So: **you can implement Firebase phone auth as soon as the backend exposes this contract** — roughly **one day** end-to-end if both sides work in parallel.
