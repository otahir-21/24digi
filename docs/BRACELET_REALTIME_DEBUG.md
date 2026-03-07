# Bracelet Realtime Bug – Trace and Debug

## 1. Where the log lines come from

| Log | File | Method / location |
|-----|------|-------------------|
| `[Bracelet] Request data (1s)` | `lib/screens/bracelet/bracelet_screen.dart` | `_refreshDataFromDevice()` line ~181, inside 1s timer, only when `state['connected'] == true` |
| `[Bracelet] event -> realtimeData` | `lib/screens/bracelet/bracelet_screen.dart` | `_listenRealtime()` subscription callback, when `e.event == 'realtimeData'` (line ~238) |
| `[Bracelet] Latest -> step: ...` | `lib/screens/bracelet/bracelet_screen.dart` | `_refreshDataFromDevice()` lines ~186–196, **after** `await startRealtime` + `await requestTotalActivityData`; reads **current in-memory state** via `_mergedLiveData()` |

So **"Latest" is from cached merged state on the timer**, not from new event data. If you see "Latest" every second with the same step, it means the 1s timer is firing and printing whatever is already in `_realtimeData` / `_totalActivityData`. New `realtimeData` events are not arriving (or very few), so state never updates.

---

## 2. Verified: "Latest" is cached state on timer

- In `_refreshDataFromDevice()` the order is: (1) if connected, print "Request data (1s)", call `startRealtime(2)`, `requestTotalActivityData()`; (2) then **immediately** `live = _mergedLiveData()` and print "Latest -> step: ...". So the print always reflects state **before** any new event from this round of requests. New data would only appear on the **next** timer tick **if** a `realtimeData` event had been received and `applyUpdate()` had run in between. So yes: **"Latest" = old cached merged state printed on timer.**

---

## 3. Are both methods invoked every second?

Yes. In `_refreshDataFromDevice()` when connected we do:

```dart
await _channel.startRealtime(RealtimeType.stepWithTemp);  // type 2
await _channel.requestTotalActivityData();
```

So both are invoked every 1s by the same timer. No branching that would skip one.

---

## 4. Native iOS path (what to inspect)

- **BLE receive:** `NewBle.m` – `peripheral:didUpdateValueForCharacteristic:error:` (line ~322). When characteristic UUID is `REC_CHAR` (FFF7), it calls `[self.delegate BleCommunicateWithPeripheral:peripheral data:characteristic.value]`.
- **Delegate:** `BraceletBleAdapter.swift` – `bleCommunicate(with:data:)` (line ~216). It calls `sdk?.dataParsing(with: d)` then `emit("realtimeData", data: payload)`. If `deviceData` or `dicData` is nil/wrong, we could skip or mis-emit.
- **Emit:** `emit(_:data:)` (line ~39) runs on main queue, locks `eventSinks`, and invokes each sink. If `eventSinks` is empty (e.g. wrong onCancel behavior), nothing receives.
- **EventChannel:** `BraceletPlugin` uses a single `FlutterEventChannel`; `onListen` adds one sink, `onCancel` removes last. For Flutter’s broadcast stream, **onListen is called when listener count goes 0→1, onCancel when 1→0**. So with search then dashboard, we get one sink; when search is replaced, dashboard still has a subscription so listener count stays ≥1 and **onCancel is not called** – so the sink should stay. Still worth logging sink count to be sure.

Checks to do on iOS:

- Is `didUpdateValueForCharacteristic` firing repeatedly when walking? (Add log at start of that block.)
- Is `bleCommunicate(with:data:)` called repeatedly? (Add log.)
- Does `sdk?.dataParsing(with: d)` return non-nil and contain type 24/25? (Log `dataType` / `dicData` or add debug emit.)
- Is `emit("realtimeData", ...)` called and is `eventSinks.count > 0`? (Log before the for loop.)

---

## 5. Device identifier (stale/wrong device)

