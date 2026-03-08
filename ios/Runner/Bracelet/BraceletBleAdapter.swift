import Foundation
import Flutter
import CoreBluetooth

/// Owns NewBle + BleSDK_J2208A; implements MyBleDelegate.
/// Forwards all data to all active event sinks (supports multiple listeners so main + inner screens keep receiving).
final class BraceletBleAdapter: NSObject {
    private let newBle = NewBle.sharedManager()
    private let sdk = BleSDK_J2208A.sharedManager()
    /// Multiple sinks so BraceletScreen and inner screens (Stress, BP) all receive events. onCancel removes last (LIFO).
    private var eventSinks: [FlutterEventSink] = []
    private let sinkLock = NSLock()
    private var discoveredPeripherals: [UUID: CBPeripheral] = [:]
    private let queue = DispatchQueue(label: "com.24digi.bracelet.adapter")
    #if DEBUG
    private var _requestTotalActivityCallCount: Int = 0
    private var _bleNotifyReceiveCount: Int = 0
    #endif

    static let serviceUUID = "FFF0"
    static let sendCharUUID = "FFF6"
    static let recCharUUID = "FFF7"

    override init() {
        super.init()
        newBle?.delegate = self
        newBle?.setUpCentralManager()
    }

    func setEventSink(_ sink: @escaping FlutterEventSink) {
        sinkLock.lock()
        defer { sinkLock.unlock() }
        eventSinks.append(sink)
    }

    func clearEventSink() {
        sinkLock.lock()
        defer { sinkLock.unlock() }
        if !eventSinks.isEmpty {
            eventSinks.removeLast()
        }
    }

