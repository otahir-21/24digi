# Recovery Score – Integration Guide

Recovery is **not** from the SDK; it is computed in-app. See `docs/SDK_RECOVERY_READINESS_FINDINGS.md`.

---

## 1. What was added

| File | Purpose |
|------|---------|
| **lib/bracelet/recovery/recovery_score_calculator.dart** | `RecoveryInput`, `RecoveryResult`, `RecoveryScoreCalculator.calculate()`. Constants for sleep target, HRV/HR baselines, stress threshold, overreaching. |
| **lib/bracelet/recovery/recovery_storage.dart** | `RecoverySnapshot`, `RecoveryStorage` – save/get by date, `last7Days` / `last7DaysScores` for trend charts. |

---

## 2. Files to update (exact list)

### 2.0 GeneralRecoveryScreen (implemented)

- **lib/screens/bracelet/general_recovery_screen.dart**
  - On build: builds `RecoveryInput` from `SleepStorage.totalSleepMinutes`, `BraceletChannel.lastKnownHrv`, `WeeklyDataStorage.last7DaysSteps[5]` (yesterday). Resting HR and stress left null until available.
  - Calls `RecoveryScoreCalculator.calculate(input)` and saves today's snapshot to `RecoveryStorage`.
  - **Status pill:** Shows "RECOVERY: {status} ({score})" with color by status (Excellent=cyan, Good=green, Fair=amber, Low=red).
  - **Reasons:** `_RecoveryReasons` shows chips for each reason below the pill.
  - **Ready line:** "Ready for High Intensity" for Good/Excellent; "Moderate Intensity Recommended" otherwise. `_ReadyIndicator` shows 1–4 active bars by status.
  - **Weekly Trend:** `_WeeklyTrendCard` uses `RecoveryStorage.last7DaysScores` for the line chart; day labels from last 7 days. Shows "Avg X" or "±X% VS Last Week" when applicable.

### 2.1 Build recovery input and call calculator (optional: dashboard)

**Option A – From dashboard (BraceletScreen)**  
When you have live data + sleep + weekly steps, compute recovery and optionally save a snapshot.

- **lib/screens/bracelet/bracelet_screen.dart**
  - Import: `import '../../bracelet/recovery/recovery_score_calculator.dart';` and `recovery_storage.dart`.
  - In the same place you use `_mergedLiveData()` (or in a timer/callback after data is updated):
    - Build `RecoveryInput`:
      - `totalSleepMinutes`: `SleepStorage.totalSleepMinutes`
      - `hrv`: `BraceletChannel.lastKnownHrv` or `liveData['hrv']`
      - `restingHeartRate`: `liveData['heartRate']` (or a dedicated resting HR if you add it)
      - `stress`: `liveData['stress']`
      - `yesterdaySteps`: `WeeklyDataStorage.last7DaysSteps.length >= 6 ? WeeklyDataStorage.last7DaysSteps[5] : null`
      - `hrvHistoryLast7Days` / `restingHeartRateHistoryLast7Days`: leave null until you have 7-day HRV/HR history (see below).
    - Call `RecoveryResult result = RecoveryScoreCalculator.calculate(input);`
    - Optionally: `RecoveryStorage.save(RecoverySnapshot(date: DateTime.now(), score: result.score, status: result.status, reasons: result.reasons, recordedAt: DateTime.now()));` (e.g. once per day in the morning).

**Option B – From GeneralRecoveryScreen**  
Compute recovery when the user opens the Recovery screen.

- **lib/screens/bracelet/general_recovery_screen.dart**
  - Convert to `StatefulWidget` or use a provider/state that holds `RecoveryResult?`.
  - In `initState` or when building: read `SleepStorage.totalSleepMinutes`, `BraceletChannel.lastKnownHrv`, `WeeklyDataStorage.last7DaysSteps`, and live data (e.g. from a passed-in `liveData` map or provider).
  - Build `RecoveryInput` as above, call `RecoveryScoreCalculator.calculate(input)`.
  - Replace the hardcoded “REGENERATION STATUS: OPTIMAL” and “Ready for High Intensity” with `result.status` and a score gauge (e.g. circular 0–100) and `result.reasons` as a list of chips or text.

