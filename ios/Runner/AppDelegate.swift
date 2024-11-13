import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let googleMapsApiKey = ProcessInfo.processInfo.environment["GOOGLE_MAP_API_KEY"] {
      GMSServices.provideAPIKey(googleMapsApiKey)
    } else {
      fatalError("Google Maps API Key not found")
      }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
