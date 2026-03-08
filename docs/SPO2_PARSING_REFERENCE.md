# SpO2 parsing: iOS SDK vs Android reference

## 1. iOS SDK – no source for DataParsingWithData

The **iOS** J2208A SDK is delivered as a **precompiled static library**: `SDK/ios/BleSDK/libBleSDK.a`. The repo only has **headers**, not the implementation of `DataParsingWithData:`.

- **Declared in:** `ios/Runner/BleSDKHeaders/BleSDK_J2208A.h`  
  `-(DeviceData_J2208A*)DataParsingWithData:(NSData*_Nullable)bleData;`
- **Return type:** `DeviceData_J2208A` (see `DeviceData_J2208A.h`):
  - `dataType` (`DATATYPE_J2208A` enum: 42, 43, 57, …)
  - `dicData` (`NSDictionary *`)
  - `dataEnd` (`BOOL`)

So **there is no iOS source in the repo** that shows how raw BLE bytes are mapped to:

- **57** (`DeviceMeasurement_Spo2_J2208A`)
- **42** (`AutomaticSpo2Data_J2208A`)
- **43** (`ManualSpo2Data_J2208A`)

That logic lives inside `libBleSDK.a`. To see it you would need either:

- Disassembly of the .a (e.g. with `otool` / Hopper/IDA), or  
- Official SDK source from the vendor.

---

## 2. Android SDK – parsing code (protocol reference)

The **Android** SDK has **Java source**. Its `DataParsingWithData(byte[] value, DataListener2025 dataListener)` in `BleSDK.java` branches on **`value[0]`** (first byte of the BLE packet). The following is the only parsing logic available in the repo and is the best reference for **packet conditions** and **dicData-like keys**.

### 2.1 Live SpO2 measurement → equivalent to iOS type **57**

**Packet condition:**

- `value[0] == 0x28` (`DeviceConst.MeasurementWithType`)
- `value[1] == 3` (measurement type: 1=HRV, 2=HR, **3=Spo2**, 4=temperature)
- `StartDeviceMeasurementWithType == true` (measurement was turned on)

**Code:** `BleSDK.java` (lines 486–538), `case DeviceConst.MeasurementWithType:` → `switch (value[1])` → `case 3: // 0xy`

**Parsed callback (Android):**

- `DataType` = `"75"` (`BleConst.MeasurementOxygenCallback`) — **iOS exposes this as enum 57**
- `End` = `true`
- **Inner map (Data/dicData)** – built as a single `HashMap` and put under `DeviceKey.Data` (Android constant `"dicData"`):

| Key (DeviceKey)   | Source in packet | Description        |
|-------------------|------------------|--------------------|
| `HeartRate`       | `value[2]`       | Heart rate         |
| **`Blood_oxygen`**| **`value[3]`**   | **SpO2 %**         |
| `HRV`             | `value[4]`       | HRV                |
| `Stress`          | `value[5]`       | Stress             |
| `HighPressure`    | `value[6]`       | Systolic           |
| `LowPressure`     | `value[7]`       | Diastolic          |
| `KHrvTempValue`   | `value[8]`, `value[9]` (temp × 0.1) | Temperature |

So for **live SpO2 (57)** the payload is a **single record** with SpO2 in **`Blood_oxygen`** (and optionally under a `Data` / `dicData` inner map depending on how the iOS SDK fills `DeviceData_J2208A.dicData`).

---

### 2.2 Automatic SpO2 history → equivalent to iOS type **42**

**Packet condition:**

- `value[0] == 0x66` (`DeviceConst.GetAutomaticSpo2Monitoring`)

**Code:** `BleSDK.java` (lines 699–703) → `ResolveUtil.GetAutomaticSpo2Monitoring(value)`  
`ResolveUtil.java` (lines 113–140)

**Parsed structure:**

- `DataType` = `"68"` (`BleConst.GetAutomaticSpo2Monitoring`) — **iOS exposes this as enum 42**
- `End` = `false` (or `true` if `value[length-1] == (byte) 0xff` or no records)
- **Data** = **list** of maps; each map:
  - **`Date`** – string from BCD bytes `value[3+i*10]` … `value[8+i*10]` (`"20YY.MM.DD HH:mm:ss"`)
  - **`Blood_oxygen`** – `getValue(value[9 + i * count], 0)` with **count = 10**

So **10 bytes per record**; SpO2 is at **offset 9** in each record. Last byte `0xff` indicates end of list.

---

### 2.3 Manual SpO2 history → equivalent to iOS type **43**

**Packet condition:**

- `value[0] == 0x60` (`DeviceConst.CMD_Get_Blood_oxygen`)

**Code:** `BleSDK.java` (lines 622–627) → `ResolveUtil.getBloodoxygen(value)`  
`ResolveUtil.java`: method **`getBloodoxygen`** (lines 722–749) — same layout as automatic:

- **count = 10** bytes per record
- **`Date`** from `value[3 + i*count]` … `value[8 + i*count]` (BCD)
- **`Blood_oxygen`** = `getValue(value[9 + i * 10], 0)`
- `End` = `true` when `value[length-1] == (byte) 0xff`

**DataType** in Android = `BleConst.Blood_oxygen` (`"55"`). On **iOS** the same response is **43** (`ManualSpo2Data_J2208A`).

---

## 3. Summary table (Android as reference)

| iOS dataType | Android command byte | Android DataType string | Packet condition | dicData / Data keys for SpO2 |
|--------------|----------------------|--------------------------|------------------|------------------------------|
| **57** (DeviceMeasurement_Spo2) | 0x28, value[1]=3 | "75" (MeasurementOxygenCallback) | Live measurement on, type 3 | Single map: **Blood_oxygen** (+ HeartRate, HRV, Stress, HighPressure, LowPressure, KHrvTempValue). May be top-level or under **Data**. |
| **42** (AutomaticSpo2Data) | 0x66 | "68" (GetAutomaticSpo2Monitoring) | Response to GetAutomaticSpo2 | List of { **Date**, **Blood_oxygen** }; 10 bytes/record, SpO2 at index 9. |
| **43** (ManualSpo2Data) | 0x60 | "55" (Blood_oxygen) | Response to GetManualSpO2 (CMD_Get_Blood_oxygen) | Same list layout: { **Date**, **Blood_oxygen** }; 10 bytes/record. |

---

## 4. dicData keys to use in the app

From the Android parsing and common iOS SDK patterns:

- **SpO2 value:** **`Blood_oxygen`** (or `blood_oxygen`). For **57**, it may appear at top-level of `dicData` or inside **`Data`** (or `dicData` again depending on SDK).
- **57:** Prefer **`dicData["Data"]["Blood_oxygen"]`** if present, else **`dicData["Blood_oxygen"]`** (see `BraceletDataParser.extractSpo2FromDicData`).
- **42 / 43:** Typically **array/list** of records; each record has **`Blood_oxygen`** and **`Date`**. Take the **latest** valid record (e.g. by Date) and read **`Blood_oxygen`** in range 1–100.

The **exact** way the iOS binary fills `dicData` for 42/43/57 is not visible without inspecting `libBleSDK.a` or vendor docs; the Android code above is the only in-repo reference for packet layout and keys.
