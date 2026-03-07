# Bracelet Module – Phase 1 Refactor Plan

**Scope:** Architecture, data flow, parsing, abstractions, maintainability only.  
**Constraint:** No UI, widget design, layout, spacing, styling, navigation, or screen structure changes. Preserve current UI exactly.

---

## Goal

- Remove raw `Map<String, dynamic>` handling from the **dashboard path** (BraceletScreen → ProgressCard / _HealthGrid).
- Introduce domain models, a parser layer, BraceletRepository, and BraceletSessionService.
- Keep BraceletChannel unchanged; keep all screens and widgets visually and behaviorally identical.
- Enable safe, incremental steps so the app keeps working after each change.

---

## What Stays Unchanged in UI

| Area | What stays the same |
|------|---------------------|
| **Screens** | BraceletScreen, BraceletSearchScreen, HeartScreen, SleepScreen, BloodPressureScreen, HrvScreen, StressScreen, Spo2Screen, TemperatureScreen, HydrationScreen, ActivitiesScreen, ProgressScreen, GeneralRecoveryScreen — same routes, same navigation flow. |
| **Layout** | Column/Row structure, SizedBox heights and widths, padding, card order, grid layout of _HealthGrid (2 columns, 8 HealthMetricCards). |
| **Widget tree** | BraceletScaffold → KeyedSubtree → Column → ProgressCard, ActivityTabs, LatestActivityCard, RecoveryDataButton, _HealthGrid. No new wrappers (e.g. no Provider above subtree unless needed for wiring only). |
| **Labels and copy** | "HI, USER", "PROGRESS", "CALORIES (Kcal)", "STEPS", "DISTANCE (km)", "Last updated …", "Latest Activity", "SLEEP", "HYDRATION", "HEART RATE", "HRV", "STRESS", "SPO2", "TEMPERATURE", "BLOOD PRESSURE", targets "800", "10,000", "8", units "BPM", "MS", "℃", "mmHg", etc. |
| **Styling** | Colors (AppColors.cyan, labelDim, 0xFF060E16, etc.), font sizes (AppStyles.lemon16, reg12, bold18), borders (SmoothGradientBorder), icons, aspect ratios. |
| **Tabs and buttons** | ActivityTabs (All, Walking, Running, Cycling, Workout), RecoveryDataButton, onTap targets (ProgressScreen, ActivitiesScreen, GeneralRecoveryScreen, HeartScreen, SleepScreen, etc.). |
| **Charts and visuals** | _ConcentricRingsPainter, progress rings, HealthMetricCard layout and trend placeholders. |
| **Navigation** | How user gets to bracelet (Home → Bracelet → Search or Dashboard), pushReplacement to BraceletScreen, push to sub-screens. |
| **BraceletChannel** | Kept as-is; no replacement in Phase 1. |

**Allowed:** Changing where data comes from (e.g. BraceletScreen reads `LiveHealthMetrics?` from a service and passes `liveMetrics?.toDisplayMap()` to existing widgets). Widget APIs may keep accepting `Map<String, dynamic>?` so that `toDisplayMap()` is the only source of that map — no change to widget signatures if we pass the same map shape.

---

## New Folder Structure

```
lib/bracelet/
├── bracelet_channel.dart          # UNCHANGED
├── debug_bracelet_page.dart       # UNCHANGED
├── data/
│   ├── models/
│   │   ├── live_health_metrics.dart   # NEW: domain model for dashboard
│   │   └── total_activity_day.dart    # NEW: optional, for type-25 parsing
│   └── bracelet_data_parser.dart     # NEW: parsing + merge (from bracelet_screen)
├── repository/
│   └── bracelet_repository.dart       # NEW: interface + impl wrapping BraceletChannel
└── service/
    └── bracelet_session_service.dart  # NEW: session state, parsing, 1s poll, exposes LiveHealthMetrics?
```

No new folders under `lib/screens/bracelet/`. Existing files there are only modified to **use** the new layer (BraceletScreen, and optionally BraceletSearchScreen for shared polling later; other screens unchanged in Phase 1).

---

## New Models

### 1. `LiveHealthMetrics` (`lib/bracelet/data/models/live_health_metrics.dart`)

