# Native iOS Realtime Debug: Why Events Stop After First Batch

Definitive finding: Flutter timer fires every second, Flutter receives type24/type25 and applies step=864 at 14:16:51; after that only request logs continue and **no more realtimeData events**. So the failure is **native/device**: native stops producing new responses after the first batch.

This doc answers the seven questions and documents the instrumentation added.

---

## 1. When Flutter calls startRealtime(2) and requestTotalActivityData() every second, what exact native methods run each time?

**Every 1s tick (Flutter → native):**

| Flutter call | Plugin | Adapter | NewBle |
|--------------|--------|---------|--------|
| `startRealtime(2)` | `handle(_:result:)` case `"startRealtime"` → `adapter.startRealtime(type: 2)` | `startRealtime(type:)` → `sdk.realTimeData(withType: 2)` → `newBle.writeValue(FFF0, FFF6, p, data)` | `writeValue:...` → find service FFF0, char FFF6 → `[p writeValue:... type:CBCharacteristicWriteWithResponse]` |
| `requestTotalActivityData()` | `handle(_:result:)` case `"requestTotalActivityData"` → `adapter.requestTotalActivityData()` | `requestTotalActivityData()` → `sdk.getTotalActivityData(withMode:0, withStart:startOfToday)` → `newBle.writeValue(FFF0, FFF6, p, data)` | Same `writeValue` path → one BLE write to FFF6 |

So **each second**: two MethodChannel invocations → two adapter methods → **two BLE writes** to the same characteristic FFF6 (WriteWithResponse). There is no queue or mutex in our code; both writes are submitted in quick succession. CoreBluetooth serializes WriteWithResponse: the second write is sent only after the first is acknowledged.

**Receive path (device → Flutter):**  
Device sends notifications on FFF7 → `peripheral:didUpdateValueForCharacteristic:` (NewBle.m) → `[delegate BleCommunicateWithPeripheral:data:]` → `bleCommunicate(with:data:)` (BraceletBleAdapter) → `sdk.dataParsing(with:)` → if non-nil → `emit("realtimeData", data: payload)` to all event sinks.

---

## 2. Do those native methods actually write to the bracelet every second, or can they early-return / no-op?

They **can** early-return without writing:

- **startRealtime(type:)**  
  - Returns without write if `newBle?.activityPeripheral` is nil (emits connectionState failed).  
  - Returns without write if `sdk?.realTimeData(withType: type)` returns nil (no emit).
- **requestTotalActivityData()**  
  - Returns without write if peripheral is nil, or sdk is nil, or `sdk.getTotalActivityData(withMode:0, withStart:startOfToday)` returns nil. All are silent (no log before instrumentation).

NewBle `writeValue` can also skip the actual write if service FFF0 or characteristic FFF6 is not found on the peripheral (NSLog + return).

So **to confirm** that we keep writing every second, the new logs are required: you should see `BLE_WRITE` / `BLE_WRITE SENT` every second for both commands. If after the first batch you see `startRealtime` / `requestTotalActivityData` logs but **no** `BLE_WRITE SENT`, then an early-return (or NewBle skip) is happening.

---

## 3. Precise temporary logs added in native code

All below are wrapped in `#if DEBUG` / `#if DEBUG` so they only appear in Debug builds.

