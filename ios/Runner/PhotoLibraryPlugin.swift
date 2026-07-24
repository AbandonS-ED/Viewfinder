import Flutter
import Photos

class PhotoLibraryPlugin {
  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "viewfinder/photo_library",
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "requestPermission":
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
          let str: String = switch status {
          case .authorized: "authorized"
          case .limited: "limited"
          case .denied: "denied"
          case .restricted: "restricted"
          case .notDetermined: "denied"
          @unknown default: "denied"
          }
          result(str)
        }
      case "exportFile":
        guard let args = call.arguments as? [String: Any],
              let filePath = args["filePath"] as? String else {
          result(FlutterError(code: "BAD_ARGS", message: nil, details: nil))
          return
        }
        let fileURL = URL(fileURLWithPath: filePath)
        PHPhotoLibrary.shared().performChanges {
          PHAssetCreationRequest.creationRequestForAssetFromImage(atFileURL: fileURL)
        } completionHandler: { success, error in
          if success {
            result(nil)
          } else {
            result(FlutterError(code: "EXPORT_FAILED", message: error?.localizedDescription, details: nil))
          }
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
