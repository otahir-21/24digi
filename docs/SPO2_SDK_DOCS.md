# SpO2 SDK documentation (J2208A)

Summary of SpO2-related APIs and data types from the **iOS SDK headers** (`ios/Runner/BleSDKHeaders/`) and in-repo docs. The Android SDK uses different type numbers; this file focuses on **iOS**.

---

## 1. Live SpO2 measurement (start/stop)

**Method:** `StartDeviceMeasurementWithType:(int)dataType isOpen:(BOOL)isOpen`

- **Header:** `BleSDK_J2208A.h` (lines 236–244)
- **Meaning:** Turn device measurement on/off.
- **Parameters:**
  - `dataType`: **1** = HRV, **2** = HR, **3** = **Spo2**, **4** = temperature
  - `isOpen`: **YES** = on, **NO** = off

**In our app:**

- Start: `startDeviceMeasurement(withType: 3, isOpen: true)` → `startSpo2Monitoring()`
- Stop: `startDeviceMeasurement(withType: 3, isOpen: false)` → `stopSpo2Monitoring()`

**Response:** Device sends data as **dataType 57** (`DeviceMeasurement_Spo2_J2208A`) on the same BLE notify (FFF7). Parse `dicData` for SpO2 (e.g. `Blood_oxygen` / `blood_oxygen`).

---

## 2. Data types (iOS) – SpO2

From `BleSDK_Header_J2208A.h`:

| Enum | Value | Description |
|------|--------|-------------|
| `AutomaticSpo2Data_J2208A` | **42** | Automatic SpO2 historical data (response to GetAutomaticSpo2Data) |
| `ManualSpo2Data_J2208A` | **43** | Manual SpO2 historical data (response to GetManualSpo2Data) |
| `DeviceMeasurement_Spo2_J2208A` | **57** | Live SpO2 measurement result (response to StartDeviceMeasurementWithType(3, YES)) |

Type **24** (RealTimeStep) can optionally include **blood_oxygen** in the same realtime stream when automatic monitoring is on (see Automatic monitoring below).

---

## 3. SpO2 history (automatic / manual)

**Methods (header declares `withStartDate:`; Swift bridge uses `withStart:`):**

- `GetAutomaticSpo2DataWithMode:(int)mode withStartDate:(NSDate*)startDate`
- `GetManualSpo2DataWithMode:(int)mode withStartDate:(NSDate*)startDate`

**Header:** `BleSDK_J2208A.h` (lines 360–378)

**Parameters:**

- **mode**
  - **0** – Read from latest position (up to 50 sets). 从最新的位置开始读取(最多50组数据)
  - **2** – Read next batch when total &gt; 50. 接着读取(当数据总数大于50的时候)
  - **0x99** – Delete all (automatic or manual) SpO2 data. 删除所有自动/手动血氧历史数据
- **startDate** – Start date for reading. Doc says it should match a date stored in the watch exactly, otherwise the parameter may be invalid.

**In our app:** We call `getAutomaticSpo2Data(withMode: 0, withStart: startOfToday)` and `getManualSpo2Data(withMode: 0, withStart: startOfToday)`. Responses arrive as **dataType 42** and **43** on the realtimeData stream.

---

## 4. Automatic monitoring (watch settings)

**Method:** `GetAutomaticMonitoringWithDataType:(int)dataType`

- **Header:** `BleSDK_J2208A.h` (lines 173–179)
- **dataType:** **1** = heartRate, **2** = **spo2**, **3** = temperature, **4** = HRV (血氧饱和度 = SpO2)

This gets the **automatic monitoring configuration** (e.g. whether the watch automatically measures SpO2). The struct `MyAutomaticMonitoring_J2208A` has a field `dataType` with the same meaning (1=HR, 2=spo2, 3=temp, 4=HRV).

When automatic SpO2 is enabled on the watch, type **24** (RealTimeStep) may include **blood_oxygen** in the payload (see `docs/BRACELET_ACTIVITY_SDK.md`).

---

## 5. Payload keys for SpO2 value

From SDK usage and `DeviceKey` / parser:

- **Primary:** `Blood_oxygen`, `blood_oxygen`
- **Alternates:** `spo2`, `SPO2`, `Spo2`, `oxygen`, `Oxygen`

Android demo puts the value in a nested map: `Data: { Blood_oxygen: "98", ... }`. Our parser supports both top-level and nested `Data` / `data` (see `BraceletDataParser.extractSpo2FromDicData`).

---

## 6. References in repo

| File | Content |
|------|---------|
| `ios/Runner/BleSDKHeaders/BleSDK_J2208A.h` | StartDeviceMeasurementWithType, GetAutomaticSpo2Data, GetManualSpo2Data, GetAutomaticMonitoringWithDataType |
| `ios/Runner/BleSDKHeaders/BleSDK_Header_J2208A.h` | DataType enum 42, 43, 57; MyAutomaticMonitoring_J2208A.dataType |
| `docs/BRACELET_ACTIVITY_SDK.md` | Type 24 fields: blood_oxygen / Blood_oxygen (optional) |
| `docs/SPO2_FLOW_DEBUG.md` | Native→Flutter flow and breakpoints for SpO2 |

---

## 7. iOS Swift API (actual selector names)

- Start/stop: `startDeviceMeasurement(withType:isOpen:)` — type **3** for SpO2.
- History: `getManualSpo2Data(withMode:withStart:)`, `getAutomaticSpo2Data(withMode:withStart:)` — header says `withStartDate:` but the framework exposes **withStart:** (same as other history APIs like sleep/activity).
