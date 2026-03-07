# Bracelet / Wearable Module – Architecture Review

Senior Flutter & backend perspective, based on actual code in this repository.

---

## 1. Module Map

| Area | Location | Notes |
|------|---------|--------|
| **Bracelet / wearable / device** | `lib/bracelet/`, `lib/screens/bracelet/`, `ios/Runner/Bracelet/` | Flutter UI + channel; **native only on iOS** (no Android bridge) |
| **Health metrics** | `bracelet_screen.dart` (`_mergedLiveData`, `_HealthGrid`), `bracelet_components.dart` (ProgressCard, HealthMetricCard) | Steps, HR, HRV, SpO2, BP, temp, stress, sleep; all from device or derived |
| **Dashboard cards** | `bracelet_components.dart`: ProgressCard, LatestActivityCard, ActivityTabs, RecoveryDataButton; `_HealthGrid` in `bracelet_screen.dart` | Cards consume `Map<String, dynamic>? liveData` |
| **Sync logic** | No backend sync. “Sync” = **poll device every 1s** via `startRealtime` + `requestTotalActivityData` in `bracelet_screen.dart` and `bracelet_search_screen.dart` | No server-side aggregation or persistence of bracelet data |
| **BLE / native SDK** | **iOS:** `BraceletPlugin.swift` (MethodChannel + EventChannel), `BraceletBleAdapter.swift` (NewBle + BleSDK_J2208A). **Android:** none (no `com.24digi/bracelet` in `android/`) | Single platform; Android cannot connect to bracelet |
| **API layer** | `lib/api/`: `ApiClient`, `profile_repository`, `auth_repository`, etc. | Used for auth and profile (e.g. `PATCH /profile/health`). **No bracelet/step/sync API** |
| **Local storage / cache** | **Bracelet:** none. Data is in-memory only (`_realtimeData`, `_totalActivityData` in `BraceletScreen`). App uses `flutter_secure_storage` for tokens (`token_storage.dart`) | No persistence of steps, HR, or other device metrics |

---

## 2. Architecture (Structured)

### 2.1 UI layer

- **Entry:** `HomeScreen` → “Bracelet” → `BraceletSearchScreen` (scan/connect) or, if already connected, direct to `BraceletScreen`.
- **BraceletScreen:** Dashboard: ProgressCard (steps, calories, distance), “Last updated”, ActivityTabs, LatestActivityCard, RecoveryDataButton, `_HealthGrid` (8 HealthMetricCards: Sleep, Hydration, Heart Rate, HRV, Stress, SpO2, Temperature, Blood Pressure). All numeric values come from `liveData = _mergedLiveData()`.
- **Sub-screens:** HeartScreen, SleepScreen, BloodPressureScreen, HrvScreen, StressScreen, Spo2Screen, TemperatureScreen, HydrationScreen, ActivitiesScreen, ProgressScreen, GeneralRecoveryScreen, etc. Each either takes `BraceletChannel` and/or `liveData` and requests device data (e.g. `requestSleepData`, `startPpgMeasurement`) and/or subscribes to `channel.events`.
- **Widgets:** `ProgressCard`, `HealthMetricCard`, etc. in `bracelet_components.dart` take `Map<String, dynamic>? liveData` and read keys like `step`, `heartRate`, `calories`, `distance`, `temperature`, `systolic`, `diastolic`, `stress`, `hrv`, `spo2`. No dedicated domain models; raw maps with multiple key variants (e.g. `step` / `Step`).

### 2.2 State management

- **No BLoC / Riverpod / Redux.** State is local to widgets:
  - **BraceletScreen:** `_realtimeData`, `_totalActivityData`, `_bpSystolic`, `_bpDiastolic`, `_dataVersion`, `_lastDataUpdateTime`; updated in `_listenRealtime()` → `applyUpdate()` → `setState`. Timer every 1s calls `_refreshDataFromDevice()` and, if `_lastDataUpdateTime != null`, `setState(() {})` to refresh “Last updated”.
  - **BraceletSearchScreen:** `_scanResults`, `_connectionStatus`, `_selectedIdentifier`, etc.; same channel subscription.
