# Bracelet Latest Activity (Running / Walking / Swimming) – SDK Audit

## Short answer

**Yes, you get “latest activity” with a type (e.g. Running, Walking) without the user selecting an activity in the app** — but only as **historical sport sessions** from the device. The SDK does **not** expose a “current live activity type” (e.g. “user is running right now” in the realtime stream). There is **no Swimming** in the J2208A activity-type list.

---

## 1. What the latest SDK provides

### 1.1 Activity mode **history** (type 30) – this is what you use for “latest activity”

| API | Data type | Description |
|-----|-----------|-------------|
| **GetActivityModeDataWithMode:withStartDate:** | Response **ActivityModeData_J2208A = 30** | “Get sports type historical data” 获取运动类型历史数据 |

- You **request** activity mode data (your app already does this via `requestActivityModeData()` on connect and every 30s).
- The device responds with **type 30** and a payload that includes:
  - **arrayActivityModeData** (or **Data** / **arrayActivityMode**)  
  - Each record has: **date**, **activityMode** (0–17), **heartRate**, **step**, **calories**, **distance**, **activeMinutes**, **paceMinutes**, **paceSeconds**, etc.

So “latest activity” = **latest session(s)** in that history, each with an **activityMode** (Running, Walking, Cycling, etc.). You do **not** need the user to select an activity in the app to get this; you just call **GetActivityModeData** and parse type 30.

**Source (SDK):**

- `latestSDK/ios/BleSDK/BleSDK_J2208A.h`: GetActivityModeDataWithMode (mode 0 = latest, up to 50 sets).
- `latestSDK/ios/Ble SDK Demo/Ble SDK Demo/activityHistoryData.m`: type 30 parsed as `dicData[@"arrayActivityModeData"]`, each item has `activityMode`, `date`, `step`, `calories`, etc.

### 1.2 Activity types (0–17) – no Swimming

From **BleSDK_Header_J2208A.h** (ACTIVITYMODE_J2208A):

| Index | Name (SDK) | Index | Name (SDK) |
|-------|------------|-------|------------|
| 0 | Run | 9 | Walk |
| 1 | Cycling | 10 | Workout |
| 2 | Badminton | 11 | Cricket |
| 3 | Football | 12 | Hiking |
| 4 | Tennis | 13 | Aerobics |
| 5 | Yoga | 14 | Ping Pong |
| 6 | Breath | 15 | Rope Jump |
| 7 | Dance | 16 | Sit Ups |
| 8 | Basketball | 17 | Volleyball |

**Swimming is not in the enum.** The J2208A SDK does not define a Swimming activity type. If the device supports swimming, it would be outside this enum (e.g. firmware-specific).

### 1.3 “Sport mode” started from the app (type 31 / 32 / 33)

| API | Description |
|-----|-------------|
| **EnterActivityMode:WorkMode:BreathParameter:** | User **selects** a sport in the app (e.g. Run, Walk); app sends “enter” (WorkMode 1). |
| **QuitActivityMode** (WorkMode 4) | Exit that mode. |
| **DeviceSendDataToAPP_J2208A (33)** | While in app-entered mode, device can send step/HR/calories/activeMinutes every second. |

So “sport mode” here is **user/app-driven**, not “device auto-detected current activity.” The doc also says: when the watch is in multi-sport mode **via the APP**, the APP must send data to the watch every 1 second or the watch exits the mode.

### 1.4 Realtime stream (type 24) – no activity type

**RealTimeStep_J2208A = 24** carries: step, calories, distance, heartRate, temperature (and possibly blood_oxygen when SpO2 is on). The SDK and demo do **not** include an “activity type” or “current sport” field in type 24. So you do **not** get “user is running/walking right now” from the realtime stream; you only get numbers (steps, HR, etc.).

---

## 2. Without selecting a specific activity – what you get

- You **do** get **latest activity (sport sessions with a type)** by:
  - Calling **GetActivityModeData** (your `requestActivityModeData()`).
  - Receiving **type 30** with **arrayActivityModeData**.
  - Taking the **latest** session(s) and reading **activityMode** (0–17) → Run, Walk, Cycling, etc.
- So “latest activity” with labels like Running, Walking, etc. **does not require** the user to select an activity in the app; it comes from the **device’s stored history** (type 30).

Whether those sessions were:

- Started by the user on the **watch** (e.g. “Start Run” on device), or  
- Started by the **app** (EnterActivityMode), or  
- **Auto-detected** by the device (e.g. walking when step pattern matches)

is **not** defined in the SDK. The SDK only defines the **data format** (type 30 + activityMode 0–17). Behavior is **device/firmware-dependent**. Many bands do auto-detect walking (and sometimes running) and record type 30 sessions; you can confirm on your device by checking if type 30 sessions appear after walking without starting any mode in the app.

---

## 3. What your app already does

- **BraceletChannel.requestActivityModeData()** → calls native **requestActivityModeData**.
- **iOS** BraceletBleAdapter: **requestActivityModeData()** calls `getActivityModeData(withMode: 0, withStart: startOfToday)` and sends the result to the device.
- **Bracelet screen**: On connect and every 30s it calls **requestActivityModeData()**; on **type 30** it parses with **BraceletDataParser.parseActivityModeDataLatest()** and **parseActivityModeDataTodayList()**, and shows the result in the “Latest Activity” card.
- **Parser** supports: `Data`, `data`, `arrayActivityModeData`, `arrayActivityMode` and per-record keys: `ActivityMode` / `activityMode`, `Date`, `Step`, `HeartRate`, `Calories`, `Distance`, `ActiveMinutes`, `Pace`, etc.

So you are **already** using the SDK’s “latest activity” (sport type) data; it’s the same data the SDK provides for “sport type historical data” (type 30).

---

## 4. Summary table

| Question | Answer |
|----------|--------|
| Do I get latest activity (e.g. Running, Walking) **without** user selecting an activity in the app? | **Yes** – from **type 30** (GetActivityModeData) as **historical sessions** with **activityMode** 0–17. |
| Is there a **live/current** activity type in the realtime stream (e.g. “user is running now”)? | **No** – type 24 (RealTimeStep) has no activity type field in the SDK. |
| Does the SDK say if type 30 sessions are **auto-detected**? | **No** – SDK only describes “sports type historical data”; auto-detect is firmware-dependent. |
| Is **Swimming** supported? | **No** – ACTIVITYMODE_J2208A has no Swimming; only 0–17 (Run, Walk, Cycling, etc.). |
| How does the app get “latest activity” today? | Request **GetActivityModeData** (you already do), parse **type 30**, use **parseActivityModeDataLatest** / **parseActivityModeDataTodayList** and show the latest / today’s sessions. |

---

## 5. If “latest activity” is still not showing

- Ensure **requestActivityModeData()** is called when the bracelet is connected (you do this on connect and every 30s).
- In debug, look for **type 30** in the event stream and the parsed **arrayActivityModeData** / **arrayActivityMode**.
- Confirm the **device** actually has activity mode history (e.g. walk/run with the band, or start a sport from the watch, then sync).
- If the device relies on **auto-detection**, it may only create type 30 sessions after a minimum duration or step pattern; try a 5–10 minute walk and then request activity mode data again.

This audit is based on **latestSDK/ios** (BleSDK J2208A headers and Ble SDK Demo).