Immutable value type used for the dashboard “live” view. All fields nullable except where noted.

| Field | Type | Description |
|-------|------|-------------|
| `step` | `int?` | Steps (realtime or total, merged). |
| `distance` | `double?` | Distance (km or meters; parser can normalize). |
| `calories` | `double?` | Calories. |
| `heartRate` | `int?` | BPM. |
| `temperature` | `double?` | °C. |
| `hrv` | `int?` | HRV in ms. |
| `stress` | `int?` | 0–100. |
| `spo2` | `int?` | SpO2 %. |
| `systolic` | `int?` | mmHg. |
| `diastolic` | `int?` | mmHg. |
| `lastUpdated` | `DateTime?` | When type 24/25 was last applied. |

**Method:** `Map<String, dynamic> toDisplayMap()`  
Returns a single map with **normalized keys** used by ProgressCard and _HealthGrid: `step`, `distance`, `calories`, `heartRate`, `temperature`, `hrv`, `stress`, `spo2`, `systolic`, `diastolic`. No duplicate keys (e.g. no `Step`/`step`). This preserves existing UI behavior without changing widgets.

**Factory:** `LiveHealthMetrics.fromMergedMap(Map<String, dynamic> m)` (optional helper for tests or legacy path).

### 2. `TotalActivityDay` (`lib/bracelet/data/models/total_activity_day.dart`) — optional in Phase 1

Use if you want the parser to return a typed model for type 25 instead of `Map<String, dynamic>`. Fields: `step`, `distance`, `calories`, `date`, `exerciseMinutes`, `activeMinutes`, `goal`. Parser can still produce `Map<String, dynamic>` for internal merge; this model is for clarity and future use.

---

## Methods to Extract First (from `bracelet_screen.dart`)

Move in this order so parsing is isolated before changing state flow.

| Order | Method(s) | Destination | Notes |
|-------|-----------|-------------|--------|
| 1 | `_dataTypeAsInt`, `_intFrom`, `_toDouble`, `_firstOf` | `BraceletDataParser` (static helpers) | Pure; no dependency on screen state. |
| 2 | `_normalizeActivityKeys`, `_parseTotalActivityData` | `BraceletDataParser` | Pure; input/output maps. |
| 3 | `_flattenForBp`, `_parseBloodPressure` | `BraceletDataParser` | Pure. |
| 4 | `_extractHrvFromMap` | `BraceletDataParser` | Pure. |
| 5 | `_estimateBpFromHeartRate`, `_stressFromHeartRate` | `BraceletDataParser` | Pure. |
| 6 | Merge logic (current `_mergedLiveData()` body) | `BraceletDataParser.mergeLiveData(realtime, total, bpSystolic, bpDiastolic)` → returns `LiveHealthMetrics?` | Input: two maps + two int?; output: `LiveHealthMetrics?`. |
| 7 | `_formatLastUpdated(DateTime t)` | Can stay in BraceletScreen (UI-only) or move to a small `BraceletFormatting` util. | Phase 1: leave in screen. |

**Remain in BraceletScreen (until service is wired):**  
`_listenRealtime`, `applyUpdate` (logic will move to BraceletSessionService), `_clearDeviceData`, `_refreshDataFromDevice`, `_startRealtimeRefreshTimer`, `_startTotalActivityPolling`, `_requestDataSoonIfConnected`, `_verifyConnectionAndClearIfDisconnected`, `_requestTotalActivityOnce`, `_requestHRVOnce`, `_startRealtimeIfConnected`, `_pauseRealtime`, RouteAware lifecycle, `initState`/`dispose`/`build`.  
After service exists: event handling and timer become “listen to service; setState when service notifies”.

---

## BraceletRepository Interface

**File:** `lib/bracelet/repository/bracelet_repository.dart`

Repository **wraps BraceletChannel only**. No parsing, no state. Exists so the session service and (later) other code depend on an abstraction, not on the channel directly.