- **BraceletChannel** is created per screen (e.g. `final BraceletChannel _channel = BraceletChannel()` in BraceletScreen and BraceletSearchScreen; `static final BraceletChannel _channel` in SleepScreen). No app-level singleton or injected service for the bracelet.

### 2.3 Repository / service layer

- **No bracelet repository or domain service.** `BraceletChannel` is the only “service”; it wraps platform channels and exposes:
  - `events` (Stream<BraceletEvent>)
  - `scan()`, `stopScan()`, `getRetrievedDevices()`, `getConnectionState()`, `connect(identifier)`, `startRealtime(type)`, `stopRealtime()`, `requestTotalActivityData()`, `requestSleepData()`, `requestHRVData()`, `startPpgMeasurement()`, `disconnect()`.
- Backend: `ProfileRepository` (and auth) use `ApiClient`; no “health metrics” or “bracelet sync” API.

### 2.4 Platform channel / native bridge

- **Mechanism:** **MethodChannel** + **EventChannel** (no Pigeon, no FFI).
  - MethodChannel: `com.24digi/bracelet` — all commands (scan, connect, startRealtime, requestTotalActivityData, etc.).
  - EventChannel: `com.24digi/bracelet/events` — broadcast stream of events: `scanResult`, `connectionState`, `realtimeData`.
- **iOS:** `BraceletPlugin` registers both channels in `register(with:)`; `BraceletBleAdapter` holds `NewBle` (CoreBluetooth wrapper) and `BleSDK_J2208A` (vendor SDK). BLE callbacks (e.g. `bleCommunicate(with:data:)`) call `sdk?.dataParsing(with: d)` and `emit("realtimeData", data: payload)` with `dataType`, `dicData`, `dataEnd`. Plugin registered in `AppDelegate.didInitializeImplicitFlutterEngine` via `BraceletPlugin.register(with: registrar)`.
- **Android:** No registration of `com.24digi/bracelet` in the project’s `android/` folder. Bracelet feature is **iOS-only**.

### 2.5 Backend API integration

- Backend is used for **auth** and **profile** (e.g. `PATCH /profile/health` for health preferences). There is **no API for bracelet data**: no upload of steps/HR/sleep, no dashboard-summary API, no sync or history from server. All health numbers on the bracelet dashboard are **device-only, in-memory**.

### 2.6 Local DB / persistence

- **Bracelet data:** None. No SQLite, Hive, or SharedPreferences for steps, HR, sleep, etc. Disconnect clears in-memory state (`_clearDeviceData()`).
- **App-wide:** `TokenStorage` uses `flutter_secure_storage` (encrypted shared prefs on Android) for tokens only.

### 2.7 Background sync flow

- There is **no background sync** in the sense of “upload to server” or “persist to DB”. “Sync” in this codebase means:
  1. **Foreground:** Every 1s, if connected, call `startRealtime(RealtimeType.stepWithTemp)` and `requestTotalActivityData()`.
  2. Device responds asynchronously via EventChannel (`realtimeData` with `dataType` 24/25/27/38/52/70 etc.).
  3. BraceletScreen (or search screen) handles events, parses `dicData`, updates `_realtimeData` / `_totalActivityData` and runs `setState`.
- When user leaves the bracelet section, `didPop()` stops the timer and calls `stopRealtime()` to reduce battery use. No background worker persists or sends data.

---

## 3. Data Flow, Transformations, and Scale

### 3.1 Where bracelet data enters the app

- **Single entry:** iOS `BraceletBleAdapter.bleCommunicate(with:data:)` receives BLE data → `sdk?.dataParsing(with: d)` → `emit("realtimeData", data: payload)` with `dataType`, `dicData`, `dataEnd`. Flutter receives it via `EventChannel.receiveBroadcastStream()` in `BraceletChannel.events`.

