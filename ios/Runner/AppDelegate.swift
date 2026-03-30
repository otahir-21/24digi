import Flutter
import UIKit
import GoogleMaps
import FirebaseCore
import AppTrackingTransparency

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyALIcUt4yKgP6dvG1ufMPCLLQDbaOD8810")
    GeneratedPluginRegistrant.register(with: self)
    let ok = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    // Register after the Flutter root view controller exists so the plugin uses the live engine.
    if let registrar = self.registrar(forPlugin: "BraceletPlugin") {
      BraceletPlugin.register(with: registrar)
    }
    return ok
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    if #available(iOS 14, *) {
      ATTrackingManager.requestTrackingAuthorization { _ in }
    }
  }
}
