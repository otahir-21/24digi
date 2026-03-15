# Sleep Data Integration – 2208 SDK

There is **no separate PDF or manual** for sleep in `latestSDK`; this doc is derived from the Android SDK code so you can integrate sleep data in your app (Flutter/iOS/Android).

---

## 1. Where sleep lives in the SDK

| Item | Location |
|------|----------|
| **Data type (string)** | `BleConst.GetDetailSleepData` = `"26"` |
| **Command (byte)** | `DeviceConst.CMD_Get_SleepData` = `0x53` |
| **Response keys** | `DeviceKey.java`: see below |
| **Request API** | `BleSDK.GetDetailSleepDataWithMode(mode, dateOfLastData)` |
| **Parse raw bytes** | `ResolveUtil.getSleepData(byte[] value)` |
| **Sample app** | `DetailSleepActivity.java` (read/delete sleep history) |

---

## 2. Requesting sleep from the device

**Method:** `BleSDK.GetDetailSleepDataWithMode(mode, dateOfLastData)`

- **mode**
  - `0x00` – start (first batch)
  - `0x02` – continue (next batch)
  - `0x99` – delete sleep data on device
- **dateOfLastData** – last timestamp from previous batch; use `""` or `null` for the first request. After each batch you can save the last `Date` and pass it for the next call (SDK supports it in the command).

Send the returned byte array over BLE to the device.

---

## 3. Response: data type and keys

- **DataType in callback:** `BleConst.GetDetailSleepData` (`"26"`).  
  Delete confirmation: `BleConst.Delete_GetDetailSleepData` (`"94"`).

- **Keys** (from `DeviceKey.java`):

| Key | Meaning |
|-----|---------|
| `DeviceKey.DataType` | `"26"` for sleep |
| `DeviceKey.End` | `true` when no more data |
| `DeviceKey.Data` | `List<Map<String, String>>` – one map per sleep record |
| `DeviceKey.Date` | Record date/time string (e.g. `"20YY-MM-DD HH:mm:ss"`) |
| `DeviceKey.ArraySleep` / `arraySleepQuality` | Space-separated sleep quality values (one per 1 min or per 5 min – see below) |
| `DeviceKey.sleepUnitLength` / `sleepUnitLength` | `"1"` = 1‑minute resolution, `"5"` = 5‑minute resolution |
| `DeviceKey.KSleepLength` / `sleepLength` | Length of sleep data (SDK internal) |

---

## 4. Parsed record shape (from `ResolveUtil.getSleepData`)

Each item in `Data` is a map:

- **Date** – BCD-decoded date/time of the record.
- **arraySleepQuality** – Space-separated numbers (e.g. `"0 1 2 1 0 2 ..."`). Each value is one interval; interval length is 1 min or 5 min depending on `sleepUnitLength`.
- **sleepUnitLength** – `"1"` (1‑minute data) or `"5"` (5‑minute data).  
  Comment in SDK: 5‑minute mode has 24 values (24 × 5 min = 2 hours of granularity per record; actual record may cover more).

You can derive total sleep, deep/light/REM (e.g. by mapping value ranges in your app or reusing logic from `lib/bracelet/data/bracelet_data_parser.dart`).

---

## 5. Flow (from `DetailSleepActivity`)

1. **Read history:** Send `GetDetailSleepDataWithMode(0x00, "")`.  
   On callback with `DataType == GetDetailSleepData`: append `maps.get(DeviceKey.Data)` to your list.  
   If `End` is false and you got 50 items, send `GetDetailSleepDataWithMode(0x02, lastDate)` to continue; repeat until `End` is true.
2. **Delete on device:** Send `GetDetailSleepDataWithMode(0x99, "")`.  
   Response comes as `Delete_GetDetailSleepData` (`"94"`).

---

## 6. Flutter / iOS

- The **Flutter plugin** in `latestSDK/2208FluterSdk/blesdk2025_plugin` has no sleep-specific docs in its README; use the same **data type and keys** as above.
- Your app already uses **data type 27** for sleep in `lib/bracelet/data/bracelet_data_parser.dart` and `SleepStorage`. The **Android SDK uses type "26"** (GetDetailSleepData); confirm with your iOS/Flutter channel whether the device sends 26 vs 27 so you map the same payload.
- **docs/** in the **project root** (not inside latestSDK) has: `AUDIT_ZERO_SLEEP_ACTIVITY.md`, `SDK_RECOVERY_READINESS_FINDINGS.md`, `BRACELET_DUMMY_DATA_AUDIT.md`, `BRACELET_ARCHITECTURE_REVIEW.md` – they describe how sleep is used in the app and how to wire device sleep (e.g. type 27) to the UI.

---

## 7. Quick reference

| What | Value |
|------|--------|
| Sleep data type (BleConst) | `"26"` |
| Delete response | `"94"` |
| CMD byte | `0x53` |
| Request | `GetDetailSleepDataWithMode(mode, dateOfLastData)` |
| Response keys | `Date`, `arraySleepQuality`, `sleepUnitLength` |
| Sample code | `DetailSleepActivity.java`, `ResolveUtil.getSleepData()`, `CsvActivity.getSleepData()` / `saveSleepData()` |

No other documentation file for “integrating sleep data” was found inside **latestSDK**; the above is the integration guide derived from the SDK source.