    private func emit(_ event: String, data: [String: Any]) {
        let envelope: [String: Any] = [
            "event": event,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "data": data
        ]
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.sinkLock.lock()
            let sinks = self.eventSinks
            self.sinkLock.unlock()
            for sink in sinks {
                sink(envelope)
            }
        }
    }

    // MARK: - Commands

    func scan() {
        guard let central = newBle?.centralManage else { return }
        // Scan with no service filter to discover all BLE devices (bracelet may not advertise FFF0 in ad).
        let services: [CBUUID]? = nil
        if central.state == .poweredOn {
            newBle?.startScanning(withServices: services)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self = self, (self.newBle?.centralManage?.state ?? .unknown) == .poweredOn else { return }
                self.newBle?.startScanning(withServices: nil)
            }
        }
    }

    func stopScan() {
        newBle?.stopscan()
    }

    func getRetrievedDevices() -> [[String: Any]] {
        guard let central = newBle?.centralManage else { return [] }
        let uuids = [CBUUID(string: Self.serviceUUID)]
        let list = central.retrieveConnectedPeripherals(withServices: uuids)
        return list.map { p in
            [
                "identifier": p.identifier.uuidString,
                "name": p.name ?? ""
            ]
        }
    }

    /// Current connection state so Flutter can restore UI without reconnecting.
    func getConnectionState() -> [String: Any] {
        guard let p = newBle?.activityPeripheral else {
            return ["connected": false]
        }
        let connected = (p.state == .connected)
        return [
            "connected": connected,
            "identifier": p.identifier.uuidString,
            "name": p.name ?? ""
        ]
    }

    func connect(identifier: String) {
        guard let uuid = UUID(uuidString: identifier) else { return }
        if let p = discoveredPeripherals[uuid] {
            newBle?.connectDevice(p)
            return
        }
        if let central = newBle?.centralManage {
            let uuids = [CBUUID(string: Self.serviceUUID)]
            let list = central.retrieveConnectedPeripherals(withServices: uuids)
            if let p = list.first(where: { $0.identifier == uuid }) {
                newBle?.connectDevice(p)
                return
            }
        }
        emit("connectionState", data: ["state": "failed", "error": "Peripheral not found"])
    }

    func connectPeripheral(_ peripheral: CBPeripheral) {
        newBle?.connectDevice(peripheral)
    }

    func startRealtime(type: Int8) {
        #if DEBUG
        print("[Bracelet iOS] startRealtime(\(type)) peripheral=\(newBle?.activityPeripheral?.identifier.uuidString ?? "nil")")
        #endif
        guard let peripheral = newBle?.activityPeripheral else {
            #if DEBUG
            print("[Bracelet iOS] startRealtime EARLY-RETURN no peripheral")
            #endif
            emit("connectionState", data: ["state": "failed", "error": "Not connected"])
            return
        }
        guard let data = sdk?.realTimeData(withType: type) as Data? else {
            #if DEBUG
            print("[Bracelet iOS] startRealtime EARLY-RETURN SDK realTimeData nil")
            #endif
            return
        }
        #if DEBUG
        print("[Bracelet iOS] startRealtime BLE_WRITE \(data.count) bytes")
        #endif
        newBle?.writeValue(Self.serviceUUID, characteristicUUID: Self.sendCharUUID, p: peripheral, data: data)
    }

    func stopRealtime() {
        startRealtime(type: 0)
    }

    /// Request total activity data (today's steps, distance, calories) from the device.
    /// Responses arrive as realtimeData with dataType 25 (TotalActivityData_J2208A).
    func requestTotalActivityData() {
        #if DEBUG
        _requestTotalActivityCallCount += 1
        let callNum = _requestTotalActivityCallCount
        print("[Bracelet iOS] requestTotalActivityData ENTRY call#\(callNum)")
        #endif
        guard let peripheral = newBle?.activityPeripheral else {
            #if DEBUG
            print("[Bracelet iOS] requestTotalActivityData EARLY-RETURN no peripheral")
            #endif
            return
        }
        guard let sdk = sdk else {
            #if DEBUG
            print("[Bracelet iOS] requestTotalActivityData EARLY-RETURN no SDK")
            #endif
            return
        }
        // mode 0 = read from latest position (up to 50 sets). startDate = today at midnight.
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        guard let data = sdk.getTotalActivityData(withMode: 0, withStart: startOfToday) as Data? else {
            #if DEBUG
            print("[Bracelet iOS] requestTotalActivityData EARLY-RETURN getTotalActivityData nil")
            #endif
            return
        }
        #if DEBUG
        print("[Bracelet iOS] requestTotalActivityData BLE_WRITE call#\(callNum) \(data.count) bytes -> device")
        #endif
        newBle?.writeValue(Self.serviceUUID, characteristicUUID: Self.sendCharUUID, p: peripheral, data: data)
    }

    /// Request HRV (and stress) data from the device. Responses arrive as realtimeData with dataType 38 (HRVData_J2208A) or 56 (DeviceMeasurement_HRV).
    /// Starts HRV measurement (type 1), waits 2.5s so the device can begin measuring, then requests historical HRV so the device may respond with type 38/56.
    func requestHRVData() {
        guard let peripheral = newBle?.activityPeripheral else { return }
        guard let sdk = sdk else { return }
        // 1) Start HRV measurement on device so it can produce type 38/56.
        if let onData = sdk.startDeviceMeasurement(withType: 1, isOpen: true) as Data? {
            newBle?.writeValue(Self.serviceUUID, characteristicUUID: Self.sendCharUUID, p: peripheral, data: onData)
        }
        // 2) Request stored HRV after a short delay so the device isn't overwhelmed and has time to accept the start command.
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            guard let self = self,
                  let peripheral = self.newBle?.activityPeripheral,
                  let sdk = self.sdk,
                  let data = sdk.getHRVData(withMode: 0, withStart: startOfToday) as Data? else { return }
            self.newBle?.writeValue(Self.serviceUUID, characteristicUUID: Self.sendCharUUID, p: peripheral, data: data)
        }
    }

    /// Enable automatic SpO2 monitoring on the device. SpO2 values then arrive in type 24 (RealTimeStep) as blood_oxygen / Blood_oxygen.
    /// SDK: StartDeviceMeasurementWithType(3, true) = SpO2 on. Response expected as dataType 57 (DeviceMeasurement_Spo2) or in type 24.
    func startSpo2Monitoring() {
        print("[Bracelet iOS] startSpo2Monitoring() invoked")
        let peripheral = newBle?.activityPeripheral
        print("[Bracelet iOS] peripheral exists = \(peripheral != nil)")
        print("[Bracelet iOS] sdk exists = \(sdk != nil)")
        guard let p = peripheral else {
            print("[Bracelet iOS] startSpo2Monitoring() SKIP: no peripheral (not connected)")
            return
        }
        guard let sdk = sdk else {
            print("[Bracelet iOS] startSpo2Monitoring() SKIP: SDK nil")
            return
        }
        guard let data = sdk.startDeviceMeasurement(withType: 3, isOpen: true) as Data? else {
            print("[Bracelet iOS] startSpo2Monitoring() SKIP: startDeviceMeasurement(withType: 3, isOpen: true) returned nil")
            return
        }
        newBle?.writeValue(Self.serviceUUID, characteristicUUID: Self.sendCharUUID, p: p, data: data)
        print("[Bracelet iOS] startSpo2Monitoring() SDK command SENT bytes=\(data.count)")
    }

    /// Stop SpO2 measurement. SDK: StartDeviceMeasurementWithType(3, false). Call when leaving SpO2 screen.
    func stopSpo2Monitoring() {
        guard let p = newBle?.activityPeripheral, let sdk = sdk else { return }
        guard let data = sdk.startDeviceMeasurement(withType: 3, isOpen: false) as Data? else { return }
        newBle?.writeValue(Self.serviceUUID, characteristicUUID: Self.sendCharUUID, p: p, data: data)
    }

    /// Request manual SpO2 history. Responses arrive as realtimeData with dataType 43 (ManualSpo2Data_J2208A).
    func requestManualSpo2History() {
        guard let peripheral = newBle?.activityPeripheral, let sdk = sdk else { return }
        let startOfToday = Calendar.current.startOfDay(for: Date())
        guard let data = sdk.getManualSpo2Data(withMode: 0, withStart: startOfToday) as Data? else { return }
        newBle?.writeValue(Self.serviceUUID, characteristicUUID: Self.sendCharUUID, p: peripheral, data: data)
    }

    /// Request automatic SpO2 history. Responses arrive as realtimeData with dataType 42 (AutomaticSpo2Data_J2208A).
    func requestAutomaticSpo2History() {
        guard let peripheral = newBle?.activityPeripheral, let sdk = sdk else { return }
        let startOfToday = Calendar.current.startOfDay(for: Date())
        guard let data = sdk.getAutomaticSpo2Data(withMode: 0, withStart: startOfToday) as Data? else { return }
        newBle?.writeValue(Self.serviceUUID, characteristicUUID: Self.sendCharUUID, p: peripheral, data: data)
    }

    /// Start PPG measurement. Device may respond with ppgResult (type 70) or ECG result (type 52) containing blood pressure.
    func startPpgMeasurement() {
        guard let peripheral = newBle?.activityPeripheral else { return }
        guard let sdk = sdk else { return }
        guard let data = sdk.ppg(withMode: 1, ppgStatus: 0) as Data? else { return }
        newBle?.writeValue(Self.serviceUUID, characteristicUUID: Self.sendCharUUID, p: peripheral, data: data)
    }

    /// Request activity mode (sport sessions) data from the device. Responses arrive as realtimeData with dataType 30 (ActivityModeData_J2208A).
    func requestActivityModeData() {
        guard let peripheral = newBle?.activityPeripheral else { return }
        guard let sdk = sdk else { return }
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        guard let data = sdk.getActivityModeData(withMode: 0, withStart: startOfToday) as Data? else { return }
        newBle?.writeValue(Self.serviceUUID, characteristicUUID: Self.sendCharUUID, p: peripheral, data: data)
    }

    /// Request sleep data from the device. Responses arrive as realtimeData with dataType 27 (DetailSleepData_J2208A).
    func requestSleepData() {
        guard let peripheral = newBle?.activityPeripheral else {
            emit("realtimeData", data: ["dataType": 27, "dataEnd": true, "dicData": ["_debug": "no peripheral"]])
            return
        }
        guard let sdk = sdk else { return }
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        // SDK may use withStart: or withStartDate: depending on bridge
        guard let data = sdk.getDetailSleepData(withMode: 0, withStart: startOfToday) as Data? else {
            emit("realtimeData", data: ["dataType": 27, "dataEnd": true, "dicData": ["_debug": "SDK getDetailSleepData returned nil"]])
            return
        }
        newBle?.writeValue(Self.serviceUUID, characteristicUUID: Self.sendCharUUID, p: peripheral, data: data)
    }

    func disconnect() {
        newBle?.disconnect()
    }
}

