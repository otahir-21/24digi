# Native iOS Investigation: Why RealtimeData Stops After First Response

**Confirmed:** Flutter calls `requestTotalActivityData` every 2s. Device responded once (e.g. step=906 at 14:29:11–12). After that, zero new realtimeData events for 16+ seconds despite repeated requests. User walked; steps should have increased.

This doc answers the investigation questions and documents what native code runs, where guards are (or aren’t), and how to interpret the new debug logs.

---

## 1. Does requestTotalActivityData send a BLE command each time, or skip if already pending?

**It sends every time. No skip, no “pending” guard.**

- **BraceletBleAdapter.requestTotalActivityData()** has no lock, no `isRequestPending` flag, no cooldown.
- Each call: checks peripheral → sdk → `sdk.getTotalActivityData(withMode: 0, withStart: startOfToday)` → if non-nil, calls `newBle?.writeValue(..., FFF6, ...)`.
- **NewBle.writeValue** does one `[p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse]` per call. No queue or “skip if busy” in our code.

So every Flutter `requestTotalActivityData()` results in one BLE write to FFF6, provided peripheral and SDK return non-nil data.

**New debug logs:** You will see `[Bracelet iOS] requestTotalActivityData ENTRY call#N` and `requestTotalActivityData BLE_WRITE call#N ... bytes -> device` for every call. If you see call#1, #2, #3, #4... every ~2s, we are sending repeatedly. Counters reset on disconnect.

---

## 2. Does the vendor SDK (BleSDK_J2208A) have a cooldown, rate limit, or “already fetching” guard?

**Unknown from our side; SDK is a closed static library (libBleSDK.a).**

- We only have headers. **BleSDK_J2208A.h** declares `GetTotalActivityDataWithMode:withStartDate:` and `RealTimeDataWithType:`; there is no documented cooldown or “already fetching” in the header.
- Each time we call `sdk.getTotalActivityData(withMode: 0, withStart: startOfToday)` we get a new `NSMutableData*` (or nil). The SDK could internally ignore repeated calls within a time window; we cannot see that without SDK source or vendor docs.
- **Conclusion:** We cannot rule out SDK-side rate limiting. If native logs show **BLE_WRITE SENT** every 2s but **BLE_NOTIFY FFF7** only for the first 1–2 packets, the device is not sending more (device or SDK protocol), not our adapter.

---

## 3. Is there a flag, lock, or boolean in the adapter that prevents re-requesting after first success?

**No.**

- There is no `dataReceivedOnce`, `requestInFlight`, or similar in **BraceletBleAdapter.swift**.
- `_startRealtimeCalledForSession` is Flutter-side (and only affects `startRealtime`, not `requestTotalActivityData`). Native adapter does not track “first response received” or block later requests.

---

## 4. Does startRealtime() need to be called repeatedly, or does it set up a continuous stream? If stream, why does the stream stop?

**SDK docs say it sets up a stream; we call it once per session.**

From **BleSDK_J2208A.h** (RealTimeDataWithType):

- **dataType 0:** off.
- **dataType 1:** “when the number of steps changes, the watch will upload data” (no temperature).
- **dataType 2:** “**fixed one second upload** (data will include temperature)” — 固定一秒钟上传一个数据.

So **startRealtime(2)** is intended to start a **device-driven stream: one upload per second** from the watch. It is not a one-shot request–response. After we send the command once, the device is supposed to keep pushing type 24 (RealTimeStep) every second.

**Why the stream might stop (hypotheses):**

- **Device/firmware:** Only sends a few packets then stops (bug or “first query” behavior).
- **Protocol:** Device might expect a follow-up command or might stop when it also receives **GetTotalActivityData** (mode 0) and sends one type 25 response, then goes idle.
- **Single “session”:** Some firmwares treat the first realtime + total-activity pair as one session and don’t stream beyond that until a new realtime start.

We now call startRealtime(2) only once per session and requestTotalActivityData every 2s. If the device is supposed to stream type 24 every second but we only see one batch, the stream is stopping on the **device** side (or the device never starts a continuous stream after the first total-activity response).

---

## 5. Does the BLE connection stay active after first data? Silent disconnect or idle?

**Our code does not disconnect or disable notifications after first data.**

- **NewBle** enables notify on FFF7 once in `enable` (after discovering characteristics). There is no code that turns notifications off or disconnects after receiving data.
- **CoreBluetooth** will keep calling `peripheral:didUpdateValueForCharacteristic:` for every notification on FFF7. If the peripheral stays connected and sends more notifications, we get more callbacks.
- **Conclusion:** If we see **no** further `[Bracelet NewBle] BLE_NOTIFY FFF7` (and no `bleCommunicate BLE_NOTIFY receive#N`) after the first batch, the **peripheral is not sending** more notifications. That could be “device went idle” or “device disconnected at link layer” (we’d then get a disconnect callback). The new logs will show whether BLE receive callbacks stop.

---

## 6. Delegate callback (didUpdateValue) only once per connection or once per command?

**No. It fires every time the peripheral sends a notification on FFF7.**

- `peripheral:didUpdateValueForCharacteristic:error:` is a standard CoreBluetooth delegate method. It is invoked **each time** the peripheral sends a value update for the subscribed characteristic (FFF7). There is no “only first time” logic in NewBle.m; every received packet triggers the delegate call to `BleCommunicateWithPeripheral:data:` → `bleCommunicate(with:data:)`.
- So if the device sends 10 notifications, we get 10 callbacks. If we only see 1 or 2 callbacks total, the device sent 1 or 2 packets.

---

## 7. Native logs added (debug only)