```dart
/// Abstraction over bracelet device access. Implemented via [BraceletChannel].
abstract class BraceletRepository {
  Stream<BraceletEvent> get events;
  Future<Map<Object?, Object?>> getConnectionState();
  Future<void> scan();
  Future<void> stopScan();
  Future<List<Map<Object?, Object?>>> getRetrievedDevices();
  Future<void> connect(String identifier);
  Future<void> startRealtime(RealtimeType type);
  Future<void> stopRealtime();
  Future<void> requestTotalActivityData();
  Future<void> requestSleepData();
  Future<void> requestHRVData();
  Future<void> startPpgMeasurement();
  Future<void> disconnect();
}
```

**Implementation:** `BraceletRepositoryImpl` (or `BraceletRepository`) with a single field `final BraceletChannel _channel` and each method delegating to `_channel`. No new logic.

---

## BraceletSessionService Design

**File:** `lib/bracelet/service/bracelet_session_service.dart`

**Responsibility:** Own dashboard “session” state and 1s polling; parse events; expose current `LiveHealthMetrics?` and notify listeners so the UI can setState.

**State (private):**

- `Map<String, dynamic>? _realtimeData`
- `Map<String, dynamic>? _totalActivityData`
- `int? _bpSystolic`, `int? _bpDiastolic`
- `DateTime? _lastDataUpdateTime`
- `int _dataVersion` (if needed for keys)
- `StreamSubscription<BraceletEvent>? _subscription`
- `Timer? _refreshTimer`
- `bool _pollingActive`

**Dependencies:**

- `BraceletRepository` (injected or created with `BraceletChannel()` → `BraceletRepositoryImpl`).
- `BraceletDataParser` (static methods or a single instance; no mutable state in parser).

**Public API:**

- `LiveHealthMetrics? get liveMetrics` — computed from merge (parser.mergeLiveData(...)); returns null when nothing to show.
- `int get dataVersion` — for KeyedSubtree key (optional; can derive from liveMetrics hash or keep counter).
- `DateTime? get lastDataUpdateTime` — for “Last updated” text.
- `void start()` — subscribe to `repository.events`, handle connectionState (clear state on disconnect), handle realtimeData (parse with BraceletDataParser, update _realtimeData/_totalActivityData/_bp*, set _lastDataUpdateTime for 24/25), start 1s timer that calls `repository.getConnectionState()` then `repository.startRealtime(2)` + `repository.requestTotalActivityData()`.
- `void stop()` — cancel subscription, cancel timer, call `repository.stopRealtime()`.
- `void setInitialRealtimeData(Map<String, dynamic>? data)` — for BraceletScreen’s `initialRealtimeData` (set _realtimeData once so first frame has data when navigating from search).
- **Notification:** Either `ValueNotifier<LiveHealthMetrics?> liveMetricsNotifier` or `Stream<LiveHealthMetrics?> get liveMetricsStream` (single-subscription or broadcast). BraceletScreen will listen and call setState. Prefer **ValueNotifier** for simplicity and single listener (the screen).

**Event handling (inside service):**

- Same logic as current `_listenRealtime` + `applyUpdate`: map `dicData` to `Map<String, dynamic>`, `dataType` dispatch (25 → parse total; 38/56 → merge HRV into _realtimeData; 24/default → merge into _realtimeData; BP from any type via parser). Then increment _dataVersion, update _lastDataUpdateTime for 24/25.
- After each update, set `liveMetricsNotifier.value = mergeLiveData(...)` so the screen’s listener runs.

**1s timer:**

- Same as current `_refreshDataFromDevice`: if connected, call `startRealtime(2)` and `requestTotalActivityData()`; then if `lastDataUpdateTime != null`, notify so “Last updated Xs ago” can refresh (screen’s listener will setState).

**No UI:** Service does not depend on Flutter (no `BuildContext`, no `setState`). Optional: `kDebugMode` logs only (e.g. “step changed”, “TotalActivityData (25)”) so debug behavior is preserved.

---

## File-by-File Migration Order

