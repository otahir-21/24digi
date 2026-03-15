# Audit: Zero/Invalid Readings, Sleep Reliability, Auto Activity Detection

Audit date: 2025-03. Evidence is file-level with line references.

---

## 1. Zero/Invalid Readings When Bracelet Not Worn or Removed

### 1.1 Status: **Partially implemented**

### 1.2 Evidence

| Area | File | Evidence |
|------|------|----------|
| **Dashboard display** | `lib/screens/bracelet/bracelet_screen.dart` | Lines 819–826: When value is null, dashboard uses **literal `"-1"`** for HR, SpO2, temp, BP, stress and **`"N/A"`** for HRV. No `"--"` or `"No reading"`. |
| **HealthMetricCard** | `lib/screens/bracelet/bracelet_components.dart` | Lines 623–677: Renders `value` as-is. So **`"-1"` and `"N/A"` are shown literally**, not as `"--"` or “No reading”. |
| **SpO2 invalid filter** | `lib/screens/bracelet/bracelet_screen.dart` | Lines 431–434: SpO2 stored only when `spo2Val != null && spo2Val > 0 && spo2Val <= 100`. **Zero/invalid not stored.** |
| **SpO2 screen** | `lib/screens/bracelet/spo2_screen.dart` | Lines 102–103, 254–256: Rejects `spo2 < 1 \|\| spo2 > 100`. UI shows **`"--"`** or **`"No SpO2 reading received"`** when no value. **Correct.** |
| **Heart screen** | `lib/screens/bracelet/heart_screen.dart` | Lines 63–64, 72–74: Only accepts HR in **30–250**. On disconnect (45–46): **`_currentBpm = null`**. **Correct.** |
| **HRV screen** | `lib/screens/bracelet/hrv_screen.dart` | Lines 68–74: On disconnect clears **`_hrvCurrent`, _hrvHighest, _hrvLowest, _hrvSamples**. **Correct.** |
| **Temperature screen** | `lib/screens/bracelet/temperature_screen.dart` | Lines 45–50: On disconnect sets **`_currentTemp = null`**, min/max cleared. Lines 288–291: Shows **`"--"`** when null. **Correct.** |
| **Stale after disconnect (dashboard)** | `lib/screens/bracelet/bracelet_screen.dart` | Lines 312–326: **`_clearDeviceData()`** sets **`_realtimeData = null`**, `_totalActivityData = null`, `_latestActivityData = null`, BP null, clears history. **Stale cleared on dashboard.** |
| **Stale HRV after disconnect** | `lib/bracelet/bracelet_channel.dart` | Line 45: **`static int? lastKnownHrv`** is **never cleared** on disconnect. Dashboard (666–667) injects `BraceletChannel.lastKnownHrv` into liveData when `liveData['hrv'] == null`. **So HRV can remain visible after bracelet removal.** |
| **Zero as valid** | `lib/bracelet/data/models/live_health_metrics.dart` | Lines 36–42: **`toDisplayMap()`** uses `if (heartRate != null)` etc. So **0 is included** and would be shown as `"0"` if SDK sends 0. No “invalid zero” filter for HR/HRV/temp in merge or display. |

### 1.3 Fixes still required

1. **Dashboard placeholders**  
   - **File:** `lib/screens/bracelet/bracelet_screen.dart` (e.g. 819–826).  
   - **Change:** For missing/invalid HR, SpO2, temp, BP, stress use **`"--"`** (or “No reading”) instead of **`"-1"`**. Keep HRV as `"N/A"` or switch to `"--"` for consistency.

2. **HealthMetricCard**  
   - **File:** `lib/screens/bracelet/bracelet_components.dart`.  
   - **Option A:** In `_HealthGrid` pass `"--"` (or “No reading”) for null/invalid so card never receives `"-1"`.  
   - **Option B:** In `HealthMetricCard` treat value `"-1"` or `"N/A"` as no reading and display `"--"` (or “No reading”).

3. **Clear HRV on disconnect**  
   - **File:** `lib/screens/bracelet/bracelet_screen.dart` inside **`_clearDeviceData()`** (312–326).  
   - **Change:** Add **`BraceletChannel.lastKnownHrv = null;`** so dashboard and recovery do not show stale HRV after bracelet removal.

