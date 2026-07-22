import 'camera_transport.dart';
import 'experimental_nikon_transport.dart';

class CameraTransportFactory {
  CameraTransport makeTransport() => ExperimentalNikonTransport();
}
