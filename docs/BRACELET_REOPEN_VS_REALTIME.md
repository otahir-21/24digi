# Reopen vs Realtime: Snapshot Works, Stream Fails

Verification in code that **on reopen** fresh data appears (snapshot/on-demand) while **while app stays open** walking does not update live (realtime stream fails).

---

## 1. On app reopen / screen re-entry: which methods fetch fresh data?

**Reopen = user leaves BraceletScreen then comes back** (e.g. switch tab, go to Heart then back, or kill app and reopen).

### A. Full app reopen (process restarted)

- **Entry:** User opens app → RootScreen → Home → Bracelet tab → **BraceletSearchScreen** or direct to **BraceletScreen** if already connected.
- If **BraceletScreen** is shown (e.g. from home with “already connected” path):
  - **initState** runs:
    - `_listenRealtime()` – subscribes to EventChannel (no fetch).
    - `_verifyConnectionAndClearIfDisconnected()` – after 300 ms, if not connected clears data (no fetch).
    - **`_requestDataSoonIfConnected()`** – microtask: if connected → **`_startRealtimeIfConnected()`** (calls **startRealtime(2)**), **`_requestTotalActivityOnce()`** (calls **requestTotalActivityData()**), **`_startRealtimeRefreshTimer()`** (starts 1 s timer that calls **requestTotalActivityData()** only).
    - **Delayed 1800 ms:** again **`_startRealtimeIfConnected()`**, **`_requestTotalActivityOnce()`**, **`_startRealtimeRefreshTimer()`**.
  - So on reopen (cold): **startRealtime(2)** is called (microtask + again at 1.8 s). **requestTotalActivityData()** is called (microtask + 1.8 s + then every 1 s by timer).

### B. Screen re-entry only (navigate away from dashboard then back)

- User was on BraceletScreen, navigated to e.g. HeartScreen, then back.
- **didPopNext** runs (RouteAware):
  - **`_startTotalActivityPolling()`** → `_startRealtimeRefreshTimer()` (if not already active, starts 1 s timer).
  - **`_startRealtimeIfConnected()`** → **startRealtime(2)**.
  - **`_startRealtimeRefreshTimer()`** – ensures 1 s timer running; next tick calls **requestTotalActivityData()**.
  - So on re-entry: **startRealtime(2)** once, **requestTotalActivityData()** on timer (and immediately once via `_refreshDataFromDevice()` if timer just started).

### C. initialRealtimeData from search

- When navigating **from BraceletSearchScreen** to BraceletScreen after connect, search can do:
  - `Navigator.pushReplacement(..., BraceletScreen(initialRealtimeData: dataToPass))`.
  - **initState** of BraceletScreen: `if (widget.initialRealtimeData != null) _realtimeData = Map.from(widget.initialRealtimeData!)`.
  - So the **first** paint can show one snapshot from the search screen. No extra fetch there; the **request** that gets fresh data on dashboard is still **requestTotalActivityData()** and (if device responds) **startRealtime** leading to type 24.

**Summary:** On reopen/re-entry we always call **startRealtime(2)** and **requestTotalActivityData()** (once or via 1 s timer). The **delayed** 1.8 s block only runs on **first** load (initState), not on didPopNext.

---

## 2. Which data type is most likely responsible for the new value after reopening?

- **Type 25 (TotalActivityData)** – Returned in response to **requestTotalActivityData()**. We explicitly request it on connect, on 1.8 s delay, and every 1 s on timer. So after reopen, the next timer tick or the immediate “once” request triggers a **request**; the device replies with type 25; we update **`_totalActivityData`** and the merge shows the new step. **This is the main source of “fresh value after reopen”.**
- **Type 24 (RealTimeStep)** – Streamed when **startRealtime(2)** is active and the device sends live updates. If the **stream** is broken (no or rare type 24 events while app stays open), type 24 does **not** drive the update on reopen; only the **on-demand** request (type 25) does.

So: **type 25 is most likely responsible for the new value that appears after reopening.** Type 24 would only contribute if the device actually sends it after we call startRealtime on re-entry; if the stream is broken, we still get type 25 from the explicit request.

---

## 3. Dashboard reliance on total activity and whether type 25 can mask stale type 24

**Merge logic (BraceletDataParser.mergeLiveData / same in screen):**

- Step:  
  - If only total has step → use total.  
  - If both have step → use **max(realtimeStep, totalStep)**.  
  - If only realtime has step → use realtime.
- Same idea for distance and calories.

So the dashboard **does** rely on total activity when realtime has no step (or a lower one). And **yes**, type 25 can “mask” stale type 24 on reopen:

- While app is open: type 24 stream is dead → `_realtimeData` never or rarely updates → merged step stays at last value (or total only).
- On reopen: we call **requestTotalActivityData()** → device sends type 25 → we set **`_totalActivityData`** to the new snapshot → merge takes **max(realtime, total)**; if total is newer/higher, **merged step = total** → UI shows the new value. So the **reopen-triggered type 25** is what makes the number jump; type 24 can be stale and still “masked” by the fresh type 25.

---

## 4. Exact lifecycle flow on reopen

