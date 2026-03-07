# Bracelet Module: Dummy / Hardcoded / Static Data Audit

**Scope:** All screens under `lib/screens/bracelet/`. Audit only — no code changes.

---

## SCREEN: bracelet_screen.dart

**STATUS:** Partially live

**DUMMY ITEMS:**
- **Line 467:** `'HI, USER'` — hardcoded greeting; replace with user name from auth/profile when available.
- **_HealthGrid (lines 598–618):** SLEEP card — `value: '-1'`, `unit: 'Deep'`, `trend: '-1'`; should come from device/backend sleep data or show placeholder only when no data.
- **_HealthGrid (lines 610–618):** HYDRATION card — `value: '-1'`, `unit: '%'`, `trend: '-1'`; should come from device or hydration feature.
- **_HealthGrid (lines 621–624, 632–635, 641–644, 651–654, 661–664, 671–674):** All cards use `trend: '-1'`; replace with real trend when available.
- **ProgressCard / _HealthGrid:** Values themselves come from `liveData`; only SLEEP and HYDRATION cards are fully dummy (no liveData path).

**LIVE ITEMS:**
- ProgressCard: steps, calories, distance, goals (800, 10000, 8) are hardcoded in **bracelet_components.dart** (see below); values come from `liveData`.
- _HealthGrid: HEART RATE, HRV, STRESS, SPO2, TEMPERATURE, BLOOD PRESSURE use `liveData` (hrStr, hrvStr, stressStr, spo2Str, tempStr, bpStr); fallback `-1` when null.
- Last updated time, event handling, merged live data from parser.

---

## SCREEN: bracelet_components.dart

**STATUS:** Partially live (ProgressCard + LatestActivityCard have dummy data)

**DUMMY ITEMS:**
- **ProgressCard (lines 32–34):** `goalCalories = 800.0`, `goalSteps = 10000.0`, `goalDistance = 8.0` — hardcoded goals; should come from user settings or device.
- **ProgressCard (lines 76, 85, 96):** `target: '800'`, `target: '10,000'`, `target: '8'` — same goals as display; replace with same source as above.
- **ActivityTabs (lines 311–317):** Static list `[All, Walking, Running, Cycling, Workout]` — may be OK as UI tabs; if activities should reflect device/supported modes, replace with device/backend list.
- **LatestActivityCard (lines 372–418):** Entire card is dummy: `'Running'`, `'Start 6:30 AM'`, `'Finish 7:30 AM'`, `'6 min/km'`, `'1,200 KM'`, `'285 Kcal'` — should come from device/backend latest activity or show empty state.
- **RecoveryDataButton:** Label only; no data.
- **HealthMetricCard:** Receives value/unit/trend from parent; no internal dummy data.

**LIVE ITEMS:**
- ProgressCard: calories, steps, distance **values** from `liveData`; concentric rings use those values vs. hardcoded goals.
- HealthMetricCard: used by bracelet_screen with live or `-1` fallback.

---

## SCREEN: heart_screen.dart

**STATUS:** Partially live

**DUMMY ITEMS:**
- **Line 93:** `'HI, USER'` — hardcoded greeting.
- **_EcgPainter (lines 287–309):** Static `_pts` array — decorative ECG curve; OK as visual only (not data).
- **_StatsTable (lines 281–282):** `Max Heart Rate: '--'`, `Resting: '--'` — should come from device history or backend when available.
- **_HistoryCard / _ChartPainter (lines 371–396):** `_data` = hardcoded 28 BPM values (72, 85, 160, …); chart should use device/backend heart rate history.
- **_ChartPainter:** `_yLabels`, `_xLabels` (200, 160, 120, 80, 40 and 00, 06, 12, 18, 00) — axis labels; OK if chart data is dynamic.
- **_AiInsightCard (lines 451–455):** Full paragraph hardcoded — should be dynamic or backend-generated based on actual RHR/pattern.

**LIVE ITEMS:**
- _HeartBpm: BPM from `_currentBpm` (type 24 realtimeData).
- _StatsTable: Average Rate from `currentBpm`.
- Listens to bracelet channel for type 24 heartRate.

---

## SCREEN: sleep_screen.dart

**STATUS:** Has dummy data

