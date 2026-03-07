# Step A – Hidden Behavior Review

Review of Step A refactor for parsing, merge, fallbacks, and widget input shape. Verdict and exact risky areas below.

---

## 1. Parsing rules

| Area | Original | Step A (parser) | Verdict |
|------|----------|------------------|---------|
| dataType (int/num/String) | `_dataTypeAsInt` same branches | `BraceletDataParser.dataTypeAsInt` identical | **Safe** |
| Total activity (type 25) | `Data` / `arrayTotalActivityData`, last record, else flat dic by step/Step/date/Date | `parseTotalActivityData` same keys and order | **Safe** |
| normalizeActivityKeys | step, Step; distance + 6 fallbacks; calories, Calories; date, exerciseMinutes, activeMinutes, goal | Parser `normalizeActivityKeys` same keys | **Safe** |
| BP keys (systolic/diastolic) | flatten Data/data then 6 sys + 6 dia key fallbacks, range 60–250 / 40–150 | Parser `parseBloodPressure` + `flattenForBp` same | **Safe** |
| HRV keys | 13 fallbacks (HRV, hrv, Value, SDNN, …) | Parser `extractHrvFromMap` same list | **Safe** |

**Conclusion: No parsing rule change.**

---

## 2. Fallback key handling

| Area | Original | Step A | Verdict |
|------|----------|--------|---------|
| firstOf order | step/Step/steps/Steps; distance/Distance/…; calories/Calories; heartRate/HeartRate/hr/HR/heart_rate; hrv/HRV/Hrv/hrvValue/hrvResultValue; spo2/SPO2/Spo2/oxygen/Oxygen; temperature/Temperature/temp/Temp; stress/Stress | Parser `firstOf` and same key lists in `mergeLiveData` | **Safe** |
| toDisplayMap keys | N/A (original was single merged map) | step, distance, calories, heartRate, temperature, hrv, stress, spo2, systolic, diastolic | **Safe** – widgets use these or fallbacks; we only emit normalized keys, so firstOf in widget (e.g. heartRate ?? HeartRate) still works (we provide heartRate). |

**Conclusion: No fallback key handling change.**

---

## 3. BP / HRV / stress estimation logic

| Area | Original | Step A | Verdict |
|------|----------|--------|---------|
| estimateBpFromHeartRate | baseSys 100, baseDia 65, hrOffset (hr-65).clamp(-30,40), sys/dia formula, clamp 90–160 / 55–100 | Parser `estimateBpFromHeartRate` same constants and formula | **Safe** |
| stressFromHeartRate | restLow 55, restHigh 75, high 120; three segments with same math | Parser `stressFromHeartRate` same | **Safe** |
| BP in merge | Use _bpSystolic/_bpDiastolic if both set; else if hr in [40,200] use estimate | Parser: systolic/diastolic = bp args; if either null and hr in range, estimate | **Safe** |
| Stress in merge | If merged has no Stress/stress and hr in [40,200], set merged['stress'] = _stressFromHeartRate(hrVal) | Parser: stressVal = intFrom(stress); if null and hr in range, stressVal = stressFromHeartRate(hrVal) | **Safe** |

**Conclusion: No BP/HRV/stress estimation logic change.**

---

## 4. lastUpdated behavior

| Area | Original | Step A | Verdict |
|------|----------|--------|---------|
| When set | Screen set `_lastDataUpdateTime = DateTime.now()` in applyUpdate when type 24 or 25 | Unchanged – still in BraceletScreen applyUpdate | **Safe** |
| Where used | "Last updated Xs ago" uses `_lastDataUpdateTime` from screen state | Same – no use of LiveHealthMetrics.lastUpdated in UI | **Safe** |
| In merged map | lastUpdated was never in the merged map | Parser returns lastUpdated: null; toDisplayMap does not include it | **Safe** |

**Conclusion: No lastUpdated behavior change.**

---

## 5. Merge precedence (realtime vs total activity)

| Area | Original | Step A | Verdict |
|------|----------|--------|---------|
| Base | merged.addAll(realtime), then if total != null overwrite step/dist/cal with rules | Parser: same merged.addAll(realtime), then same total block | **Safe** |
| Step | realtimeStep null → totalStep; both set → max(realtime, total); else realtimeStep | Parser: same three branches | **Safe** |
| Distance | Same (realtimeDist null → totalDist; both → max; else realtimeDist) | Parser: same | **Safe** |
| Calories | Same | Parser: same | **Safe** |