### 3.2 Transformation before UI

- **BraceletScreen.** In `_listenRealtime()`, on `realtimeData`:
  - `dicData` is cast to `Map<String, dynamic>` (`dicMap`).
  - By `dataType`: 25 → `_parseTotalActivityData(dicMap)` → `_totalActivityData` (normalized keys via `_normalizeActivityKeys`). 27 → logged (sleep). 38/56 → HRV merged into `_realtimeData`. 24 (and default) → merged into `_realtimeData`. Blood pressure extracted via `_parseBloodPressure(dicMap)` → `_bpSystolic` / `_bpDiastolic`.
- **Merge for UI:** `_mergedLiveData()` combines `_realtimeData` and `_totalActivityData`: for step/distance/calories it takes max of realtime vs total; normalizes keys (`heartRate`, `hrv`, `spo2`, `temperature`, `stress`); adds BP or HR-based BP estimate and HR-based stress if missing.
- **Dashboard:** `liveData = _mergedLiveData()` passed to ProgressCard and `_HealthGrid`. ProgressCard uses helpers like `_toInt(liveData?['step'])`, `_toDouble(liveData?['distance'])` with fallbacks for multiple key names (e.g. `Distance`, `totalDistance`, `mileage`). So there is a **transformation layer**, but it lives inside the screen and components as static/private methods and map key normalization, not in a separate domain or repository layer.

### 3.3 Raw SDK models and UI

- **SDK “models” are raw maps.** Native sends `dicData` (e.g. from `deviceData.dicData as? [String: Any]`). Flutter never gets a typed Dart model from the SDK; it gets `Map<Object?, Object?>` then `Map<String, dynamic>`. UI widgets (ProgressCard, HealthMetricCard) receive `Map<String, dynamic>? liveData` and read multiple possible keys (e.g. `step`/`Step`, `heartRate`/`HeartRate`). So **SDK shape effectively leaks into the UI**: key names and structure are device/SDK-specific; there is no app-level DTO or domain model that isolates the UI from the SDK.

### 3.4 Where “sync” starts and ends

- **Starts:** User on BraceletScreen or BraceletSearchScreen; 1s timer fires → `_refreshDataFromDevice()` (or search’s equivalent) → `startRealtime(2)` + `requestTotalActivityData()`.
- **Ends:** Device sends one or more BLE responses → native `dataParsing` → `realtimeData` events → Flutter `applyUpdate()` → `setState` → UI rebuild. No write to DB or API.

### 3.5 Date/time normalization

- **Device:** Type 25 total activity can include `date` (e.g. `2026.03.07`). iOS requests “today” via `calendar.startOfDay(for: Date())` for total activity, sleep, HRV.
- **Flutter:** `_lastDataUpdateTime = DateTime.now()` when type 24/25 is applied; displayed as “Xs ago” or “at HH:mm” via `_formatLastUpdated`. No timezone normalization layer; no conversion to UTC or user timezone in a central place. Date parsing for type 25 is implicit (device format in map).

### 3.6 Error handling

- **Channel:** `BraceletChannel.cancelBraceletSubscription` swallows `PlatformException` with “No active stream” (hot restart). `main.dart` `FlutterError.onError` suppresses the same for global error handler.
- **MethodChannel:** `requestHRVData`, `startPpgMeasurement`, `discoveryByQROrOther` catch `PlatformException` and ignore or return a string. Other methods do not wrap in try/catch in the channel class; callers (screens) sometimes use empty `catch (_) {}`.
- **Connection:** On `connectionState` with disconnected state, `_clearDeviceData()` clears in-memory data. No retry policy, no queue of failed requests, no user-visible error message for “request failed”.

### 3.7 Offline support

- **Bracelet:** Works “offline” in the sense that no backend is required for device data. But there is **no offline persistence**: if the app is killed or user disconnects, all steps/HR/etc. are lost. No local cache to show “last known” values after reopen.