### 2.2 Show score and status in GeneralRecoveryScreen

- **lib/screens/bracelet/general_recovery_screen.dart**
  - **Status pill:** Use `result.status` (Low / Fair / Good / Excellent) and optionally `result.score` (e.g. “RECOVERY: GOOD (72)”).
  - **Reasons:** Map `result.reasons` to a row of chips or a column of short lines below the score.
  - **Trend chart:** Use `RecoveryStorage.last7DaysScores` (and optionally `RecoveryStorage.last7Days`) to drive a small bar or line chart (e.g. in `_WeeklyTrendCard`).

### 2.3 (Optional) 7-day HRV and resting HR baselines

The calculator uses **last 7 days** of HRV and resting HR for baseline when provided. Right now the app does not store per-day HRV or resting HR.

- **Option 1 – In-memory:** Add a small store (e.g. `lib/bracelet/recovery/baseline_storage.dart`) with:
  - `List<int> last7DaysHrv` and `List<int> last7DaysRestingHr` (by date key, same pattern as `WeeklyDataStorage`).
  - Update when you have a “daily” HRV value (e.g. from HRV screen or first morning HRV) and a resting HR (e.g. minimum HR of the day or morning HR).
- **Option 2 – Reuse WeeklyDataStorage:** If you later add `last7DaysHrv` and `last7DaysRestingHr` to `WeeklyDataStorage` (or another existing daily store), pass them into `RecoveryInput.hrvHistoryLast7Days` and `restingHeartRateHistoryLast7Days`.

Until then, the calculator uses **default baselines** (`defaultHrvBaselineMs`, `defaultRestingHrBaseline`) so recovery still works without 7-day history.

### 2.4 RecoveryDataButton (dashboard)

- **lib/screens/bracelet/bracelet_components.dart** (or wherever `RecoveryDataButton` lives)
  - You can pass a `RecoveryResult?` or `int? score` into `RecoveryDataButton` and show a small badge (e.g. “72 Good”) so the dashboard shows today’s recovery at a glance.

---

## 3. Where to store daily recovery snapshots (trend charts)

- **Current implementation:** **In-memory** in `RecoveryStorage` (`_byDate` map, last 30 days). Good for a quick trend on the Recovery screen; lost on app restart.
- **For persistence:**  
  - **shared_preferences:** Serialize `RecoveryStorage.last7Days` (or last 30) to JSON and save on each `RecoveryStorage.save()`; on startup, load and re-apply to `RecoveryStorage` (you’d add a `RecoveryStorage.loadFromPrefs()` and call it from app init).  
  - **Local DB (e.g. sqflite):** One table `recovery_snapshots (date TEXT PRIMARY KEY, score INT, status TEXT, reasons TEXT, recorded_at TEXT)`. Save on `RecoveryStorage.save()`, and provide `RecoveryStorage.last7Days` by querying the DB.  
  - **Backend:** If you have a user health API, POST a daily recovery snapshot and fetch last 7/30 for the trend chart.

Recommendation: start with in-memory `RecoveryStorage` and add `shared_preferences` (or your existing local storage) when you want the trend to survive restarts.

---

## 4. Formula summary (from calculator)

- **Start at 100.**  
- **Sleep:** Under 7 h → penalty (per 30 min short, capped). Over 9 h → small penalty.  
- **HRV:** Above 7-day baseline (or default) → bonus; below → penalty.  
- **Resting HR:** Above 7-day baseline (or default) → penalty.  
- **Stress:** Above 70 → penalty.  
- **Overreaching:** Yesterday steps high and sleep short → extra penalty.  
- **Score** clamped 0–100. **Status:** 0–25 Low, 26–50 Fair, 51–75 Good, 76–100 Excellent.

All thresholds and caps are constants at the top of `recovery_score_calculator.dart` for easy tuning.
