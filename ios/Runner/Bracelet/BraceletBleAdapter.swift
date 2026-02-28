import Foundation
import Flutter
import CoreBluetooth

/// Owns NewBle + BleSDK_J2208A; implements MyBleDelegate.
/// Forwards all data to eventSink on main thread.
final class BraceletBleAdapter: NSObject {
    private let newBle = NewBle.shared()
    private let sdk = BleSDK_J2208A.shared()
    private var eventSink: FlutterEventSink?
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
        eventSink = sink
    }

    func clearEventSink() {
        eventSink = nil
    }

    private func emit(_ event: String, data: [String: Any]) {
        let envelope: [String: Any] = [
            "event": event,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "data": data
        ]
        DispatchQueue.main.async { [weak self] in
            self?.eventSink?(envelope)
        }
    }

    // MARK: - Commands

    func scan() {
        newBle?.startScanning(withServices: nil)
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

    func connect(identifier: String) {
        guard let uuid = UUID(uuidString: identifier) else { return }
        if let p = discoveredPeripherals[uuid] {
            newBle?.connect(p)
            return
        }
        if let central = newBle?.centralManage {
            let uuids = [CBUUID(string: Self.serviceUUID)]
            let list = central.retrieveConnectedPeripherals(withServices: uuids)
            if let p = list.first(where: { $0.identifier == uuid }) {
                newBle?.connect(p)
                return
            }
        }
        emit("connectionState", data: ["state": "failed", "error": "Peripheral not found"])
    }

    func connectPeripheral(_ peripheral: CBPeripheral) {
        newBle?.connect(peripheral)
    }

    func startRealtime(type: Int8) {
        guard let peripheral = newBle?.activityPeripheral else {
            emit("connectionState", data: ["state": "failed", "error": "Not connected"])
            return
        }
        guard let data = sdk?.realTimeData?(withType: type) as Data? else { return }
        newBle?.writeValue(Self.serviceUUID, characteristicUUID: Self.sendCharUUID, p: peripheral, data: data)
    }

    func stopRealtime() {
        startRealtime(type: 0)
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
        let msg = error?.localizedDescription ?? NSNull()
        emit("connectionState", data: ["state": "disconnected", "error": msg])
    }

    func scan(with peripheral: CBPeripheral!, advertisementData: [String : Any]!, rssi: NSNumber!) {
        discoveredPeripherals[peripheral.identifier] = peripheral
        let name = peripheral.name ?? ""
        emit("scanResult", data: [
            "identifier": peripheral.identifier.uuidString,
            "name": name,
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
        guard let deviceData = sdk?.dataParsing?(with: d) else { return }
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
