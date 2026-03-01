# Bracelet SDK – Activity data integration

How the J2208A bracelet SDK exposes **activity** data and what you can integrate in the app.

---

## 1. How the SDK provides activity data

Activity comes from **three** SDK flows:

| Flow | iOS dataType | Description | What you get |
|------|--------------|-------------|--------------|
| **Realtime (live)** | **24** | `RealTimeStep` – streamed every second or on step change | Steps, distance, calories, heart rate, temperature, exercise/active minutes for *current moment* |
| **Total (daily)** | **25** | `TotalActivityData` – daily aggregates | Per-day: steps, distance, calories, goal, exercise minutes, active minutes (up to 50 days) |
| **Detail (intraday)** | **26** | `DetailActivityData` – finer time resolution | Per interval: date/time, steps, calories, distance, minute-by-minute step array |
| **Activity mode (sport)** | **30** | `ActivityModeData` – workout sessions by sport type | Per session: date/time, **sport type**, heart rate, duration, steps, pace, distance, calories |

**Modes for reading:** `0` = from latest (up to 50), `2` = next batch, `0x99` = delete.

---

## 2. Data already used in the app

- **Realtime (24)**  
  Used on the bracelet dashboard: live steps, distance, calories, heart rate, temperature (from `startRealtime(RealtimeType.stepWithTemp)`).

- **Total (25)**  
  Used for “today’s total” so the dashboard isn’t empty before realtime: `requestTotalActivityData()` → responses with **dataType 25** → parsed as step, distance, calories (and optionally goal, exerciseMinutes, activeMinutes).  
  Polling every 30s is already implemented in `bracelet_screen.dart`.

- **Detail (26)** and **Activity mode (30)**  
  **Not** requested from the app yet. The iOS plugin has no `requestDetailActivityData` or `requestActivityModeData`; only `requestTotalActivityData` is implemented.

---

## 3. All activities (sport types) from the bracelet

The device supports **18 activity/sport modes** (from `ACTIVITYMODE_J2208A` in the iOS SDK):

| Index | Name (SDK) | Typical label |
|-------|------------|----------------|
| 0 | Run | Running |
| 1 | Cycling | Cycling |
| 2 | Badminton | Badminton |
| 3 | Football | Football |
| 4 | Tennis | Tennis |
| 5 | Yoga | Yoga |
| 6 | Breath | Breathing exercise |
| 7 | Dance | Dance |
| 8 | Basketball | Basketball |
| 9 | Walk | Walking |
| 10 | Workout | Workout / fitness |
| 11 | Cricket | Cricket |
| 12 | Hiking | Hiking |
| 13 | Aerobics | Aerobics |
| 14 | PingPong | Table tennis |
| 15 | RopeJump | Rope jump |
| 16 | SitUps | Sit-ups |
| 17 | Volleyball | Volleyball |

These are the **sport types** you get in **Activity mode data (type 30)** when the user has recorded workouts.  
Realtime (24) and total (25) are **not** per-sport; they are “all activities” for the current moment or the day.

---

## 4. List of activity-related data you can get from the SDK

| # | Data | dataType | Request (SDK) | Response shape (typical keys) |
|---|------|----------|----------------|--------------------------------|
| 1 | **Live steps / distance / calories / HR / temp** | 24 | `RealTimeDataWithType(1 or 2)` (already used) | step, distance, calories, heartRate, temperature, exerciseMinutes, activeMinutes |
| 2 | **Daily total (per day)** | 25 | `GetTotalActivityDataWithMode:withStartDate:` (already used) | Data[]: Date, Step, Distance, Calories, Goal, ExerciseMinutes, ActiveMinutes |
| 3 | **Detail activity (intraday)** | 26 | `GetDetailActivityDataWithMode:withStartDate:` | Data[]: Date, step (per interval), Calories, Distance, minute-step array |
| 4 | **Sport sessions (activity mode)** | 30 | `GetActivityModeDataWithMode:withStartDate:` | Data[]: Date, **sportModel** (0–17), HeartRate, ActiveMinutes, Step, Pace, Distance, Calories |

So the **full list of activity-related data** you can get from the bracelet SDK is:

1. **Realtime** – steps, distance, calories, heart rate, temperature, exercise/active minutes (live).
2. **Total activity** – per-day steps, distance, calories, goal, exercise minutes, active minutes (up to 50 days).
3. **Detail activity** – per-interval steps, calories, distance, and minute-level step breakdown.
4. **Activity mode (sport)** – per-session: sport type (one of the 18 above), heart rate, duration, steps, pace, distance, calories.

---

## 5. What’s missing in the app to “integrate activity section”

- **iOS (BraceletBleAdapter + BraceletPlugin)**  
  - Add `requestDetailActivityData()` → call SDK `GetDetailActivityDataWithMode:withStartDate:` and emit **realtimeData** with **dataType 26**.  
  - Add `requestActivityModeData()` → call SDK `GetActivityModeDataWithMode:withStartDate:` and emit **realtimeData** with **dataType 30**.

- **Flutter (BraceletChannel)**  
  - Add `requestDetailActivityData()` and `requestActivityModeData()` that call the new native methods.

- **App UI**  
  - **Activities screen:** Subscribe to events with dataType **26** and **30**; parse `Data` or equivalent (e.g. iOS might use a key like `arrayDetailActivity` / `arrayActivityMode` – check actual payload).  
  - Show **sport sessions** from type 30 (sport type, date, duration, steps, distance, calories, pace).  
  - Optionally show **detail activity** from type 26 (e.g. hourly or interval breakdown for a day).

- **Enter activity mode (optional)**  
  - SDK has `EnterActivityMode:WorkMode:BreathParameter:` to start a workout on the device (e.g. “Run”, “Yoga”).  
  - Then the device records that session and it appears in **Activity mode data (30)**.  
  - Implementing this is optional for “list activities”; it’s needed only if you want to **start** a sport mode from the app.

---

## 6. Summary table – activities you can get data for

| Source | What you get |
|--------|----------------|
| **Realtime (24)** | Live steps, distance, calories, HR, temp (no sport type) |
| **Total (25)** | Daily steps, distance, calories, goal, exercise/active minutes (no sport type) |
| **Detail (26)** | Intraday step/calorie/distance and minute-level steps (no sport type) |
| **Activity mode (30)** | **Per-session sport type** (Run, Cycling, Badminton, Football, Tennis, Yoga, Breath, Dance, Basketball, Walk, Workout, Cricket, Hiking, Aerobics, PingPong, RopeJump, SitUps, Volleyball) + heart rate, duration, steps, pace, distance, calories |

For an **“Activity section”** that shows past workouts by type, you need to add **requestActivityModeData** and parse **dataType 30** with the **18 sport types** listed above.
