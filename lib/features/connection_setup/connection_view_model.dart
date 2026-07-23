import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/camera_app_error.dart';
import '../../domain/camera_connection_config.dart';
import '../../domain/camera_transport_mode.dart';
import '../../domain/camera_workflow_state.dart';
import '../../protocol/camera_transport_factory.dart';
import '../settings/settings_view_model.dart';
import 'connection_state.dart';

final transportFactoryProvider = Provider<CameraTransportFactory>((ref) {
  return CameraTransportFactory();
});

final connectionProvider =
    NotifierProvider<ConnectionNotifier, ConnectionState>(ConnectionNotifier.new);

class ConnectionNotifier extends Notifier<ConnectionState> {
  @override
  ConnectionState build() {
    final prefs = ref.watch(preferencesStoreProvider);
    final config = prefs.loadConnectionConfig();
    return ConnectionState(
      hostInput: config.host,
      portInput: config.port.toString(),
      transportMode: config.transportMode,
      autoExportToPhotoLibrary: config.autoExportToPhotoLibrary,
      prioritizeJPEGDownloads: config.prioritizeJPEGDownloads,
    );
  }

  Future<void> connect() async {
    final host = state.hostInput.trim();
    final portRaw = state.portInput.trim();
    if (host.isEmpty) {
      state = state.copyWith(
        workflowState: CameraWorkflowState.error,
        isWorking: false,
        lastSummary: '请输入相机 IP（默认 192.168.1.1）',
      );
      return;
    }
    final port = int.tryParse(portRaw);
    if (port == null || port <= 0 || port > 65535) {
      state = state.copyWith(
        workflowState: CameraWorkflowState.error,
        isWorking: false,
        lastSummary: '端口格式无效（1-65535），默认是 15740',
      );
      return;
    }
    state = state.copyWith(
      isWorking: true,
      workflowState: CameraWorkflowState.connecting,
      lastSummary: '正在连接 $host:$port…',
    );
    try {
      final factory = ref.read(transportFactoryProvider);
      final config = CameraConnectionConfig(
        host: host,
        port: port,
        transportMode: state.transportMode,
        autoExportToPhotoLibrary: state.autoExportToPhotoLibrary,
        prioritizeJPEGDownloads: state.prioritizeJPEGDownloads,
      );
      final transport = factory.makeTransport();
      final session = await transport.connect(config: config);
      state = state.copyWith(
        workflowState: CameraWorkflowState.connected,
        activeSession: session,
        isWorking: false,
        lastSummary: '已连接到 ${session.cameraName}',
      );
    } on CameraAppError catch (e) {
      state = state.copyWith(
        workflowState: CameraWorkflowState.error,
        isWorking: false,
        lastSummary: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        workflowState: CameraWorkflowState.error,
        isWorking: false,
        lastSummary: e.toString(),
      );
    }
  }

  Future<void> disconnect() async {
    final session = state.activeSession;
    if (session == null) {
      state = state.copyWith(
        workflowState: CameraWorkflowState.waitingForWifi,
        activeSession: null,
        isWorking: false,
        lastSummary: '相机未连接。',
      );
      return;
    }
    final factory = ref.read(transportFactoryProvider);
    final transport = factory.makeTransport();
    await transport.disconnect(session);
    state = state.copyWith(
      workflowState: CameraWorkflowState.waitingForWifi,
      activeSession: null,
      isWorking: false,
      lastSummary: '已断开。需要重新连接时，点击"连接相机"。',
    );
  }

  void setHost(String host) {
    state = state.copyWith(hostInput: host);
    unawaited(_persist());
  }

  void setPort(String port) {
    state = state.copyWith(portInput: port);
    unawaited(_persist());
  }

  void setTransportMode(CameraTransportMode mode) {
    state = state.copyWith(transportMode: mode);
    unawaited(_persist());
  }

  void setAutoExportToPhotoLibrary(bool value) {
    state = state.copyWith(autoExportToPhotoLibrary: value);
    unawaited(_persist());
  }

  void setPrioritizeJPEGDownloads(bool value) {
    state = state.copyWith(prioritizeJPEGDownloads: value);
    unawaited(_persist());
  }

  Future<void> _persist() async {
    final prefs = ref.read(preferencesStoreProvider);
    final port = int.tryParse(state.portInput) ?? 15740;
    await prefs.saveConnectionConfig(
      CameraConnectionConfig(
        host: state.hostInput,
        port: port,
        transportMode: state.transportMode,
        autoExportToPhotoLibrary: state.autoExportToPhotoLibrary,
        prioritizeJPEGDownloads: state.prioritizeJPEGDownloads,
      ),
    );
  }
}
