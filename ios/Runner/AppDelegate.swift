import Flutter
import UIKit
import GoogleMaps
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Firebase for phone auth, analytics, etc.
    FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyALIcUt4yKgP6dvG1ufMPCLLQDbaOD8810")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // Register custom bracelet BLE plugin (method + event channel)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "BraceletPlugin") {
      BraceletPlugin.register(with: registrar)
    }
  }
}
