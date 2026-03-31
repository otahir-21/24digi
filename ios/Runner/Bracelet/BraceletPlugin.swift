import Flutter
import UIKit

/// Registers MethodChannel + EventChannel; keeps all BLE logic in BraceletBleAdapter.
final class BraceletPlugin: NSObject, FlutterPlugin {
    private let adapter = BraceletBleAdapter()

    static func register(with registrar: FlutterPluginRegistrar) {
        let instance = BraceletPlugin()
        let methodChannel = FlutterMethodChannel(
            name: "com.24digi/bracelet",
            binaryMessenger: registrar.messenger()
        )
        methodChannel.setMethodCallHandler(instance.handle(_:result:))

        let eventChannel = FlutterEventChannel(
            name: "com.24digi/bracelet/events",
            binaryMessenger: registrar.messenger()
        )
        eventChannel.setStreamHandler(instance)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "scan":
            adapter.scan()
            result(nil)
        case "stopScan":
            adapter.stopScan()
            result(nil)
        case "getRetrievedDevices":
            let list = adapter.getRetrievedDevices()
            result(list)
        case "getConnectionState":
            result(adapter.getConnectionState())
        case "connect":
            guard let args = call.arguments as? [String: Any],
                  let id = args["identifier"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "identifier required", details: nil))
                return
            }
            adapter.connect(identifier: id)
            result(nil)
        case "startRealtime":
            let type = (call.arguments as? [String: Any])?["type"] as? Int ?? 1
            adapter.startRealtime(type: Int8(truncatingIfNeeded: type))
            result(nil)
        case "stopRealtime":
            adapter.stopRealtime()
            result(nil)
        case "requestTotalActivityData":
            adapter.requestTotalActivityData()
            result(nil)
        case "requestDetailActivityData":
            adapter.requestDetailActivityData()
            result(nil)
        case "requestSleepData":
            adapter.requestSleepData()
            result(nil)
        case "requestActivityModeData":
            adapter.requestActivityModeData()
            result(nil)
        case "requestHRVData":
            adapter.requestHRVData()
            result(nil)
        case "startHeartRateMonitoring":
            adapter.startHeartRateMonitoring()
            result(nil)
        case "startPpgMeasurement":
            adapter.startPpgMeasurement()
            result(nil)
        case "startSpo2Monitoring":
            adapter.startSpo2Monitoring()
            result(nil)
        case "stopSpo2Monitoring":
            adapter.stopSpo2Monitoring()
            result(nil)
        case "startTemperatureMonitoring":
            adapter.startTemperatureMonitoring()
            result(nil)
        case "stopTemperatureMonitoring":
            adapter.stopTemperatureMonitoring()
            result(nil)
        case "requestTemperatureData":
            adapter.requestTemperatureData()
            result(nil)
        case "requestManualSpo2History":
            adapter.requestManualSpo2History()
            result(nil)
        case "requestAutomaticSpo2History":
            adapter.requestAutomaticSpo2History()
            result(nil)
        case "disconnect":
            adapter.disconnect()
            result(nil)
        case "discoveryByQROrOther":
            result("not implemented")
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

extension BraceletPlugin: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        adapter.setEventSink(events)
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        adapter.clearEventSink()
        return nil
    }
}
