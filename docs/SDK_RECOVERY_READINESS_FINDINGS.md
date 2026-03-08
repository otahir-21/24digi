# SDK: Recovery / Readiness / Wellness – Findings

Searched the **SDK folder** (iOS headers + Android Java) and **demo apps** for recovery score, readiness, fatigue, body battery, energy, wellness, health score, and related keywords.

---

## 1. Is recovery available directly from the SDK?

**No.** The J2208A SDK does **not** expose:

- Recovery score  
- Readiness score  
- Body battery / energy score  
- Wellness score or health score  
- Any single “recovery” or “readiness” dataType, command, or dicData key  

There are **no** API names or data types containing “recovery”, “readiness”, “wellness”, “body battery”, or “health score” in:

- **iOS:** `ios/Runner/BleSDKHeaders/BleSDK_J2208A.h`, `BleSDK_Header_J2208A.h`, `DeviceData_J2208A.h`  
- **Android:** `BleSDK.java`, `ResolveUtil.java`, `DeviceConst.java`, `BleConst.java`, `DeviceKey.java`  
- **Demo:** No recovery/readiness/wellness activities or screens in the SDK demo apps  

---

## 2. What the SDK does expose (raw metrics for manual recovery)

These are the **data types, commands, and dicData keys** that **can be used to compute recovery/readiness yourself** in the app.

### 2.1 iOS (headers only)

| Data / API | dataType (enum) | Description |
|------------|------------------|-------------|
| **HRV (history)** | 38 `HRVData_J2208A` | GetHRVDataWithMode:withStartDate: → HRV history |
| **HRV (live measurement)** | 56 `DeviceMeasurement_HRV_J2208A` | StartDeviceMeasurementWithType(1, YES) → live HRV result |
| **Sleep (detail)** | 27 `DetailSleepData_J2208A` | GetDetailSleepDataWithMode:withStartDate: → sleep segments |
| **Realtime (live)** | 24 `RealTimeStep_J2208A` | RealTimeDataWithType → step, HR, temp, etc. |
| **Total activity** | 25 `TotalActivityData_J2208A` | Steps, distance, calories (daily) |
| **Activity mode** | 30 `ActivityModeData_J2208A` | Sport sessions (type, duration, HR, etc.) |

There is **no** iOS dataType or method name for recovery/readiness/wellness/score.

**File:** `ios/Runner/BleSDKHeaders/BleSDK_Header_J2208A.h` (DATATYPE_J2208A enum, lines 12–95), `BleSDK_J2208A.h` (method declarations).

---

### 2.2 Android (Java – parsing and keys)

**HRV history (getHrvTestData)**  
- **Command:** `CMD_Get_HrvTestData` (0x56).  
- **Response DataType:** `GetHRVData` = `"42"` (BleConst).  
- **Parsing:** `ResolveUtil.getHrvTestData(value)` → `BleSDK.java` ~311–313.  
- **Per-record keys (DeviceKey / dicData):**  
  `Date`, **`hrv`** (HRV), `vascularAging`, **`stress`** (疲劳度 Tired), `highBP`, `lowBP`, `HeartRate`.  
- **Comment in DeviceKey:** “Stress = 疲劳度” (fatigue degree).  

**File:**  
`SDK/.../blesdk_2208/.../ResolveUtil.java` (lines 853–891),  
`DeviceKey.java` (lines 209–225: HRV, Stress, Fatiguedegree).

**HRV realtime test result (SDNN + fatigue index)**  
- **Keys (DeviceKey):**  
  `hrvResultState`, `hrvResultAvg`, `hrvResultTotal`, `hrvResultCount`, **`hrvResultTired`** (疲劳指数据), `hrvResultValue`.  
- **Usage:** HRV realtime test UI (e.g. `activity_hrv_real_time.xml`), not a separate “recovery” API.  

**File:** `DeviceKey.java` (lines 272–295).

**ECG/PPG result (includes fatigue degree)**  
- **Parsing:** `ResolveUtil` builds a map with **`Fatiguedegree`** (`fatigueDegree`) from `value[5]`, plus HR, HRV, HighPressure, LowPressure, etc.  
- **File:** `ResolveUtil.java` (lines 1375–1401, 1402–1429).