// MARK: - MyBleDelegate

extension BraceletBleAdapter: MyBleDelegate {
    func connectSuccessfully() {
        emit("connectionState", data: ["state": "connected", "error": NSNull()])
    }

    func disconnect(_ error: Error?) {
        #if DEBUG
        _requestTotalActivityCallCount = 0
        _bleNotifyReceiveCount = 0
        #endif
        let msg: Any = error?.localizedDescription as Any? ?? NSNull()
        emit("connectionState", data: ["state": "disconnected", "error": msg])
    }

    func scan(with peripheral: CBPeripheral!, advertisementData: [String : Any]!, rssi: NSNumber!) {
        let localName = advertisementData?[CBAdvertisementDataLocalNameKey] as? String
        let name = (peripheral.name ?? localName ?? "").trimmingCharacters(in: .whitespaces)
        discoveredPeripherals[peripheral.identifier] = peripheral
        emit("scanResult", data: [
            "identifier": peripheral.identifier.uuidString,
            "name": name.isEmpty ? "Unknown" : name,
            "rssi": rssi.intValue
        ])
    }

    func connectFailed(withError error: Error?) {
        let msg = error?.localizedDescription ?? "Unknown"
        emit("connectionState", data: ["state": "failed", "error": msg])
    }

    func enableCommunicate() {}