4. **Treat zero as invalid for display**  
   - **File:** `lib/screens/bracelet/bracelet_screen.dart` (_HealthGrid).  
   - **Change:** When building `hrStr`, `spo2Str`, `tempStr`, etc., treat **0** as invalid (e.g. same as null and show `"--"`), for HR also reject 0 or out-of-range (e.g. &lt; 30 or &gt; 250) so “0 BPM” is not shown as real.

### 1.4 Risky assumptions

- **BraceletChannel.lastKnownHrv** is global and persists across disconnects; recovery and dashboard can show HRV from a previous session.
- **`"-1"`** is used as a sentinel; UI does not convert it to a proper “no reading” label.

---

## 2. Sleep Reliability and Sub-Readings

### 2.1 Status: **Partially implemented**

### 2.2 Evidence

| Area | File | Evidence |
|------|------|----------|
| **Device-specific storage** | `lib/bracelet/sleep_storage.dart` | Single **`_lastSleepData`** (line 7), no device ID or key. **`updateFromMap`** (9–11) overwrites with one map. **Sleep is not device-specific;** last device to send type 27 wins. |
| **Dedupe** | `lib/bracelet/data/bracelet_data_parser.dart` | **`_sleepRecordKey`** (252–264): key = startTime + totalSleepTime + unit + arraySleepQuality. **`parseSleepDataWithDedup`** (267–327): dedupes by this key, merges same-day (gap ≤ 45 min), picks latest-date first, longest valid. **Dedupe is by record content, not by device.** |
| **Storage key** | `lib/bracelet/sleep_storage.dart` | No key at all; one global map. No per-device or per-user key. |
| **Parser merge** | `lib/bracelet/data/bracelet_data_parser.dart` | **`_mergeIntoNightlySessions`**: merge by **same night** (evening = that day, early morning = previous day), gap ≤ 90 min, so one night 23:00–07:30 is one session. **`_selectBestMergedSession`**: pick latest night, then session with largest totalSleepMinutes. **Fixes vendor 7h30 vs app 4h58 when device sent two segments across midnight.** |
| **Cache** | `lib/screens/bracelet/bracelet_screen.dart` | **`_sleepRecordsBuffer`** (e.g. 508–512): batches type 27, then **`parseSleepDataWithDedup`** → **`SleepStorage.updateFromMap(map)`** (554). Single in-memory buffer; no device-scoped cache. |
| **Sub-readings source** | `lib/bracelet/data/bracelet_data_parser.dart` | **`_parseOneSleepRecord`** (526–599): **deep/light/REM/awake** from **`arraySleepQuality`** only. **`_classifySleepSample`** (495–523): unit 1 → 1=deep, 2=light, 3=REM, else awake; unit 5 → value/5, 0..2 deep, &gt;2..8 light, &gt;8..20 REM, else awake. **Sub-readings come only from SDK arraySleepQuality and mapping; no dummy.** |
| **Totals** | `lib/bracelet/data/bracelet_data_parser.dart` | Line 570: **`totalSleepMinutes = deepMinutes + lightMinutes + remMinutes`**. Line 577: **`isReliable = totalSleepMinutes >= 15`**. **`_filterValidFragments`** (336–338): keeps only **≥ 15 min** and **`isReliable`**. **Totals and stages are from real SDK data; no duplication in parser.** |

### 2.3 Fixes still required

1. **Device-specific sleep**  
   - **File:** `lib/bracelet/sleep_storage.dart`.  
   - **Change:** Store sleep keyed by device ID (or connection identifier) if available from channel/platform. E.g. `Map<String, Map<String, dynamic>> _lastSleepDataByDevice` and **`updateFromMap(deviceId, data)`** / **`lastSleepData(deviceId)`**. When device ID is not available, keep current single-map behavior and document that sleep is “last connected device” only.

2. **Optional: clear sleep on disconnect**  
   - If desired: when bracelet disconnects, either clear **SleepStorage** for that device or mark it stale so UI does not show “last night” from a different device. Depends on product choice (show last known vs hide when disconnected).

### 2.4 What is already correct

- Dedupe and merge rules are sound; sub-readings (deep/light/REM/awake) come only from SDK **arraySleepQuality** and documented mapping; totals are not duplicated or dummy in the parser.