### 3.8 Suitability for millions of users

- **Device path:** Per-user, per-device BLE. No backend load for bracelet data today. Scaling issues would be: (1) many concurrent BLE connections on a single phone (not the case here; one device), (2) battery impact of 1s polling (mitigated by stopping when leaving screen).
- **Backend:** No bracelet APIs yet; when added, backend must scale for writes (sync) and reads (dashboard/history). Not applicable to current code.
- **App architecture:** Not ready for scale: no single source of truth, no repository, no caching, no offline, duplicate logic across screens, and Android not implemented.

---

## 4. Important Files and Responsibility / Design

| File | Responsibility | Design |
|------|----------------|--------|
| **lib/bracelet/bracelet_channel.dart** | MethodChannel + EventChannel wrapper; exposes scan, connect, realtime, requestTotalActivityData, requestSleepData, requestHRVData, startPpgMeasurement, disconnect. Parses event envelope to `BraceletEvent`. | **Good:** Single place for channel names and method names. **Risky:** No abstraction above channel (UI and screens call this directly). Comment says “iOS only” but API is used as if cross-platform. |
| **lib/screens/bracelet/bracelet_screen.dart** | Dashboard: state (_realtimeData, _totalActivityData, BP, _dataVersion, _lastDataUpdateTime), 1s timer, event subscription, applyUpdate, _mergedLiveData, _parseTotalActivityData, _normalizeActivityKeys, BP/HRV/step parsing, RouteAware lifecycle, ProgressCard + _HealthGrid. | **Needs refactor:** ~900 lines; mixes UI, parsing, merge logic, and lifecycle. Parsing and merge belong in a service/repository. Raw map types and SDK key names throughout. |
| **lib/screens/bracelet/bracelet_search_screen.dart** | Scan list, connect by identifier, connection state, 1s refresh when connected, navigation to BraceletScreen with optional initialRealtimeData, device name filter. | **Risky:** Duplicate 1s timer and event handling; similar to dashboard. Large file; could share “connected session” logic with dashboard. |
| **lib/screens/bracelet/bracelet_components.dart** | ProgressCard, _ProgressMetric, _ConcentricRingsPainter, ActivityTabs, LatestActivityCard, RecoveryDataButton, HealthMetricCard, etc. All take `liveData` map. | **Risky:** UI depends on raw map and multiple key variants (step/Step, distance/Distance, etc.). No domain type; brittle if SDK changes. |
| **lib/screens/bracelet/blood_pressure_screen.dart** | BP from liveData or PPG; subscribes to channel; parses BP from realtimeData (ECG/ppg types); same key-flattening and parsing pattern as dashboard. | **Risky:** Duplicate parsing logic (_flattenForBp, _intFrom, _estimateBpFromHeartRate). Should use shared parser/service. |
| **lib/screens/bracelet/sleep_screen.dart** | Requests sleep via channel; UI is mostly static (no stream of type 27 parsed and shown in a dedicated model). | **Needs refactor:** Sleep data request exists; handling of type 27 in BraceletScreen only logs. Sleep screen doesn’t receive parsed sleep data from a shared place. |
| **lib/screens/bracelet/activities_screen.dart** | Activity list and “today” panel; takes optional channel. | **OK;** activity list is static; today could later be fed from device/sync. |
| **ios/Runner/Bracelet/BraceletPlugin.swift** | Registers MethodChannel and EventChannel; delegates all calls to BraceletBleAdapter. | **Good:** Thin plugin; adapter holds logic. |
| **ios/Runner/Bracelet/BraceletBleAdapter.swift** | NewBle + BleSDK_J2208A; scan, connect, startRealtime, requestTotalActivityData, requestSleepData, requestHRVData, startPpgMeasurement; MyBleDelegate; emits scanResult, connectionState, realtimeData (dataType, dicData, dataEnd). | **Good:** Single place for BLE and SDK. **Risky:** Date handling (e.g. startOfToday) is device-local; no UTC. Multiple event sinks (LIFO cancel) is correct for multiple Flutter listeners. |
| **ios/Runner/NewBle.m** | CoreBluetooth central manager; scan, connect, read/write; notifies delegate (BraceletBleAdapter) with raw data. | **Vendor/legacy;** Flutter only talks to BraceletBleAdapter. |
| **android/** | No bracelet plugin. | **Critical gap:** Android users cannot use bracelet feature. |

---

## 5. Architecture Risks

- **Tight coupling:** UI (ProgressCard, _HealthGrid) and screen (BraceletScreen) depend directly on `BraceletChannel` and raw `Map<String, dynamic>` with SDK key names. Changing SDK or adding another data source requires edits across many widgets and the big screen file.
- **Missing abstractions:** No `BraceletRepository` or `HealthMetricsService`; no domain models (e.g. `LiveHealthMetrics`, `TotalActivityDay`). Parsing and merge logic live in the screen and are duplicated (e.g. BP parsing in dashboard and BloodPressureScreen).
- **Direct SDK dependency in UI:** Keys like `step`, `Step`, `distance`, `Distance`, `heartRate`, `HeartRate`, `ECGhighBpValue`, etc. are used in widgets. SDK or firmware changes will break UI unless every call site is updated.
- **Missing repository boundary:** No layer that returns “current steps” or “last known HR” from a single source (device vs cache vs API). Screens and channel are the only boundary.
- **Poor caching:** No cache. Disconnect or app kill loses all data. No “last known” display or offline list.
- **Duplicate logic:** (1) 1s timer and request logic in both BraceletScreen and BraceletSearchScreen. (2) BP parsing and key flattening in BraceletScreen and BloodPressureScreen. (3) Connection-state handling and “clear data on disconnect” in multiple places.
- **Android:** No MethodChannel/EventChannel for bracelet on Android; feature is iOS-only. Duplicate native implementation will be needed (and possibly different SDK shapes).
- **Backend scalability:** No backend for bracelet data today. When you add sync, you’ll need: idempotent writes, batching, and dashboard/summary APIs that don’t recompute from raw events on every request.
- **Production issues at scale:** (1) No structured logging or analytics for “sync failed” or “parse error”. (2) Empty `catch (_) {}` hides failures. (3) No rate limiting or backoff if device sends bursts. (4) Multiple BraceletChannel instances and multiple listeners to same EventChannel can be confusing (iOS adapter supports multiple sinks; Flutter creates new channel per screen). (5) Debug prints (e.g. `[Bracelet SDK]`) should be behind `kDebugMode` in all code paths for release.

---

## 6. Recommended Refactor Plan

### Immediate

- **Gate all bracelet debug prints** behind `kDebugMode` (including `[Bracelet SDK]` and event logs in `_listenRealtime`).
- **Android:** Either implement `BraceletPlugin` + adapter on Android (same channel names) with the same event payload shape, or clearly document/disable bracelet on Android in UI.
- **Error handling:** Replace empty `catch (_) {}` with at least logging (debug) and optionally user-visible “Could not load data” where appropriate. Don’t swallow all PlatformExceptions outside the known “No active stream” case.

### Medium-term

- **Extract parsing and merge:** Move `_parseTotalActivityData`, `_normalizeActivityKeys`, `_parseBloodPressure`, `_flattenForBp`, `_extractHrvFromMap`, `_dataTypeAsInt`, and merge logic out of BraceletScreen into a `BraceletDataParser` or `BraceletRealtimeMapper` (pure functions or a small class). Use it from BraceletScreen and BloodPressureScreen (and any other consumer).
- **Introduce domain models:** Define e.g. `LiveHealthMetrics` (step, distance, calories, heartRate, temperature, hrv, stress, spo2, systolic, diastolic, lastUpdated) and optionally `TotalActivityDay`. Have the parser produce these; UI consumes domain models instead of raw maps.
- **Single “bracelet session” or service:** One place that owns: connection state, 1s polling, subscription to events, and current “live” and “total” state. BraceletScreen and BraceletSearchScreen would depend on this service (e.g. via Provider or a getter) instead of each having its own timer and subscription. Reduces duplicate logic and ensures one source of truth.
- **Last-known cache:** On disconnect or app background, write last `_mergedLiveData()` (or domain equivalent) and `_lastDataUpdateTime` to persistent storage (e.g. secure storage or a small local DB). On launch or reconnect, show “Last updated at …” from cache until new data arrives.

### Long-term (production architecture)

- **Repository layer:** `BraceletRepository` (or `HealthDeviceRepository`) that exposes: `Stream<LiveHealthMetrics>`, `Future<void> requestTotalActivity()`, `Future<void> requestSleep()`, etc. Internally it uses BraceletChannel and the parser; can later add backend sync (upload after each session, or batch).
- **Backend sync API:** Define upload API (e.g. POST /v1/health/sync with idempotency key, or batch of daily summaries). App sends after disconnect or periodically; backend stores by user and date. Dashboard/summary API (e.g. GET /v1/health/summary?from=&to=) for history. Keep “live” data from device; aggregates and history from backend.
- **Offline-first (optional):** Local DB (e.g. SQLite/Drift or Hive) for health events or daily summaries. Sync worker uploads when online; UI reads from local first, then overlays live device stream when connected.
- **Unified native interface:** Consider Pigeon (or codegen) for a single contract (method + event payloads) so iOS and Android implement the same API and Flutter gets typed Dart interfaces. Reduces duplication and key-name drift.

---

## 7. Native SDK Integration (Summary)

- **Mechanism:** **MethodChannel** (`com.24digi/bracelet`) for commands; **EventChannel** (`com.24digi/bracelet/events`) for events. No Pigeon, no FFI.
- **Android:** No integration. No `BraceletPlugin` or equivalent in `android/`. Bracelet code path is iOS-only.
- **iOS:** Starts in `AppDelegate.didInitializeImplicitFlutterEngine` → `BraceletPlugin.register(with: registrar)` → MethodChannel + EventChannel set up. `BraceletBleAdapter` uses `NewBle` (Obj-C CoreBluetooth wrapper) and `BleSDK_J2208A` (vendor SDK). Data path: BLE read → `NewBle` delegate → `BraceletBleAdapter.bleCommunicate(with:data:)` → `sdk?.dataParsing(with: d)` → `emit("realtimeData", payload)` → Flutter `EventChannel.receiveBroadcastStream()`.
- **Flutter ↔ native:** Flutter calls `_methodChannel.invokeMethod('startRealtime', {'type': 2})` etc.; native returns void or state map. Events: native calls `sink(envelope)`; Flutter receives `BraceletEvent.fromMap(map)`.

---

## 8. Backend APIs (Relevant to Bracelet)

- **Existing:** Auth and profile (e.g. `PATCH /profile/health` for health preferences). No bracelet or step/sleep/HR APIs.
- **Request/response models:** Profile uses `ProfileHealthPayload` (e.g. health considerations). No request/response models for device data.
- **API style:** Profile is user-preference/setup (dashboard-summary style for “health goals”), not raw-data. Bracelet data is currently device-only.
- **What should stay where:**  
  - **Flutter:** Device discovery, connection, realtime stream, parsing, merge, UI. Optional: local cache and upload queue.  
  - **Backend (when added):** Receiving synced metrics (idempotent), storing by user/date, serving dashboard/summary and history; optionally aggregation and insights.

---

## 9. Diagrams and Top Files

### Current architecture (text)

```
[User]
   |
   v
[HomeScreen] --> BraceletSearchScreen (scan/connect) --> BraceletScreen (dashboard)
   |                    |                                      |
   |                    | 1s timer                             | 1s timer
   |                    v                                      v
   |              BraceletChannel  <-------------------  BraceletChannel
   |                    |                                      |
   |                    | MethodChannel (scan, connect,        |
   |                    |   startRealtime, requestTotal...)   |
   |                    | EventChannel (scanResult,           |
   |                    |   connectionState, realtimeData)    |
   |                    v                                      v
   |              [iOS only] BraceletPlugin
   |                    |
   |                    v
   |              BraceletBleAdapter --> NewBle (BLE) + BleSDK_J2208A (parse)
   |                    |
   |                    v
   |              Device (BLE)
   |
   v
[ApiClient] --> Backend (auth, profile only; no bracelet API)

BraceletScreen state: _realtimeData, _totalActivityData, _bp*, _dataVersion, _lastDataUpdateTime
  --> _mergedLiveData() --> ProgressCard, _HealthGrid (raw Map<String, dynamic>)
Sub-screens (Heart, Sleep, BP, HRV, Stress, etc.): each uses BraceletChannel and/or liveData map.
No local DB for bracelet data. No backend sync.
```

### Ideal architecture (text)

```
[User]
   |
   v
[HomeScreen] --> BraceletSearchScreen --> BraceletScreen (dashboard)
   |                    |                        |
   |                    v                        v
   |              BraceletService (singleton or injected)
   |                    |                        |
   |                    |  • connectionState     |  • liveMetrics: Stream<LiveHealthMetrics>
   |                    |  • scan / connect     |  • requestTotalActivity(), requestSleep(), ...
   |                    |  • single 1s poll     |  • lastKnown: LiveHealthMetrics? (from cache)
   |                    |  • event subscription|
   |                    v                        v
   |              BraceletRepository (or HealthDeviceRepository)
   |                    |
   |                    |  • BraceletChannel (platform)
   |                    |  • BraceletDataParser (dicData -> LiveHealthMetrics / TotalActivityDay)
   |                    |  • LocalCache (last known + optional history)
   |                    |  • SyncQueue (optional: upload to backend)
   |                    v
   |              [MethodChannel + EventChannel]
   |                    |
   |                    v
   |              iOS BraceletPlugin + Android BraceletPlugin (same contract)
   |                    |
   |                    v
   |              Device (BLE)
   |
   v
[ApiClient] --> Backend
   |              • POST /v1/health/sync (idempotent)
   |              • GET /v1/health/summary?from=&to=
   |
   v
UI: ProgressCard(liveMetrics), HealthMetricCard(liveMetrics) — domain types, not raw maps.
```

### Top 10 files to read first

1. **lib/bracelet/bracelet_channel.dart** – Flutter’s only interface to the device (method + event channel API).
2. **lib/screens/bracelet/bracelet_screen.dart** – Dashboard state, 1s timer, event handling, merge and parsing, UI.
3. **ios/Runner/Bracelet/BraceletPlugin.swift** – Where Flutter meets native (channel registration).
4. **ios/Runner/Bracelet/BraceletBleAdapter.swift** – BLE and SDK usage; where `realtimeData` payload is built.
5. **lib/screens/bracelet/bracelet_search_screen.dart** – Scan, connect, 1s refresh, navigation with initialRealtimeData.
6. **lib/screens/bracelet/bracelet_components.dart** – ProgressCard and HealthMetricCard; how UI consumes `liveData` map.
7. **lib/screens/bracelet/blood_pressure_screen.dart** – Example of duplicate parsing and channel subscription.
8. **lib/main.dart** – Route observer for bracelet; global “No active stream” error suppression.
9. **docs/BRACELET_ACTIVITY_SDK.md** – Data types (24, 25, 26, 27, etc.) and field names from SDK.
10. **ios/Runner/NewBle.m** (and BleSDK_J2208A usage in adapter) – How BLE data reaches the adapter and is parsed.

---

*Document generated from actual codebase inspection. No generic advice only.*