| Step | File(s) | Action |
|------|---------|--------|
| 1 | `lib/bracelet/data/models/live_health_metrics.dart` | **Create.** Define class + `toDisplayMap()`. |
| 2 | `lib/bracelet/data/bracelet_data_parser.dart` | **Create.** Move static parsing/merge from bracelet_screen (methods 1–6). Parser returns `LiveHealthMetrics?` from merge; keep internal use of maps for realtime/total. Add `parseRealtimeEvent(dicMap, dataType)` that returns a delta or updates passed-in maps (or keep parsing in service with parser helpers). Simplest: parser has `parseTotalActivityData`, `parseBloodPressure`, `extractHrvFromMap`, `mergeLiveData(realtime, total, bpSys, bpDia)` → `LiveHealthMetrics?`. |
| 3 | `lib/screens/bracelet/bracelet_screen.dart` | **Change.** Replace in-screen parsing/merge with calls to `BraceletDataParser`. Keep state (_realtimeData, _totalActivityData, _bp*, _lastDataUpdateTime, _dataVersion) and _listenRealtime/applyUpdate/timer in place. So: import parser, call `BraceletDataParser.parseTotalActivityData(dic)`, `BraceletDataParser.mergeLiveData(...)`, etc. Build: `liveData = _mergedLiveData()` as now but implemented using parser; then `liveMetrics = LiveHealthMetrics.fromMergedMap(liveData!)` (or parser returns LiveHealthMetrics directly). Pass `liveMetrics?.toDisplayMap()` to ProgressCard and _HealthGrid. **Result:** Dashboard path uses LiveHealthMetrics internally; UI still receives same map from `toDisplayMap()`. No visual change. |
| 4 | `lib/bracelet/repository/bracelet_repository.dart` | **Create.** Interface + BraceletRepositoryImpl(BraceletChannel). |
| 5 | `lib/bracelet/service/bracelet_session_service.dart` | **Create.** Implement as above; use repository and parser; expose ValueNotifier<LiveHealthMetrics?>. |
| 6 | `lib/screens/bracelet/bracelet_screen.dart` | **Change.** Instantiate BraceletSessionService (with repository impl and channel). In initState: call `sessionService.setInitialRealtimeData(widget.initialRealtimeData)`, `sessionService.start()`, add listener to `sessionService.liveMetricsNotifier` that calls setState. Remove _listenRealtime subscription and 1s timer from screen (service owns them). Remove _realtimeData, _totalActivityData, _bpSystolic, _bpDiastolic, _lastDataUpdateTime, _dataVersion from screen state; read from `sessionService.liveMetrics`, `sessionService.lastDataUpdateTime`, `sessionService.dataVersion`. build: `liveMetrics = sessionService.liveMetrics`, pass `liveMetrics?.toDisplayMap()` to ProgressCard/_HealthGrid, `_formatLastUpdated(sessionService.lastDataUpdateTime!)` when non-null. didPop: call `sessionService.stop()`. **Result:** Screen is thin; all logic in service + parser. |
| 7 | (Optional) | If BraceletSearchScreen should share the same session (e.g. one service instance for “bracelet tab”): inject or provide BraceletSessionService from a parent (e.g. home or bracelet tab). Phase 1 can leave search screen as-is and keep a separate channel + timer there; document as “Phase 2: unify session”. |

**Do not change in Phase 1:**  
`bracelet_components.dart` (ProgressCard, _HealthGrid, etc.) — still accept `Map<String, dynamic>? liveData`; they receive that map from `liveMetrics?.toDisplayMap()`.  
`bracelet_search_screen.dart` — optional: only ensure it still passes `initialRealtimeData` to BraceletScreen; no refactor required.  
`blood_pressure_screen.dart`, `heart_screen.dart`, `sleep_screen.dart`, etc. — unchanged.  
`bracelet_channel.dart`, `debug_bracelet_page.dart` — unchanged.

---

## Safe Incremental Migration Plan

### Step A: Add models and parser (no behavior change)

1. Add `lib/bracelet/data/models/live_health_metrics.dart` with `LiveHealthMetrics` and `toDisplayMap()`.
2. Add `lib/bracelet/data/bracelet_data_parser.dart` with all static methods copied from bracelet_screen (names: `dataTypeAsInt`, `intFrom`, `toDouble`, `firstOf`, `normalizeActivityKeys`, `parseTotalActivityData`, `flattenForBp`, `parseBloodPressure`, `extractHrvFromMap`, `estimateBpFromHeartRate`, `stressFromHeartRate`, `mergeLiveData` returning `LiveHealthMetrics?`).
3. In `bracelet_screen.dart`: replace each `_parseTotalActivityData` / `_normalizeActivityKeys` / etc. with `BraceletDataParser.parseTotalActivityData` / … Keep `_mergedLiveData()` but implement it by calling `BraceletDataParser.mergeLiveData(_realtimeData, _totalActivityData, _bpSystolic, _bpDiastolic)` and returning `result?.toDisplayMap()`. So the screen still has the same state variables and the same merge output type (map) for the UI. **Verify:** Run app; dashboard shows same numbers, “Last updated” works, no regression.
4. **Checkpoint:** Tests or manual test: connect bracelet, open dashboard, confirm steps/HR/calories/distance/BP/temp/stress match previous behavior.