- Connection state comes from `newBle?.activityPeripheral` (e.g. `1A4F2172-BB6A-A5C5-7F4D-DDC3878A5D6D`).
- Scan results are stored in `discoveredPeripherals` and emitted as `scanResult` with `identifier`.
- Connect is by `connect(identifier: String)` – we use either `discoveredPeripherals[uuid]` or `retrieveConnectedPeripherals(withServices:)`. So we only connect to a peripheral we discovered or that’s already connected with FFF0. If the user tapped a different device in the list, we use that identifier; if they had an old session, we might have a stale identifier in UI but we still call `connect(identifier)` with whatever was selected. So the critical check is: when we connect, is the **peripheral we’re writing to** the same one that receives notifications? Yes – we use `newBle?.activityPeripheral` for both `startRealtime` and `requestTotalActivityData`, and BLE notifications are on that same peripheral. So a “stale identifier” would only matter if we’re connecting to the wrong peripheral (e.g. wrong list item). To verify: log the connected peripheral identifier when we send startRealtime/requestTotalActivityData and when we receive in bleCommunicate; they should match.

---

## 6. Temporary debug logging (exact points)

Add these only in debug builds; remove after finding the failure layer.

### Flutter (bracelet_screen.dart)

- **Before invokeMethod (in _refreshDataFromDevice, right before the two awaits):**
  ```dart
  if (kDebugMode) debugPrint('[Bracelet DBG] about to startRealtime(2) + requestTotalActivityData');
  ```
- **When BraceletEvent received (top of listener, before any return):**
  ```dart
  if (kDebugMode) debugPrint('[Bracelet DBG] event received: ${e.event} dataType=${e.data['dataType']}');
  ```
- **When applyUpdate actually changes step (inside the branch where we set _realtimeData for type 24):**
  ```dart
  if (kDebugMode) debugPrint('[Bracelet DBG] applyUpdate: step updated to ${dicMapCopy['step'] ?? dicMapCopy['Step']}');
  ```

### Flutter (bracelet_channel.dart) – optional

- After `invokeMethod('startRealtime', ...)` and after `invokeMethod('requestTotalActivityData')` return, you could log, but the screen log above is enough to confirm “request sent”.

### iOS BraceletBleAdapter.swift

- **startRealtime:** at the start of `startRealtime(type:)`:
  ```swift
  #if DEBUG
  print("[Bracelet iOS] startRealtime(\(type)) peripheral=\(newBle?.activityPeripheral?.identifier.uuidString ?? "nil")")
  #endif
  ```
- **requestTotalActivityData:** at the start of `requestTotalActivityData()`:
  ```swift
  #if DEBUG
  print("[Bracelet iOS] requestTotalActivityData")
  #endif
  ```
- **bleCommunicate (BLE receive):** at the very start:
  ```swift
  #if DEBUG
  print("[Bracelet iOS] bleCommunicate received \(d?.count ?? 0) bytes")
  #endif
  ```
- **After dataParsing, before emit:**
  ```swift
  #if DEBUG
  print("[Bracelet iOS] emit realtimeData dataType=\(dataType) sinks=\(eventSinks.count)")
  #endif
  ```
- **If deviceData or dicData is nil:** add an else and log so we know when parsing fails.

### iOS NewBle.m (optional)

- In `didUpdateValueForCharacteristic`, when `strUUID isEqualToString:REC_CHAR`:
  ```objc
  NSLog(@"[Bracelet BLE] didUpdateValueForCharacteristic FFF7 length=%lu", (unsigned long)characteristic.value.length);
  ```

Interpretation:

- No `[Bracelet iOS] startRealtime` / `requestTotalActivityData` → method channel not called or wrong channel.
- No `[Bracelet BLE] didUpdateValueForCharacteristic` → device not sending or notifications off.
- `bleCommunicate` never / rarely → BLE not delivering.
- `bleCommunicate` often but no/rare `emit realtimeData` → `dataParsing` returning nil or wrong type.
- `sinks=0` → EventChannel sink was cleared (onCancel with 0 listeners).
- Flutter shows `event received: realtimeData` rarely → native not emitting or Flutter not receiving.

---

## 7. Which layer is failing (decision table)

