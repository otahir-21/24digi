# SpO2 native-to-Flutter flow and debug breakpoints

## Chain (exact breakpoints)

1. **Flutter screen**  
   - `BraceletScreen._onConnected()` calls `_channel.startSpo2Monitoring()` (once after connect).  
   - Log: `[Bracelet] _onConnected: calling startSpo2Monitoring()` / `startSpo2Monitoring() done`.

2. **BraceletChannel**  
   - `startSpo2Monitoring()` invokes method `startSpo2Monitoring` on `com.24digi/bracelet`.  
   - Log: `[Bracelet SpO2] startSpo2Monitoring() called -> invoking native` / `native call returned`.

3. **BraceletPlugin (iOS)**  
   - `handle(_:result:)` case `"startSpo2Monitoring"` → `adapter.startSpo2Monitoring()`.  
   - Log: `[Bracelet Plugin] handle startSpo2Monitoring -> adapter.startSpo2Monitoring()`.

4. **BraceletBleAdapter (iOS)**  
   - `startSpo2Monitoring()`: guard peripheral, sdk, then `sdk.startDeviceMeasurement(withType: 3, isOpen: true)`, then `newBle?.writeValue(...)`.  
   - Log: `startSpo2Monitoring() invoked` / `SKIP: no peripheral` | `SKIP: SDK nil` | `SKIP: startDeviceMeasurement returned nil` / `SDK command SENT (N bytes)`.

5. **Device + BLE notify**  
   - Device may send SpO2 on same FFF7 notify. No app code here; if nothing is sent, we never get 42/43/57.

6. **NewBle (Obj-C)**  
   - `peripheral:didUpdateValueForCharacteristic:` for FFF7 → `[delegate BleCommunicateWithPeripheral:data:]`.  
   - All notify data goes to adapter; no filtering.

7. **BraceletBleAdapter.bleCommunicate(with:data:)**  
   - `sdk?.dataParsing(with: d)` → if nil: **not emitted** (log: `dataParsing NIL ... firstBytes=...`).  
   - If non-nil: `dataType = deviceData.dataType.rawValue`, build payload, `emit("realtimeData", data: payload)`.  
   - Log: `dataParsing OK dataType=X` for every packet; `SpO2 PACKET dataType=42|43|57` when SpO2 type.

8. **EventSink**  
   - `emit()` pushes to all `eventSinks` on main queue. No filtering by dataType.

9. **Flutter event listener**  
   - `EventChannel.receiveBroadcastStream()` → `BraceletEvent.fromMap` → screens listen for `event == 'realtimeData'`, use `data['dataType']`, `data['dicData']`.  
   - Log (Spo2Screen): `[SpO2] received event type=X ... parsed spo2=...`.

## Where SpO2 can break

- **No 42/43/57 in Flutter** with logs showing only 24, 26/27, 30, 38, 56 → break is **before** Flutter:
  - **5→6→7**: Device never sends SpO2, or sends in a format the SDK does not parse (then `dataParsing` returns nil; check `dataParsing NIL ... firstBytes=`).
  - **4**: Command not sent: check for `SKIP: no peripheral` or `startDeviceMeasurement returned nil` (no `SDK command SENT`).
- If **native** logs show `SpO2 PACKET dataType=57` but **Flutter** never sees type 57 → break in **8 or 9** (sinks or stream); current code does not filter, so unlikely.

## iOS SpO2 dataType mapping (this app)

| dataType | Source |
|----------|--------|
| **57** | Live SpO2: response to `StartDeviceMeasurementWithType(3, true)` (our `startSpo2Monitoring()`). |
| **42** | Automatic SpO2 history: response to `GetAutomaticSpo2DataWithMode:withStartDate:` (not called by us). |
| **43** | Manual SpO2 history: response to `GetManualSpo2DataWithMode:withStartDate:` (not called by us). |

So **only 57** is expected from our current flow. If the bracelet only pushes SpO2 in **type 24** (realtime step payload) when monitoring is on, then we rely on type 24 containing `blood_oxygen` / `Blood_oxygen`; parser already supports that.

## What to confirm with new logs

1. Flutter: `[Bracelet] _onConnected: calling startSpo2Monitoring()` and `[Bracelet SpO2] startSpo2Monitoring() called` → screen and channel call.
2. iOS: `[Bracelet Plugin] handle startSpo2Monitoring` and `[Bracelet iOS] startSpo2Monitoring() SDK command SENT` → plugin and adapter sent command.
3. iOS: Any `dataParsing NIL` with same firstBytes pattern after starting SpO2 → possible SpO2 packet that SDK doesn’t parse.
4. iOS: Any `SpO2 PACKET dataType=57` (or 42/43) → native received SpO2 and emitted; then Flutter should see that type.
5. If no SpO2 packet ever: device may require wear, manual trigger on device, or delay before first result.