### Step B: Introduce repository (no behavior change)

5. Add `lib/bracelet/repository/bracelet_repository.dart` with interface and `BraceletRepositoryImpl(BraceletChannel)`.
6. In BraceletScreen: create `final _repo = BraceletRepositoryImpl(BraceletChannel());` and replace every `_channel.*` call with `_repo.*`. **Verify:** Same behavior.

### Step C: Introduce session service and thin the screen

7. Add `lib/bracelet/service/bracelet_session_service.dart` with state (realtime, total, bp, lastUpdated, dataVersion), ValueNotifier<LiveHealthMetrics?>, start()/stop()/setInitialRealtimeData(), and event/timer logic moved from BraceletScreen.
8. BraceletScreen: create service with `BraceletSessionService(BraceletRepositoryImpl(BraceletChannel()))`. initState: setInitialRealtimeData(widget.initialRealtimeData), service.start(), listen to liveMetricsNotifier → setState(() {}). Remove _subscription, _realtimeData, _totalActivityData, _bpSystolic, _bpDiastolic, _lastDataUpdateTime, _dataVersion, _listenRealtime, _clearDeviceData, _refreshDataFromDevice, _startRealtimeRefreshTimer, _startTotalActivityPolling, _requestDataSoonIfConnected, _requestTotalActivityOnce, _requestHRVOnce, _startRealtimeIfConnected, _pauseRealtime (logic lives in service). build: liveMetrics = service.liveMetrics, lastDataUpdateTime = service.lastDataUpdateTime, dataVersion = service.dataVersion; pass liveMetrics?.toDisplayMap(), _formatLastUpdated(service.lastDataUpdateTime!). didPop: service.stop(). **Verify:** Full flow: search → connect → dashboard → steps update, “Last updated” updates, navigate away and back, disconnect clears data.
9. **Checkpoint:** Full regression: all sub-screens (Heart, Sleep, BP, etc.) still open and work; navigation unchanged; UI pixel-identical.

### Step D: Cleanup

10. Remove any dead code from bracelet_screen (old merge/parse methods already moved). Ensure all debug prints in parser/service are behind `kDebugMode`.
11. (Optional) Add `TotalActivityDay` and have parser return it from parseTotalActivityData for clarity; merge can still take map from it or keep using map internally for Phase 1.

---

## Risks and Rollback Plan

| Risk | Mitigation | Rollback |
|------|------------|----------|
| Parser output differs from current merge (e.g. wrong step/HR) | Implement `mergeLiveData` and `LiveHealthMetrics.fromMergedMap` with identical logic to current `_mergedLiveData()`; compare in debug: merged map vs liveMetrics.toDisplayMap(). | Revert parser/screen to use in-screen merge and maps only; keep models in repo but unused. |
| Service loses events or timer (no updates on dashboard) | Service must subscribe to repository.events in start() and start timer; mirror current _listenRealtime and _refreshDataFromDevice exactly. | Revert to Step B: screen owns subscription and timer again; service not used. |
| Multiple BraceletChannel instances (e.g. service + search screen) | Phase 1: allow it; search and dashboard each can have their own channel. Unify in Phase 2. | N/A. |
| Performance (ValueNotifier every second) | Single setState per update; same as today. If needed, throttle “Last updated” tick to once per second. | No change needed. |
| Sub-screens (BloodPressureScreen, etc.) still use BraceletChannel directly | By design in Phase 1; they keep using channel. Only dashboard path uses repository/service. | No rollback; no change to those screens. |

**Rollback strategy:** Each step is a separate commit. If Step C breaks the dashboard: revert the “Introduce session service” commit and keep Step A + B (parser + repository only; screen still owns state and subscription).