| Observation | Failing layer |
|-------------|----------------|
| No "[Bracelet DBG] about to startRealtime" every second | Timer or _refreshDataFromDevice not running (e.g. not connected) |
| No "[Bracelet iOS] startRealtime" | Request not sent: Flutter invokeMethod or plugin not registered |
| No "[Bracelet BLE] didUpdateValueForCharacteristic" / no "bleCommunicate received" | BLE response not received (notifications, or device not sending) |
| "bleCommunicate received" often but no "emit realtimeData" or dataType not 24/25 | SDK parsing not producing activity data (nil or other type) |
| "emit realtimeData sinks=0" | EventChannel sink cleared (listener count 0) |
| "emit realtimeData sinks=1" but no "[Bracelet DBG] event received" for realtimeData | Flutter not receiving (stream / isolate issue) |
| "[Bracelet DBG] event received realtimeData" but no "applyUpdate: step updated" | Parser or applyUpdate ignoring fields (e.g. wrong type or key) |
| "applyUpdate: step updated" logs but UI unchanged | UI reading stale state (e.g. wrong key, not rebuilding) |

---

## 8. Root cause candidates (by likelihood)

1. **Device/firmware only sends realtime (type 24) occasionally** (e.g. on step change or every N seconds), not every second. We request every 1s but the band may not reply every second. So we see one or a few events, then nothing until the next time the device decides to send. **Likely.**
2. **Sending startRealtime(2) every second** might put the device in a “reset” or “re-subscribe” mode so it only responds once or throttles. Try starting realtime once when the dashboard appears and only polling `requestTotalActivityData()` every few seconds (or once). **Likely.**
3. **SDK dataParsing** returns nil for some responses (e.g. partial BLE packet, or non-activity packet), so we don’t emit. **Possible.**
4. **EventChannel sink list empty** (e.g. if onCancel is ever called with still-active listeners due to another bug). **Less likely** given broadcast stream semantics; confirm with `sinks=` log.
5. **Connection is to a different peripheral** than the one we’re writing to (wrong identifier). **Unlikely** if we use the same `activityPeripheral` for write and notify.

---

## 9. Fastest fix path (minimal code changes) – APPLIED

- **Debug logs** have been added in Flutter and iOS (see section 6); run and check where the chain stops.
- **Fix applied:** Stop sending `startRealtime(2)` every second; send it only when the dashboard becomes active (already done in `_startRealtimeIfConnected()` and `_requestDataSoonIfConnected()`). In `_refreshDataFromDevice()` the 1s timer now calls **only** `requestTotalActivityData()`. So:
  - Realtime (type 24) is started once (or twice early) when connected; the device may then stream type 24 on its own.
  - Every 1s we only request total activity (type 25), which can refresh steps/distance/calories from the device.
  If the device requires a repeated `startRealtime` to keep streaming type 24, revert this change (call both `startRealtime(2)` and `requestTotalActivityData()` again in `_refreshDataFromDevice()`) and rely on logs to find the real bottleneck.

---

## 10. Exact files and methods to inspect

| Layer | File | Method / area |
|-------|------|-------------------------------|
| Timer / request | `lib/screens/bracelet/bracelet_screen.dart` | `_refreshDataFromDevice()`, `_startRealtimeRefreshTimer()` |
| Channel | `lib/bracelet/bracelet_channel.dart` | `startRealtime()`, `requestTotalActivityData()` |
| Plugin | `ios/Runner/Bracelet/BraceletPlugin.swift` | `handle(_:result:)` cases `startRealtime`, `requestTotalActivityData` |
| Adapter | `ios/Runner/Bracelet/BraceletBleAdapter.swift` | `startRealtime(type:)`, `requestTotalActivityData()`, `bleCommunicate(with:data:)`, `emit(_:data:)` |
| BLE | `ios/Runner/NewBle.m` | `peripheral:didUpdateValueForCharacteristic:error:` (FFF7), `enable`, `notification:on:` |
| Flutter receive | `lib/screens/bracelet/bracelet_screen.dart` | `_listenRealtime()` subscription, `applyUpdate()` |

I can add the temporary debug logs and the “start realtime once” change in the code next if you want.