**Sleep**  
- **DataType:** `GetDetailSleepData` = `"26"` (BleConst).  
- **Keys:** `sleepLength`, **`arraySleepQuality`** (5‑minute sleep quality, 24 values), `sleepUnitLength`.  
- **File:** `ResolveUtil.java` (getSleepData, ~664–708), `DeviceKey.java` (182–187).

**Live measurement (type 24 / MeasurementWithType)**  
- Heart rate, Blood_oxygen, HRV, Stress, HighPressure, LowPressure, temperature (e.g. MeasurementHrvCallback, MeasurementOxygenCallback).  
- **File:** `BleSDK.java` (MeasurementWithType branch, ~486–538), `DeviceKey.java`.

---

### 2.3 Summary: raw metrics you can use to calculate recovery manually

| Metric | Source (SDK) | dataType / Command | Key(s) / Notes |
|--------|----------------|--------------------|----------------|
| **HRV** | HRV history / live HRV measurement | 38, 56 (iOS); GetHRVData "42", CMD_Get_HrvTestData 0x56 (Android) | `hrv`, HRV value in dicData |
| **Stress / fatigue (device)** | HRV history; ECG result; live measurement | Same as above; ECG result | **`stress`** (疲劳度); **`fatigueDegree`** (Fatiguedegree); **`hrvResultTired`** (HRV test) |
| **Sleep** | Detail sleep | 27 (iOS); GetDetailSleepData "26", CMD_Get_SleepData 0x53 (Android) | `arraySleepQuality`, sleepLength, deep/light/REM (from your app’s sleep parser) |
| **Resting HR** | Realtime, single HR, or activity/HRV payloads | 24, 28, 29, 55, 56, 38, etc. | `heartRate`, `HeartRate` |
| **Activity load** | Total activity, activity mode | 25, 30 (iOS) | Steps, distance, calories, exercise duration |
| **Temperature** | Realtime / measurement | 24, 57, 58, 45, 46 | `temperature`, `KHrvTempValue` |

There is **no** “recovery” or “readiness” or “body battery” value from the device; you can derive an index in-app from the above (e.g. HRV + sleep quality + stress + activity).

---

## 3. Demo screens / activities

- **Android:**  
  - `HrvDataReadActivity`, `HrvRealTimeActivity`, `MeasurementActivity` (HRV, heart, SpO2, temp), `EcgPPgStatusActivity`, sleep/activity flows.  
  - **No** Recovery, Readiness, Wellness, Body Battery, or “health score” activity.  
- **iOS:** Headers only; no demo app in the SDK folder.  
- **This app (lib/):**  
  - `GeneralRecoveryScreen`, `RecoveryDataButton`, “Hydration Recovery”, “Recovery Consistency”, “Metabolic Readiness” are **app-level UI/copy only**; they are **not** backed by any SDK recovery/readiness API.

---

## 4. Exact file locations (reference)

| What | Location |
|------|----------|
| iOS dataType enum | `ios/Runner/BleSDKHeaders/BleSDK_Header_J2208A.h` (lines 12–95) |
| iOS API list | `ios/Runner/BleSDKHeaders/BleSDK_J2208A.h` (Get*/Set*/DataParsingWithData) |
| Android DataParsing switch | `SDK/.../blesdk_2208/.../BleSDK.java` (DataParsingWithData, ~166+) |
| Android HRV history parsing | `SDK/.../ResolveUtil.java` getHrvTestData (853–891) |
| Android Stress / Fatiguedegree keys | `SDK/.../DeviceKey.java` (209–225, 272–295) |
| Android ECG/Fatiguedegree | `SDK/.../ResolveUtil.java` (1383–1391, 1413–1425) |
| Android sleep keys | `SDK/.../DeviceKey.java` (182–187), ResolveUtil getSleepData (664–708) |
| Android constants | `BleConst.java` (GetHRVData="42", GetDetailSleepData="26"), `DeviceConst.java` (CMD_Get_HrvTestData=0x56, CMD_Get_SleepData=0x53) |

---

## 5. Conclusion

- **Recovery/readiness/wellness/body battery/health score:** **not** provided by the SDK.  
- **For your own recovery/readiness logic:** use **HRV** (history + live), **stress/fatigue** (`stress`, `fatigueDegree`, `hrvResultTired`), **sleep** (detail + `arraySleepQuality`), **resting HR**, and **activity** (steps, exercise) from the data types and keys above.