**DUMMY ITEMS:**
- **Line 63:** `'HI, USER'` — hardcoded greeting.
- **_MoonHero (line 212):** Score `'-1'` (displayed as -1%) — placeholder; should come from device sleep data (type 27) or backend.
- **_StatCards (lines 319–321):** Sleep Time, Sleep Latency, Nap all `value: '-1'` — should come from sleep API/device.
- **_SleepCycle (lines 368–406):** Entire `_data` list static: AMS 25%, Light 53%, Deep 24%, REM 12%, S.E 37%, Sleep Dept 32% with fixed times (00:06, 02:16, etc.) — should come from device/backend sleep stages.
- **_SleepOverview / _OverviewChartPainter (lines 453–469):** `bars` hardcoded (x/h pairs) — chart should use real sleep-over-time data.
- **_AiInsightCard (lines 494–501):** Two hardcoded bullet tips — should be dynamic or backend insights.

**LIVE ITEMS:**
- Requests sleep via `_channel.requestSleepData()`; no state wired to response yet (data would be type 27).

---

## SCREEN: blood_pressure_screen.dart

**STATUS:** Partially live

**DUMMY ITEMS:**
- **Line 173:** `'HI, USER'` — hardcoded greeting.
- **_StatTiles (line 200):** `averageBp: '-- / --'` — should come from history/backend when available.
- **_BpHero:** "Measure" button is UI only; systolic/diastolic are live.
- **_GraphCard / _BpBarPainter (lines 451–452, 465–466):** `_sys = [120, 145, 135, 140, 155]`, `_dia = [80, 95, 85, 90, 100]` — chart data hardcoded; should use device/backend BP history.
- **_AiInsightCard (lines 469–474):** Full paragraph hardcoded — should be dynamic/backend.

**LIVE ITEMS:**
- _BpHero: systolic, diastolic from `_systolic`, `_diastolic` (liveData + realtimeData type 52 / ECG result).
- _StatTiles: lastBp from live state.
- Listens to channel, starts PPG; applies liveData and estimates from HR when no direct BP.

---

## SCREEN: hrv_screen.dart

**STATUS:** Partially live

**DUMMY ITEMS:**
- **Line 155:** `'HI, USER'` — hardcoded greeting.
- **_GraphCard / _HrvBarPainter (lines 419–439, 426–427):** `_raw` = 21 hardcoded values; `_yLabels`, `_xLabels` — chart should use device/backend HRV history.
- **_AiInsightCard (lines 451–456):** Full paragraph hardcoded — should be dynamic/backend.

**LIVE ITEMS:**
- _HrvHero: value from `_hrvCurrent` (type 38/56).
- _StatTiles: highest, lowest, average from device session.
- Requests and listens for HRV data (38, 56).

---

## SCREEN: stress_screen.dart

**STATUS:** Partially live

**DUMMY ITEMS:**
- **Line 191:** `'HI, USER'` — hardcoded greeting.
- **_StressHero (line 206):** When `d.current < 0` fallback value `57` — placeholder; consider `--` or neutral.
- **_GradientBar (line 214):** When no data, fallback `0.57` — same as above.
- **_StatTiles (lines 222–224):** When `d.max/min/medium < 0` use `82`, `61`, `45` — placeholder stats; consider `--` or hide.
- **_AiInsightCard (lines 469–474):** Full paragraph hardcoded — should be dynamic/backend.

**LIVE ITEMS:**
- Stress value from HRV (type 38/56) Stress field or derived from HR (type 24).
- Bar chart uses `barValues` from `_stressHistory` (live).
- Max/medium/min computed from session history when available.

---

## SCREEN: spo2_screen.dart

**STATUS:** Has dummy data

**DUMMY ITEMS:**
- **Line 33:** `'HI, USER'` — hardcoded greeting.
- **_LungsHero (line 132):** `'95%'` — hardcoded; should come from device/backend SpO2.
- **_SegmentedColorBar (line 53):** `value: 0.95` — hardcoded; should match live SpO2.
- **_StatTiles (lines 228–240):** All three tiles `value: '-1%'` — should come from device/backend.
- **_GraphCard / _Spo2BarPainter (lines 371–391, 426–427):** `_raw` 21 values; chart should use device/backend SpO2 history.
- **_AiInsightCard (lines 377–383):** Full paragraph hardcoded — should be dynamic/backend.

**LIVE ITEMS:**
- None; screen does not take channel or liveData; no device integration.

