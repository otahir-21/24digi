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
        guard let peripheral = newBle?.activityPeripheral else {
            emit("connectionState", data: ["state": "failed", "error": "Not connected"])
            return
        }
        guard let data = sdk?.realTimeData(withType: type) as Data? else { return }
        newBle?.writeValue(Self.serviceUUID, characteristicUUID: Self.sendCharUUID, p: peripheral, data: data)
    }

    func stopRealtime() {
        startRealtime(type: 0)
    }

    /// Request total activity data (today's steps, distance, calories) from the device.
    /// Responses arrive as realtimeData with dataType 25 (TotalActivityData_J2208A).
    func requestTotalActivityData() {
        guard let peripheral = newBle?.activityPeripheral else { return }
        guard let sdk = sdk else { return }
        // mode 0 = read from latest position (up to 50 sets). startDate = today at midnight.
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        guard let data = sdk.getTotalActivityData(withMode: 0, withStart: startOfToday) as Data? else { return }
        newBle?.writeValue(Self.serviceUUID, characteristicUUID: Self.sendCharUUID, p: peripheral, data: data)
    }

    /// Request HRV (and stress) data from the device. Responses arrive as realtimeData with dataType 38 (HRVData_J2208A).
    func requestHRVData() {
        guard let peripheral = newBle?.activityPeripheral else { return }
        guard let sdk = sdk else { return }
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        guard let data = sdk.getHRVData(withMode: 0, withStart: startOfToday) as Data? else { return }
        newBle?.writeValue(Self.serviceUUID, characteristicUUID: Self.sendCharUUID, p: peripheral, data: data)
    }

    /// Start PPG measurement. Device may respond with ppgResult (type 70) or ECG result (type 52) containing blood pressure.
    func startPpgMeasurement() {
        guard let peripheral = newBle?.activityPeripheral else { return }
        guard let sdk = sdk else { return }
        guard let data = sdk.ppg(withMode: 1, ppgStatus: 0) as Data? else { return }
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
        guard let d = data else { return }
        guard let deviceData = sdk?.dataParsing(with: d) else { return }
        let dataType = deviceData.dataType.rawValue
        let dataTypeName = "DataType_\(dataType)"
        var dicData: [String: Any] = [:]
        if let dict = deviceData.dicData as? [String: Any] {
            dicData = dict
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