### 2.5 Risky assumptions

- **Single device or “last writer wins”:** Sleep is not keyed by device; switching devices overwrites **SleepStorage** with the latest type 27 response.
- **No persistence:** Sleep is in-memory only; app restart loses it unless something else persists it.

---

## 3. Auto Activity Detection and “In Progress”

### 3.1 Status: **Partially implemented** (false “in progress” fixed; no SDK “live workout” state)

### 3.2 Evidence

| Area | File | Evidence |
|------|------|----------|
| **Type 30 (activity mode)** | `lib/bracelet/data/bracelet_data_parser.dart` | **`parseActivityModeDataLatest`** (132–174), **`parseActivityModeDataTodayList`** (178+): type 30 = **completed** sessions (Date, ActivityMode, ActiveMinutes, Step, etc.). **No “in progress” or “active session” field** in parsed data; SDK sends completed records. |
| **False “walking in progress”** | `lib/screens/bracelet/activities_screen.dart` | **Fixed.** **`_currentActivityFromLiveData`** (380–384) now **always returns null**. No longer uses type 24 (steps/exerciseMinutes) to show “In progress”. **Today’s Activities** list only shows **ActivityStorage** (type 30) sessions. |
| **Latest Activity card** | `lib/screens/bracelet/bracelet_screen.dart` | Line 673: **`latestActivityToShow = _latestActivityData`** only (no type 24 fallback). **`_buildCurrentActivityFromRealtime`** not used for card. **Correct.** |
| **Activity “state” (ActivitiesInfoScreen)** | `lib/screens/bracelet/activities_info_screen.dart` | **`_activityState`** (39): `'idle' \| 'walking' \| 'running'`. Set from **type 24** cadence + HR (209–220): cadence ≥ 140 and HR ≥ 100 → running; 80 ≤ cadence ≤ 130 and 80 ≤ HR ≤ 115 → walking; cadence &lt; 60 → idle. **This is app-derived from live steps/HR, not SDK “workout started/finished”**. Used for the **activity detail** screen (e.g. Running/Walking), not for dashboard “in progress”. **No bug** per “in progress” rules; optionally document as “estimated state” not “workout session”. |
| **Started / in progress / finished** | N/A | **SDK (type 30)** only provides **completed** sessions. There is **no code path** that receives a “workout started” or “workout in progress” from the SDK. **“In progress” is therefore never shown from live workout state** until the SDK (or another channel) provides it. |

### 3.3 Fixes still required

1. **None for “in progress” logic.**  
   - Type 24 and last activity history are no longer used for “in progress”. Latest Activity and Today’s Activities use only type 30.

2. **Optional / documentation**  
   - **File:** e.g. `lib/screens/bracelet/activities_info_screen.dart` or a short doc.  
   - **Change:** Clarify that **`_activityState`** (walking/running/idle) is **estimated from live cadence/HR (type 24)**, not from SDK “workout started/finished”. If the SDK later exposes “workout in progress” (e.g. a flag or separate type), add a code path that sets “in progress” only from that and keep type 24 for display only, not for “in progress”.

### 3.4 Risky assumptions

- **Type 30 = history only:** All activity-mode data is treated as completed sessions; there is no handling for an “active session” or “current workout” from the SDK.
- **ActivitiesInfoScreen state:** Walking/running/idle is heuristic (cadence + HR); it can be wrong when the user is sitting if type 24 still reports non-zero steps/HR.

---

## Summary Table

| Item | Status | Main files | Fixes required |
|------|--------|------------|----------------|
| **1. Zero/invalid readings** | Partially implemented | bracelet_screen.dart (819–826), bracelet_components.dart (HealthMetricCard), bracelet_channel.dart (lastKnownHrv) | Use "--" for no reading; clear lastKnownHrv on disconnect; treat 0 as invalid for display |
| **2. Sleep reliability** | Partially implemented | sleep_storage.dart (no device key), bracelet_data_parser.dart (dedupe/merge/stages) | Add device-specific storage key if device ID available; optional clear-on-disconnect |
| **3. Auto activity / “in progress”** | Partially implemented (false “in progress” fixed) | activities_screen.dart, bracelet_screen.dart, activities_info_screen.dart | None for “in progress”; optional doc for cadence-based state |