---

## Summary

- **Goal:** Domain model + parser + repository + session service; dashboard path uses `LiveHealthMetrics` and `toDisplayMap()`; UI unchanged.
- **Unchanged:** All screens, layout, labels, styling, navigation, BraceletChannel, and widget tree. ProgressCard and _HealthGrid still receive `Map<String, dynamic>?` (from `toDisplayMap()`).
- **New:** `lib/bracelet/data/models/live_health_metrics.dart`, `lib/bracelet/data/bracelet_data_parser.dart`, `lib/bracelet/repository/bracelet_repository.dart`, `lib/bracelet/service/bracelet_session_service.dart`.
- **Migration:** A (models + parser, screen calls parser) → B (repository wraps channel, screen uses repo) → C (service owns state and events, screen listens) → D (cleanup). Each step keeps the app working and allows revert by commit.

---

## Step A Completed: What Changed

### New files

- **`lib/bracelet/data/models/live_health_metrics.dart`** — `LiveHealthMetrics` with `step`, `distance`, `calories`, `heartRate`, `temperature`, `hrv`, `stress`, `spo2`, `systolic`, `diastolic`, `lastUpdated` and `toDisplayMap()`.
- **`lib/bracelet/data/bracelet_data_parser.dart`** — Static parser: `dataTypeAsInt`, `intFrom`, `toDouble`, `firstOf`, `normalizeActivityKeys`, `parseTotalActivityData`, `flattenForBp`, `parseBloodPressure`, `extractHrvFromMap`, `estimateBpFromHeartRate`, `stressFromHeartRate`, `mergeLiveData(...)` → `LiveHealthMetrics?`.

### Methods that remain in `bracelet_screen.dart` after Step A

- **Lifecycle / state:** `initState`, `didChangeDependencies`, `didPush`, `didPopNext`, `didPop`, `dispose`.
- **Connection / polling:** `_requestDataSoonIfConnected`, `_verifyConnectionAndClearIfDisconnected`, `_requestTotalActivityOnce`, `_requestHRVOnce`, `_startRealtimeIfConnected`, `_pauseRealtime`, `_refreshDataFromDevice`, `_startRealtimeRefreshTimer`, `_startTotalActivityPolling`, `_clearDeviceData`.
- **Event handling:** `_listenRealtime` (including `applyUpdate` and the event subscription).
- **UI helper:** `_formatLastUpdated`.
- **Merge (delegates to parser):** `_mergedLiveData()` — now calls `BraceletDataParser.mergeLiveData(...)` and returns `result?.toDisplayMap()`.
- **Build:** `build` (unchanged structure; still passes `liveData` to ProgressCard and _HealthGrid).

### Why Step A is behavior-safe

1. **Same logic:** All parsing and merge logic was moved as-is into `BraceletDataParser`; only the call site changed (screen → parser).
2. **Same output shape:** `mergeLiveData` returns `LiveHealthMetrics?`; `toDisplayMap()` returns a map with the same normalized keys (`step`, `distance`, `calories`, `heartRate`, etc.) that ProgressCard and _HealthGrid already use. No widget signature or key change.
3. **State and flow unchanged:** BraceletScreen still owns `_realtimeData`, `_totalActivityData`, `_bpSystolic`, `_bpDiastolic`, `_dataVersion`, `_lastDataUpdateTime`, the event subscription, and the 1s timer. Realtime updates and setState flow exactly as before.
4. **No new dependencies:** No repository, service, or cache; only a new data layer used by the existing screen.

### How to verify UI and realtime behavior unchanged

1. **Connect bracelet** → open dashboard. Progress card shows steps, calories, distance; health grid shows HR, HRV, stress, SpO2, temp, BP. Values match pre–Step A.
2. **Walk / move** so device sends type 24. Steps (and distance/calories) update within a few seconds; "Last updated Xs ago" advances.
3. **Navigate away and back** (e.g. to Heart then back). Dashboard still shows last values; 1s polling continues.
4. **Disconnect** (or turn off bracelet). Data clears; progress and grid show placeholders (e.g. -- --, -1).
5. **No UI changes:** Same labels, layout, colors, tabs, navigation. No new or removed widgets.