**Conclusion: No merge precedence change.**

---

## 6. Widget input shape

| Consumer | Reads | Step A toDisplayMap() | Verdict |
|----------|--------|------------------------|---------|
| ProgressCard | step, calories, distance (+ Distance, totalDistance, … for distance) | step, distance, calories (normalized) | **Safe** – has required keys; distance fallbacks in widget still work (we provide distance). |
| _HealthGrid | heartRate/HeartRate, hrv/HRV, spo2/oxygen/Oxygen/SPO2, systolic/Systolic, diastolic/Diastolic, temperature/Temperature, stress/Stress | heartRate, hrv, spo2, systolic, diastolic, temperature, stress | **Safe** – widget uses key ?? fallback; we provide the primary key in each pair. |
| stepKey | liveData?['step'] ?? 0 | liveData has 'step' when present | **Safe** |

**Conclusion: No widget input shape change** – same logical keys and types for display; optional fallback keys no longer needed because we always pass normalized keys.

---

## 7. Realtime update frequency

| Area | Original | Step A | Verdict |
|------|----------|--------|---------|
| Event subscription | _channel.events.listen in _listenRealtime | Same – still in BraceletScreen | **Safe** |
| 1s timer | _realtimeRefreshTimer, _refreshDataFromDevice | Same | **Safe** |
| setState on event | applyUpdate() + addPostFrameCallback setState | Same | **Safe** |
| New allocations | _mergedLiveData() built map each build | mergeLiveData() + toDisplayMap() each build – one extra allocation (LiveHealthMetrics + map) | **Safe** – negligible; no timer or stream change. |

**Conclusion: Realtime updates are not slower or less frequent.**

---

## 8. Exact lines/areas that are risky (optional adjustments)

### 8.1 SpO2 / numeric truncation (optional)

- **Where:** `bracelet_data_parser.dart` line 259: `spo2: intFrom(merged['spo2'])`.
- **Original:** Merged map could hold device value as double (e.g. 98.7).
- **Step A:** `intFrom` truncates (98.7 → 98). Widget shows "98" instead of "98.7" (or "99" if rounded).
- **Impact:** Small display difference for fractional SpO2.
- **Fix (optional):** Round before int: e.g. `spo2: toDouble(merged['spo2'])?.round()` and keep `spo2` as `int?` in the model, or keep double in model and let widget format.

### 8.2 Stress type (improvement, not regression)

- **Where:** Parser passes `stress: stressVal` (int?).
- **Original:** merged['stress'] could be device double (e.g. 50.0).
- **Step A:** We pass int (50). Widget does `'$stress'` and `(stress as num) > 50` – both work; display "50" instead of "50.0".
- **Verdict:** **Safe** – display is consistent; no regression.

### 8.3 Temperature

- **Where:** `toDouble(merged['temperature'])` – we keep double.
- **Verdict:** **Safe** – no change from original.

---

## 9. Summary verdict

| Category | Verdict |
|----------|---------|
| Parsing rules | **Safe as-is** |
| Fallback key handling | **Safe as-is** |
| BP/HRV/stress estimation | **Safe as-is** |
| lastUpdated behavior | **Safe as-is** |
| Merge precedence (realtime vs total) | **Safe as-is** |
| Widget input shape | **Safe as-is** |
| Realtime update frequency | **Safe as-is** |
| SpO2 fractional display | **Adjusted:** parser now uses `toDouble(merged['spo2'])?.round()` so 98.7 → 99 (matches original intent for display). |

**Overall: Safe as-is** for behavior. Optional SpO2 rounding has been applied.

---

## 10. Applied fix

**File:** `lib/bracelet/data/bracelet_data_parser.dart`  
**Line:** 259  

**Change:** `spo2: intFrom(merged['spo2'])` → `spo2: toDouble(merged['spo2'])?.round()` so fractional SpO2 (e.g. 98.7) displays as rounded (99) rather than truncated (98).

No other code or logic changes required for correctness.