    func bleCommunicate(with peripheral: CBPeripheral!, data: Data!) {
        #if DEBUG
        _bleNotifyReceiveCount += 1
        #endif
        guard let d = data else { return }
        // Raw BLE packet logging (before SDK parsing)
        let len = d.count
        let firstByte = len > 0 ? String(format: "%02x", d[0]) : "—"
        let first12 = d.prefix(12).map { String(format: "%02x", $0) }.joined(separator: " ")
        print("[Bracelet iOS] BLE raw len=\(len) firstByte=0x\(firstByte) first12=\(first12)")
        if len >= 2 && d[0] == 0x28 {
            print("[Bracelet iOS] BLE raw 0x28 packet -> secondByte=0x\(String(format: "%02x", d[1]))")
        }
        guard let deviceData = sdk?.dataParsing(with: d) else {
            print("[Bracelet iOS] dataParsing NIL len=\(d.count)")
            return
        }
        let dataType = deviceData.dataType.rawValue
        print("[Bracelet iOS] dataParsing OK dataType=\(dataType)")
        let dataTypeName = "DataType_\(dataType)"
        var dicData: [String: Any] = [:]
        if let dict = deviceData.dicData as? [String: Any] {
            dicData = dict
        }
        if dataType == 42 || dataType == 43 || dataType == 57 {
            print("[Bracelet iOS] SpO2 PACKET dataType=\(dataType) dic=\(dicData)")
        }
        let payload: [String: Any] = [
            "dataType": dataType,
            "dataTypeName": dataTypeName,
            "dicData": dicData,
            "dataEnd": deviceData.dataEnd
        ]
        emit("realtimeData", data: payload)
    }
}