---

## SCREEN: temperature_screen.dart

**STATUS:** Partially live

**DUMMY ITEMS:**
- **Line 106:** `'HI, USER'` — hardcoded greeting.
- **_GraphCard / _TempBarPainter (lines 599–621):** `_raw` 19 values; chart should use device/backend temperature history.
- **_AiInsightCard:** Hardcoded insight text — should be dynamic/backend.

**LIVE ITEMS:**
- _TempHero: temperature from `_currentTemp` (type 24).
- _StatTiles: highest, lowest, average from session.
- Listens for type 24 temperature.

---

## SCREEN: hydration_screen.dart

**STATUS:** Has dummy data

**DUMMY ITEMS:**
- **Line 33:** `'HI, USER'` — hardcoded greeting.
- **_HydrationTopCard (lines 49–51):** `hydrationPercent: 0.22`, `currentLiters: 1.0`, `goalLiters: 8.0` — all hardcoded; should come from device/backend or user input.
- **_GaugeCard (line 424):** `_WaterGaugePainter(pct: 0.22, s: s)` — same 22%; should match live hydration.
- **_GraphCard:** Hydration frequency chart — if data is hardcoded, replace with device/backend.
- **_AiInsightCard:** Hardcoded tips — should be dynamic/backend.

**LIVE ITEMS:**
- None; no channel or liveData; no device integration.

---

## SCREEN: activities_screen.dart

**STATUS:** Partially live (static lists + dummy today)

**DUMMY ITEMS:**
- **Line 65:** `'HI, USER'` — hardcoded greeting.
- **_allActivities (lines 26–46):** Static list of 12 activity types (Walking, Running, …) — if device supports activity modes, consider syncing with device; else OK as app taxonomy.
- **_TodayPanel / _today (lines 297–321):** Three fixed activities (Running 6:30–7:30, Walking 6:30–7:30, Cycling 6:30–7:30) with progress 0.65, 0.80, 0.40 — should come from device/backend today's activities.
- **activities_info_screen (from _StatLine):** `Total Calories: '-1'`, `Active Time: '-1'` — should come from activity detail/device.

**LIVE ITEMS:**
- Channel passed for future use; search/filter over static list.

---

## SCREEN: progress_screen.dart

**STATUS:** Has dummy data

**DUMMY ITEMS:**
- **Line 73:** `'HI, USER'` — hardcoded greeting.
- **_values, _maxes, _progress (lines 23–26):** `['-1','-1','-1']`, `['/-1','/-1','/-1']`, `[0.0,0.0,0.0]` — steps/distance/calories and progress should come from bracelet_screen or device (e.g. liveData / total activity).
- **_barData, _barMaxes (lines 35–41):** Weekly bar data all -1.0 — should come from device/backend history.
- **_yTickSets:** Static axis labels; OK if data range is dynamic.
- **_aiTexts (lines 55–59):** Three hardcoded tab-specific AI texts — should be dynamic/backend.

**LIVE ITEMS:**
- None; screen does not receive channel or liveData; should be fed from bracelet dashboard data or same source as ProgressCard.

---

## SCREEN: general_recovery_screen.dart

**STATUS:** Has dummy data

**DUMMY ITEMS:**
- **Line 24:** `'HI, USER'` — hardcoded greeting.
- **_StatusPill (line 171):** `'REGENERATION STATUS: OPTIMAL'` — should come from computed recovery/backend.
- **_ReadyIndicator (lines 194–195):** `isActive = i < 3` (3 of 4 bars active) — should reflect real readiness score.
- **_BodyBalanceCard (lines 293–306):** `'92%'`, `values: [0.5, 0.7, 0.55, 0.85, 0.65, 0.92]` — should come from device/backend.
- **_StressIndexCard (lines 356–375):** `'LOW'`, `widthFactor: 0.45` — should come from stress/HRV data.
- **_SleepQualityCard (lines 399–404, 437–440, 473–497):** `_bars` (REM 55%, LIGHT 80%, DEEP 65%, AWAKE 20%), `'Excellent'`, `'96%'` Circadian, `widthFactor: 0.96` — should come from sleep data.
- **_HydrationRecoveryCard (lines 383–384, 411–412, 424–425):** `'Goal: 2.5L Today'`, `progress: 0.70`, `'70%'` — should come from hydration/recovery.
- **_EveningRoutineCard, _SleepEnvironmentCard, _WeeklyTrendCard, _InflammationCard, _MetabolicReadinessCard:** All contain hardcoded percentages, labels, or fixed values — should come from device/backend/insights.

