import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller = window?.rootViewController as! FlutterViewController
    let bgChannel = FlutterMethodChannel(
      name: "viewfinder/background_download",
      binaryMessenger: controller.binaryMessenger
    )
    BackgroundDownloadHandler.register(channel: bgChannel)
    PhotoLibraryPlugin.register(messenger: controller.binaryMessenger)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