**Scenario: user was on BraceletScreen, went to another screen, then came back (didPopNext).**

1. **didPopNext** (BraceletScreen)
   - `_startTotalActivityPolling()` → `_startRealtimeRefreshTimer()`  
     - If timer was stopped (we left), it starts again and calls `_refreshDataFromDevice()` once now.
   - `_startRealtimeIfConnected()`  
     - `getConnectionState()` → if connected, **startRealtime(2)** (native).
   - `_startRealtimeRefreshTimer()`  
     - Same 1 s timer; next tick in 1 s will call `_refreshDataFromDevice()` again.

2. **Connection check**  
   - Inside `_startRealtimeIfConnected()` and `_refreshDataFromDevice()` we call `_channel.getConnectionState()`; no separate “reopen connection” step.

3. **Realtime start**  
   - **startRealtime(2)** is invoked in `_startRealtimeIfConnected()` (native `startRealtime(type: 2)`). No delayed start for re-entry; it runs synchronously after didPopNext.

4. **Total activity request**  
   - **requestTotalActivityData()** is invoked:
     - Immediately once if `_startRealtimeRefreshTimer()` just started (it calls `_refreshDataFromDevice()` once).
     - Then every 1 s by the timer (`_refreshDataFromDevice()` → `requestTotalActivityData()` only).

5. **Event subscription**  
   - Subscription was created in **initState** via `_listenRealtime()` and is not recreated on didPopNext. So we keep receiving events on the same subscription.

6. **Merge**  
   - On each **realtimeData** event, **applyUpdate()** updates **`_realtimeData`** (type 24) or **`_totalActivityData`** (type 25), then **setState** → **build()** runs → **`_mergedLiveData()`** (parser merge) → **toDisplayMap()** → ProgressCard / _HealthGrid.

7. **UI update**  
   - **setState** in applyUpdate + **addPostFrameCallback(setState)** force a rebuild; **KeyedSubtree(key: ValueKey(_dataVersion))** and **stepKey** ensure widgets that depend on step rebuild when data/version change.

**Order on re-entry:** didPopNext → startRealtime(2) + start timer → _refreshDataFromDevice() once → requestTotalActivityData() → (device replies) → realtimeData event (type 25) → applyUpdate → _totalActivityData set → setState → build → merge → UI shows new step.

---

## 5. Smallest instrumentation to prove type 24 = live, type 25 = reopen/fresh

- **Prove live walking should come from type 24:** Log when **type 24** is applied and step changes: e.g. `[Bracelet SOURCE] type24 step=X`. If while walking we **never** see this log (or see it only once), the realtime stream is failing.
- **Prove reopen/fresh from type 25:** Log when **type 25** is applied: e.g. `[Bracelet SOURCE] type25 step=X`. After reopen, if we see this log with a new step and no (or old) type 24, then the fresh value is coming from type 25.

**Minimal change:** In **applyUpdate** in `bracelet_screen.dart`: in the **type 25** branch log `[Bracelet SOURCE] type25 step=X`; in the **type 24** branch log `[Bracelet SOURCE] type24 step=X`. After applyUpdate, in the **realtimeData** handler, log merged step once (e.g. in post-frame callback) as `[Bracelet SOURCE] merged step=Y`. No other refactor.

---

## 6. Temporary logs added (exact locations)

**File:** `lib/screens/bracelet/bracelet_screen.dart`

| Log | Location | When it runs |
|-----|----------|----------------|
| `[Bracelet SOURCE] type25 step=X` | Inside **applyUpdate()**, in the `if (type == 25)` branch, right after setting `_totalActivityData` | Every time a **realtimeData** event with **dataType 25** is received (response to requestTotalActivityData). |
| `[Bracelet SOURCE] type24 step=X (old=Y)` | Inside **applyUpdate()**, in the `else` branch for type 24 (realtime step), when we update `_realtimeData` | Every time a **realtimeData** event with **dataType 24** is received (device stream). |
| `[Bracelet SOURCE] merged step=Z (after type N)` | Inside **addPostFrameCallback** after **applyUpdate()**, in the same `_listenRealtime()` subscription callback | Once per **realtimeData** event, on the next frame after applyUpdate; Z is the step from _mergedLiveData() (max(realtime, total) or fallback). |

**Interpretation:**

- **While walking, app open:** If the realtime stream worked you would see `[Bracelet SOURCE] type24 step=...` repeatedly. If you only see `[Bracelet SOURCE] type25 step=...` (e.g. every 1 s from the timer) and **no** or **one** `type24`, then **live walking updates are not coming from type 24**; any change you see is from type 25 (snapshot) only.
- **After reopen:** You should see at least one `[Bracelet SOURCE] type25 step=...` with the new step. If you see **no** `type24` after reopen but **do** see `type25` and then `merged step=<new value>`, that **proves reopen-triggered request causes only type 25 to change** and the fresh value on screen is from the snapshot (type 25), not the stream (type 24).
- **Merged step:** After each event, `merged step=Z` shows what the UI will display. If Z only changes when type 25 events appear (and not when type 24 appears), the dashboard is effectively driven by type 25 on reopen; type 24 stream is failing.