| Location | Log line |
|----------|----------|
| **BraceletPlugin.swift** | `[Bracelet Plugin] handle startRealtime type=X` |
| **BraceletPlugin.swift** | `[Bracelet Plugin] handle requestTotalActivityData` |
| **BraceletBleAdapter.swift** | `[Bracelet iOS] startRealtime(X) peripheral=...` (existing) |
| **BraceletBleAdapter.swift** | `[Bracelet iOS] startRealtime EARLY-RETURN no peripheral` |
| **BraceletBleAdapter.swift** | `[Bracelet iOS] startRealtime EARLY-RETURN SDK realTimeData nil` |
| **BraceletBleAdapter.swift** | `[Bracelet iOS] startRealtime BLE_WRITE N bytes` |
| **BraceletBleAdapter.swift** | `[Bracelet iOS] requestTotalActivityData` (existing) |
| **BraceletBleAdapter.swift** | `[Bracelet iOS] requestTotalActivityData EARLY-RETURN no peripheral` |
| **BraceletBleAdapter.swift** | `[Bracelet iOS] requestTotalActivityData EARLY-RETURN no SDK` |
| **BraceletBleAdapter.swift** | `[Bracelet iOS] requestTotalActivityData EARLY-RETURN getTotalActivityData nil` |
| **BraceletBleAdapter.swift** | `[Bracelet iOS] requestTotalActivityData BLE_WRITE N bytes` |
| **NewBle.m** | `[Bracelet NewBle] BLE_WRITE FFF6 len=X firstByte=0xXX` (on entry) |
| **NewBle.m** | `[Bracelet NewBle] BLE_WRITE SKIP no service` / `no characteristic` (if skip) |
| **NewBle.m** | `[Bracelet NewBle] BLE_WRITE SENT N bytes to FFF6` (before write) |
| **NewBle.m** | `[Bracelet NewBle] BLE_NOTIFY FFF7 len=X firstByte=0xXX` (didUpdateValue FFF7) |
| **BraceletBleAdapter.swift** | `[Bracelet iOS] bleCommunicate BLE_NOTIFY received N bytes` |
| **BraceletBleAdapter.swift** | `[Bracelet iOS] dataParsing returned nil (raw N bytes)` |
| **BraceletBleAdapter.swift** | `[Bracelet iOS] dataParsing OK dataType=X dataEnd=Y` |
| **BraceletBleAdapter.swift** | `[Bracelet iOS] EventChannel EMIT realtimeData dataType=X sinks=Y` |

Interpretation:

- After the first batch, if you see **Plugin + Adapter** logs every second but **no** `BLE_WRITE SENT` → early-return or NewBle skip.
- If you see **BLE_WRITE SENT** twice per second but **no** `BLE_NOTIFY FFF7` → device not sending; likely firmware/command behavior.
- If you see **BLE_NOTIFY FFF7** but **dataParsing returned nil** → SDK parsing issue or unexpected payload.
- If you see **dataParsing OK** but **no** `EventChannel EMIT` → bug in emit path (unlikely; same code path).
- If you see **EventChannel EMIT** but Flutter doesn’t get events → EventChannel/stream issue (unlikely given first batch works).

---

## 4. Which of the four failure modes is it?

Use the log sequence after the first batch (e.g. after 14:16:51):

| Observation | Failure mode |
|-------------|----------------|
| No `BLE_WRITE SENT` (but Plugin/Adapter logs) | **A. Not writing after first response** (early-return or skip) |
| `BLE_WRITE SENT` every second, no `BLE_NOTIFY FFF7` | **B. Writing but not receiving BLE responses** (device not sending) |
| `BLE_NOTIFY FFF7` but `dataParsing returned nil` | **C. Receiving but parser returns nil** |
| `dataParsing OK` + `EventChannel EMIT` but no Flutter event | **D. Parsing valid but not emitting to Flutter** (unlikely) |

Most likely from “only first batch” behavior: **B** (we keep writing, device stops responding) or a mix where the **device/SDK** only reacts to the first pair of commands (e.g. cooldown or “data end” semantics). The new logs will confirm.

---

## 5. Cooldown / busy / dataEnd / command collision in SDK or adapter?

- **Our adapter:** No cooldown, no “busy” flag, no suppression of writes or emits. Every call to `startRealtime` / `requestTotalActivityData` that passes the guards results in a write. Every successful `dataParsing` results in an emit.
- **dataEnd:** We only pass `deviceData.dataEnd` in the payload to Flutter; we do not use it to stop requesting or emitting. So we do not suppress later responses based on dataEnd.
- **Vendor SDK (BleSDK_J2208A):** We don’t have source. It could have internal state (e.g. “realtime session active”, “total activity request in progress”) that ignores repeated `realTimeData(withType:2)` or `getTotalActivityData` until some condition is met. We cannot see that without SDK logs or docs.
- **Command collision:** We send **startRealtime(2)** then **requestTotalActivityData()** back-to-back every second. Both use the same characteristic (FFF6) with WriteWithResponse. CoreBluetooth will send the first write, wait for ACK, then send the second. So the device receives: realtime command, then total-activity command, every second. Some firmware or SDKs may expect a single “session” of realtime and then only respond once, or may require a delay or different sequence for repeated requests. That would match “first batch only” and point to **B** or SDK/device semantics.