**LIVE ITEMS:**
- None; stateless; no channel or liveData.

---

## SCREEN: bracelet_search_screen.dart

**STATUS:** Partially live (navigation + request logic; no data display audited for dummy values in this pass)

**DUMMY ITEMS:**
- Search UI and request data (search) log; primary role is connection/scan. Any placeholder device list would be from scan results (live).

**LIVE ITEMS:**
- Scan results, connection state, requestSleepData/startRealtime when used.

---

## SCREEN: bracelet_scaffold.dart

**STATUS:** No data (layout only)

**DUMMY ITEMS:** None.  
**LIVE ITEMS:** N/A.

---

## SCREEN: activities_info_screen.dart

**STATUS:** Likely has dummy data (referenced in activities_screen with '-1' stats)

**DUMMY ITEMS:**
- Total Calories, Active Time from activities_screen passed as '-1' — should come from activity detail/device.

**LIVE ITEMS:**
- Depends on what ActivitiesScreen passes; currently dummy.

---

## SCREEN: share_activity_screen.dart

**STATUS:** Not fully audited; typically share target (e.g. social) and optional activity payload. If it shows activity stats, ensure they come from real activity data, not hardcoded.

---

## Summary Table

| Screen                    | Has dummy data | Fully live | Partially live |
|---------------------------|----------------|-----------|----------------|
| bracelet_screen           | ✓              |           | ✓              |
| bracelet_components       | ✓              |           | ✓              |
| heart_screen              | ✓              |           | ✓              |
| sleep_screen              | ✓              |           |                |
| blood_pressure_screen     | ✓              |           | ✓              |
| hrv_screen                | ✓              |           | ✓              |
| stress_screen             | ✓              |           | ✓              |
| spo2_screen               | ✓              |           |                |
| temperature_screen        | ✓              |           | ✓              |
| hydration_screen          | ✓              |           |                |
| activities_screen         | ✓              |           | ✓              |
| progress_screen           | ✓              |           |                |
| general_recovery_screen   | ✓              |           |                |

---

## PRIORITY ORDER: Which screens to integrate first (by amount of dummy data and impact)

1. **progress_screen.dart** — Dashboard expansion; values/maxes/progress and weekly bars all `-1`. Same data source as ProgressCard (steps, distance, calories). High impact, single data source.
2. **sleep_screen.dart** — Score, stat cards, sleep cycle, overview chart, and insights all dummy. Already requests sleep data (type 27); wire response to state and replace placeholders.
3. **spo2_screen.dart** — Entire screen static (95%, -1% tiles, chart, insight). Add channel/liveData and device or backend SpO2; then replace hero, tiles, chart, AI.
4. **hydration_screen.dart** — Percent, liters, goal, gauge, and insights hardcoded. No device today; define backend or manual input then replace all placeholders.
5. **general_recovery_screen.dart** — Many cards with fixed percentages and labels. Depends on sleep, stress, hydration, activity; integrate after those screens feed data, then compute or fetch recovery metrics.
6. **bracelet_screen.dart + bracelet_components.dart** — SLEEP and HYDRATION grid cards and LatestActivityCard dummy; ProgressCard goals hardcoded. After sleep/hydration/progress/activities are live, wire grid and latest activity and user goals.
7. **heart_screen.dart** — History chart and AI insight dummy; live BPM and average already. Add history source and optional AI backend.
8. **blood_pressure_screen.dart** — Graph and average BP and AI dummy; live BP and last value already. Add history and optional AI.
9. **hrv_screen.dart** — Chart and AI dummy; live HRV and stats already. Add history and optional AI.
10. **stress_screen.dart** — Placeholder fallbacks (57, 0.57, 82, 61, 45) and AI dummy; live stress and bar chart already. Soften fallbacks and add AI.
11. **temperature_screen.dart** — History chart and AI dummy; live temp and stats already. Add history and optional AI.
12. **activities_screen.dart** — Today panel and activity stats dummy; activity list can stay static unless device modes are used. Add today’s activities and detail stats from device/backend.

---

**End of audit.**