All under `#if DEBUG` / `#ifdef DEBUG`. Counters reset on disconnect.

| Location | Log |
|----------|-----|
| **requestTotalActivityData** (adapter) | `[Bracelet iOS] requestTotalActivityData ENTRY call#N` |
| **requestTotalActivityData** (adapter) | `[Bracelet iOS] requestTotalActivityData BLE_WRITE call#N X bytes -> device` (when actually writing) |
| **bleCommunicate** (adapter) | `[Bracelet iOS] bleCommunicate BLE_NOTIFY receive#N X bytes` (every BLE receive) |
| **dataParsing** (adapter) | `[Bracelet iOS] dataParsing returned nil ... receive#N` or `dataParsing OK dataType=X dataEnd=Y -> EventChannel EMIT receive#N` |
| **emit** (adapter) | `[Bracelet iOS] EventChannel EMIT realtimeData dataType=X sinks=Y` |
| **NewBle** (existing) | `[Bracelet NewBle] BLE_WRITE FFF6 ...` / `BLE_WRITE SENT` / `[Bracelet NewBle] BLE_NOTIFY FFF7 len=...` |

**How to interpret:**

- **call#1, #2, #3...** every ~2s and **receive#1, #2** then no more **receive#N** → We are sending; BLE only gets 2 packets (e.g. type 24 + 25), then **device stops sending**. Likely device/firmware or protocol (e.g. only one total-activity “session” per realtime start).
- **receive#3, #4...** but **dataParsing returned nil** → Device is sending; SDK parsing fails for later packets (different format or multi-packet).
- **receive#3, #4...** and **dataParsing OK** and **EventChannel EMIT** → Full path works; if Flutter still doesn’t get events, issue is Flutter/stream (already ruled out by your tests).

---

## 8. Vendor SDK header notes (streaming, interval, live vs total)

From **BleSDK_J2208A.h**:

- **RealTimeDataWithType (dataType 2):** “Watch real-time data upload” — **fixed one second upload** (data includes temperature). So there *is* a documented “continuous” mode (type 2 = 1 packet/sec).
- **GetTotalActivityDataWithMode:withStartDate:** Request–response. Mode 0 = read from latest (up to 50 sets). No documented minimum interval before re-querying; no “live step” vs “total activity” distinction in the header — only “total exercise data” and “real-time data upload.”

So:

- **Continuous step updates** are supposed to come from **RealTimeDataWithType(2)** (stream), not from repeatedly calling GetTotalActivityData.
- **Total activity** (type 25) is on-demand; each GetTotalActivityData can return one response (e.g. one set). The device may be designed to answer that once per “session” or to rate-limit; the header doesn’t say.

**Practical implication:** For **live steps** we depend on the **realtime stream (type 24)**. If the device stops that stream after the first batch, we need either a device/firmware fix or a way to “re-start” the stream (e.g. call startRealtime(2) again after some time or after each total-activity response). The 2s polling of requestTotalActivityData alone may not be intended to drive continuous updates.

---

## Summary: What runs on each requestTotalActivityData

1. **Flutter** → MethodChannel `requestTotalActivityData`.
2. **BraceletPlugin** → `adapter.requestTotalActivityData()`.
3. **BraceletBleAdapter.requestTotalActivityData():**
   - Guard: peripheral, sdk, `getTotalActivityData(withMode:0, withStart:startOfToday)` non-nil.
   - No guard for “already pending” or “first response done.”
   - Calls `newBle.writeValue(FFF0, FFF6, peripheral, data)`.
4. **NewBle.writeValue:** Finds FFF0/FFF6, then `[p writeValue:data ... CBCharacteristicWriteWithResponse]`.

So **each** requestTotalActivityData results in **one** BLE write. No native code blocks repeat calls.

---

## Is BLE still receiving packets after the first response?

**Use the new logs:**

- If you see **receive#1, receive#2** (and maybe receive#3) then **no** further **BLE_NOTIFY receive#N** or **BLE_NOTIFY FFF7** while **call#4, #5, #6...** keep appearing → **BLE is not receiving** more packets. The device (or radio) is not sending more notifications after the first batch.
- If you see **receive#3, #4...** → BLE is receiving; then check dataParsing and EventChannel EMIT to see where the pipeline stops.

---

## Most likely cause and fix

**Most likely:** The **device** (or SDK protocol) sends one batch (e.g. type 24 + type 25) in response to the first total-activity request (and possibly the realtime start), then **does not send** more notifications for subsequent GetTotalActivityData commands. So BLE goes quiet after the first response.

**Reasonable fixes to try (in order):**

1. **Re-start realtime stream periodically:** Call **startRealtime(2)** every N seconds (e.g. 10–30) in addition to requestTotalActivityData every 2s, to see if the device resumes streaming type 24. (SDK says type 2 = 1 upload/sec; re-sending the command might restart the stream.)
2. **Rely on realtime stream only for live steps:** Call **startRealtime(2)** once; stop polling total activity so aggressively (e.g. requestTotalActivityData every 30s or on demand). If the device truly streams type 24 every second, we should get updates without repeated GetTotalActivityData. If the stream still stops after one batch, then the device/firmware is not honouring the “fixed one second upload” mode.
3. **Vendor / device:** Ask vendor whether GetTotalActivityData is intended to be polled every 2s and whether RealTimeDataWithType(2) is supposed to keep streaming; and whether there is a known “one response per session” or rate limit.

The new native logs (call#N, receive#N, dataParsing, EventChannel EMIT) will confirm whether we are sending every time and whether BLE receives any packet after the first batch. That will tell us if the next step is re-enabling/refreshing the stream, changing the command mix, or escalating to device/SDK behavior.