---

## 6. Can calling both startRealtime(2) and requestTotalActivityData() every second interfere?

Yes, in principle:

- **Same characteristic:** Both commands are written to FFF6. Sending two commands in quick succession every second could be interpreted by the device as “start realtime + request total” once, then the device may not support or may ignore repeating that exact pattern (e.g. it only streams once per “session”).
- **SDK state:** The SDK might track “realtime already started” and treat repeated `realTimeData(2)` as no-op, or might expect a different sequence for repeated total-activity requests.

So interference is plausible. The smallest fix is to **reduce or serialize** these calls so the device is not hammered with the same two writes every second.

---

## 7. Smallest native-only fix to try first

**Recommendation: call startRealtime once (or rarely) and only request total activity every N seconds.**

Rationale:

- Realtime (type 2) may be intended to “turn on” a stream once; repeating it every second may be unnecessary or even cause the device to “reset” or ignore further responses.
- Total activity is the one that returns type 24/25 (steps, etc.). So we keep **requestTotalActivityData()** on a timer (e.g. every 2–3 s) and **startRealtime(2)** only once when we consider the session started (e.g. on connect / when starting the dashboard), or every 10–30 s if the device requires a refresh.

**Concrete options (pick one to try first):**

1. **Only requestTotalActivityData every N seconds (e.g. 3 s)**  
   In Flutter: keep 1 s timer but only call `requestTotalActivityData()` every 3rd tick; call `startRealtime(2)` only once when entering/connected (or remove from timer entirely).  
   Native: no change.

2. **Only startRealtime every N seconds**  
   Call `startRealtime(2)` every 5–10 s and `requestTotalActivityData()` every 1 s.  
   Native: no change.

3. **Call startRealtime once, request total less often**  
   On connect / screen start: call `startRealtime(2)` once. Timer (e.g. every 2 s): only `requestTotalActivityData()`.  
   Native: no change.

4. **Serialize commands with delay (native)**  
   In `BraceletBleAdapter`, when Flutter calls `requestTotalActivityData()`, delay the actual write by 200–300 ms (e.g. `DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { ... writeValue ... }`) so the previous write (from `startRealtime`) is fully sent and ACKed before the next.  
   Reduces chance of the device seeing both commands in one “burst” every second.

5. **Wait for prior response before next request**  
   Would require native (or Flutter) to wait for at least one `realtimeData` (or a “dataEnd” for that type) before sending the next `requestTotalActivityData()`. More invasive; try (1)–(4) first.

**Smallest fix to test first:** **(3) startRealtime once, request total every 2 s.**  
In Flutter: on connect / when starting realtime UI, call `startRealtime(2)` once. Start a 2 s timer that only calls `requestTotalActivityData()`. If events then keep coming, the issue is likely command collision or device handling of repeated startRealtime(2). If they still stop after first batch, then try (4) or focus on device/SDK behavior (B).

---

## Summary

| Item | Answer |
|------|--------|
| **Most likely failure point** | Device stops sending BLE notifications after the first batch (**B**), or SDK/device semantics (cooldown / “one session” / collision) when we send startRealtime + requestTotalActivity every second. |
| **Exact native files/methods** | `BraceletPlugin.handle` (startRealtime, requestTotalActivityData), `BraceletBleAdapter.startRealtime`, `requestTotalActivityData`, `bleCommunicate`; `NewBle.writeValue`, `peripheral:didUpdateValueForCharacteristic:` (FFF7). |
| **Exact log lines added** | See section 3 above; prefix `[Bracelet Plugin]`, `[Bracelet iOS]`, `[Bracelet NewBle]`. |
| **Smallest fix to test first** | **startRealtime(2) once on connect/start; only requestTotalActivityData() every 2 s from timer.** (Flutter-only change; no native change required for this test.) |

After you run with the new logs, use section 4 to classify A/B/C/D and then refine the fix (e.g. add native delay (4) if needed).
