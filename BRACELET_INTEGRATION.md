# Bracelet SDK (NewBle + BleSDK_J2208A) – Flutter iOS Integration

## 1. Step-by-step checklist (execution order)

1. **Add SDK to Xcode (no refactor)**
   - Add BleSDK group: point to `SDK/ios/BleSDK` (headers + `libBleSDK.a`).
   - Add NewBle: add `SDK/ios/Ble SDK Demo/NewBle.m` and `NewBle.h` to Runner target.
   - Add `libBleSDK.a` to Runner **Frameworks** and set **Library Search Paths** to `$(PROJECT_DIR)/../../../SDK/ios/BleSDK`.
   - Set **Header Search Paths** to `$(PROJECT_DIR)/../../../SDK/ios/BleSDK` and `$(PROJECT_DIR)/../../../SDK/ios/Ble SDK Demo`.

2. **Bridging header**
   - In `ios/Runner/Runner-Bridging-Header.h` add:
     - `#import "NewBle.h"`
     - `#import "BleSDK_Header_J2208A.h"`
     - `#import "BleSDK_J2208A.h"`
     - `#import "DeviceData_J2208A.h"`

3. **Swift adapter + plugin**
   - Add `ios/Runner/Bracelet/BraceletBleAdapter.swift` (owns SDK, implements `MyBleDelegate`, forwards to EventChannel on main thread).
   - Add `ios/Runner/Bracelet/BraceletPlugin.swift` (MethodChannel + EventChannel, registers with Flutter).

4. **Register plugin**
   - In `AppDelegate.swift`: register `BraceletPlugin` with the Flutter engine (no BLE logic in AppDelegate).

5. **iOS configuration**
   - **Info.plist**: add `NSBluetoothAlwaysUsageDescription` (and optionally `NSBluetoothPeripheralUsageDescription` for older keys).
   - **Xcode**: Runner target → Signing & Capabilities → add **Background Modes** → enable **Bluetooth LE accessories** if you need background BLE.

6. **Flutter side**
   - Add `lib/bracelet/bracelet_channel.dart` (MethodChannel + EventChannel wrapper).
   - Add `lib/bracelet/debug_bracelet_page.dart` (Scan / Connect / Start Realtime / Stop / Disconnect + text log).
   - In `main.dart`: add route to `DebugBraceletPage` (and optional debug entry point).

---

## 2. Exact file/folder additions (no refactors)

| Add | Path |
|-----|------|
| Swift adapter | `ios/Runner/Bracelet/BraceletBleAdapter.swift` |
| Swift plugin | `ios/Runner/Bracelet/BraceletPlugin.swift` |
| Dart channel | `lib/bracelet/bracelet_channel.dart` |
| Debug screen | `lib/bracelet/debug_bracelet_page.dart` |

**Modified (minimal):**

- `ios/Runner/Runner-Bridging-Header.h` – add SDK imports.
- `ios/Runner/Info.plist` – add Bluetooth usage description.
- `ios/Runner/AppDelegate.swift` – one line to register `BraceletPlugin`.
- `lib/main.dart` – add route `/debug-bracelet` → `DebugBraceletPage`.
- `ios/Runner.xcodeproj/project.pbxproj` – add Bracelet group, NewBle.m, libBleSDK.a, header/library search paths, Sources.

**SDK reference (no copy):** Xcode group “BleSDK” and “NewBle” reference existing files under `SDK/ios/`.

---

## 3. iOS configuration

**Info.plist keys**

- `NSBluetoothAlwaysUsageDescription` (required for BLE on iOS 13+): e.g. “Used to connect to your bracelet for health data.”

**Xcode capability (optional)**

- **Background Modes** → **Bluetooth LE accessories** – only if you need BLE in background.

---

## 4. Channel names and event payload

**MethodChannel name:** `com.24digi/bracelet`

**EventChannel name:** `com.24digi/bracelet/events`

**MethodChannel methods**

| Method | Args | Returns / effect |
|--------|------|-------------------|
| `scan` | none | Starts BLE scan; results via event `scanResult` or callback list. |
| `stopScan` | none | Stops scan. |
| `getRetrievedDevices` | none | Returns list of already-connected peripherals (service FFF0). |
| `connect` | `identifier: String` (UUID) | Connects to device by identifier. |
| `startRealtime` | `type: int` (0=off, 1=step, 2=stepWithTemp) | Starts realtime streaming. |
| `stopRealtime` | none | Stops realtime (sends type 0). |
| `disconnect` | none | Disconnects. |

**Event payload envelope (streaming + scan)**

All events use the same envelope shape:

```json
{
  "event": "realtimeData" | "scanResult" | "connectionState",
  "timestamp": "<ISO8601 or millis>",
  "data": { ... }
}
```

- **realtimeData:** `data` = `{ "dataType": 24, "dataTypeName": "RealTimeStep_J2208A", "dicData": { ... }, "dataEnd": false }` (same as `DeviceData_J2208A`: `dataType` int, `dicData` map, `dataEnd` bool).
- **scanResult:** `data` = `{ "identifier": "UUID", "name": "Device Name", "rssi": -60 }`.
- **connectionState:** `data` = `{ "state": "connected" | "disconnected" | "failed", "error": null | "message" }`.

---

## 5. Discovery methods

1. **BLE scanning (SDK)**  
   - `startScanningWithServices:nil` → delegate `scanWithPeripheral:advertisementData:RSSI:` → emit `scanResult` events; MethodChannel `scan` / `stopScan`.

2. **Alternative: retrieve already-connected**  
   - `retrieveConnectedPeripheralsWithServices:@[CBUUID UUIDWithString:@"0xFFF0"]]` → MethodChannel `getRetrievedDevices` returns list of `{ "identifier", "name" }`.  
   - **QR / NFC / WiFi / bind:** Not present in NewBle or BleSDK_J2208A. The demo app has a separate `QiCodeScanningViewController` (QR) for app-level “QR code connection”; the SDK itself has no QR/NFC/WiFi/bind API. So we expose only BLE scan + retrieve; optional stub for a future “discoveryByQR” can return “not implemented” until you add app-level QR handling.

---

## 6. Reconnection

- For now: no auto-reconnect. You can add reconnection hooks later in `BraceletBleAdapter` (e.g. on `Disconnect:` re-call `connectDevice` with last peripheral or identifier).

---

## 7. Thread safety

- EventChannel `eventSink` is invoked only on the main thread (dispatch from delegate callbacks via `DispatchQueue.main.async`).
