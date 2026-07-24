import Flutter
import UIKit

class BackgroundDownloadHandler {
  static var currentTaskId: UIBackgroundTaskIdentifier = .invalid

  static func register(channel: FlutterMethodChannel) {
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "begin":
        guard let args = call.arguments as? [String: Any],
              let name = args["name"] as? String else {
          result(FlutterError(code: "BAD_ARGS", message: nil, details: nil))
          return
        }
        currentTaskId = UIApplication.shared.beginBackgroundTask(withName: name) {
          channel.invokeMethod("onExpiration", arguments: nil)
        }
        result(currentTaskId.rawValue)
      case "end":
        guard currentTaskId != .invalid else { result(nil); return }
        UIApplication.shared.endBackgroundTask(currentTaskId)
        currentTaskId = .invalid
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
