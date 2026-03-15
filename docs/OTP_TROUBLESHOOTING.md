# OTP not received – what to check

The app uses **Firebase Phone Authentication**. The SMS is sent by Google/Firebase, not by the app. If you reach the OTP screen but never get the code, check the following.

## 1. Phone number / country code

- The app shows a **confirmation dialog** before sending: “Send verification code to +971…?”  
- If you’re **not in UAE**, the default `+971` is wrong. Enter the number **with country code**, e.g. `+1xxxxxxxxxx` (US), `+92xxxxxxxxxx` (Pakistan), etc.
- If the dialog shows the wrong number, tap **Cancel**, go back, and type the number including the correct `+country_code`.

## 2. Firebase Console

- [Firebase Console](https://console.firebase.google.com) → your project (**kivi-d10da**) → **Authentication** → **Sign-in method**.
- Ensure **Phone** is **Enabled**.
- (Optional) **Phone numbers for testing**: add your number and a fixed code (e.g. `123456`). That number will always get that code without a real SMS (useful for development).

## 3. Android: SHA-1 / SHA-256

- Firebase needs your app’s signing fingerprints.
- **Project settings** (gear) → **Your apps** → select the Android app (`com.digi24.fitness`) → add **SHA-1** and **SHA-256**.
- Get them from your machine, e.g.:
  - Debug:  
    `cd android && ./gradlew signingReport`  
    or from keytool with your keystore.
- Without these, reCAPTCHA/Play Integrity can block or prevent SMS from being sent even if the app moves to the OTP screen.

## 4. Resend and errors

- On the OTP screen, use **Resend OTP**. You’ll see a SnackBar: “Verification code resent” or an error message.
- If you see an error, read it (e.g. “invalid phone number”, “quota exceeded”) and fix the cause (number format, Firebase quota, or project config).

## 5. Delays and carriers

- SMS can be delayed by a few minutes or blocked by the carrier.
- Try **Resend OTP** once; wait 2–3 minutes and check again (and spam folder if applicable).

## Summary

1. Confirm the number in the dialog (correct country code).
2. Enable Phone auth and optionally add a test number in Firebase.
3. On Android, add SHA-1 and SHA-256 in Firebase.
4. Use Resend and read any SnackBar error.
