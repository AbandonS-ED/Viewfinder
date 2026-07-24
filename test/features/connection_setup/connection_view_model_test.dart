import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viewfinder/domain/camera_app_error.dart';
import 'package:viewfinder/domain/camera_session.dart';
import 'package:viewfinder/domain/camera_transport_mode.dart';
import 'package:viewfinder/domain/camera_workflow_state.dart';
import 'package:viewfinder/features/connection_setup/connection_view_model.dart';
import 'package:viewfinder/features/settings/settings_view_model.dart';

import '../../helpers/fake_camera_transport.dart';

void main() {
  group('ConnectionNotifier', () {
    test('build() 从 preferencesStore 读取 config，字段映射正确', () async {
      SharedPreferences.setMockInitialValues({
        'camera_connection_config': jsonEncode({
          'host': '10.0.0.1',
          'port': 15740,
          'transportMode': 'experimentalNikon',
          'autoExportToPhotoLibrary': true,
          'prioritizeJPEGDownloads': false,
        }),
      });
      final sp = await SharedPreferences.getInstance();
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
      ]);
      addTearDown(() => container.dispose());

      final state = container.read(connectionProvider);
      expect(state.hostInput, '10.0.0.1');
      expect(state.portInput, '15740');
      expect(state.transportMode, CameraTransportMode.experimentalNikon);
      expect(state.autoExportToPhotoLibrary, isTrue);
      expect(state.prioritizeJPEGDownloads, isFalse);
      expect(state.workflowState, CameraWorkflowState.waitingForWifi);
      expect(state.activeSession, isNull);
      expect(state.isWorking, isFalse);
    });

    test('connect() 成功 → workflowState 变 connecting 再变 connected，activeSession 非 null', () async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final session = CameraSession(
        id: 'test-1',
        cameraName: 'Test Camera',
        connectedHost: '192.168.1.1',
        port: 15740,
        connectedAt: DateTime.now(),
      );
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
        transportFactoryProvider.overrideWithValue(
          FakeCameraTransportFactory(
            fakeTransport: FakeCameraTransport(sessionToReturn: session),
          ),
        ),
      ]);
      addTearDown(() => container.dispose());

      final notifier = container.read(connectionProvider.notifier);
      expect(container.read(connectionProvider).workflowState, CameraWorkflowState.waitingForWifi);

      final connectFuture = notifier.connect();
      expect(container.read(connectionProvider).isWorking, isTrue);
      expect(container.read(connectionProvider).workflowState, CameraWorkflowState.connecting);

      await connectFuture;

      final state = container.read(connectionProvider);
      expect(state.workflowState, CameraWorkflowState.connected);
      expect(state.activeSession, isNotNull);
      expect(state.activeSession!.cameraName, 'Test Camera');
      expect(state.isWorking, isFalse);
    });

    test('connect() 失败 → workflowState 变 error，lastSummary 写入错误消息', () async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
        transportFactoryProvider.overrideWithValue(
          FakeCameraTransportFactory(
            fakeTransport: FakeCameraTransport(
              errorToThrow: const CameraAppError.networkProbeFailed('超时'),
            ),
          ),
        ),
      ]);
      addTearDown(() => container.dispose());

      final notifier = container.read(connectionProvider.notifier);
      await notifier.connect();

      final state = container.read(connectionProvider);
      expect(state.workflowState, CameraWorkflowState.error);
      expect(state.activeSession, isNull);
      expect(state.isWorking, isFalse);
      expect(state.lastSummary, contains('连接相机失败'));
    });

    test('disconnect() → workflowState 变 waitingForWifi，activeSession = null', () async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final session = CameraSession(
        id: 'test-2',
        connectedAt: DateTime.now(),
      );
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
        transportFactoryProvider.overrideWithValue(
          FakeCameraTransportFactory(
            fakeTransport: FakeCameraTransport(sessionToReturn: session),
          ),
        ),
      ]);
      addTearDown(() => container.dispose());

      final notifier = container.read(connectionProvider.notifier);
      await notifier.connect();
      expect(container.read(connectionProvider).workflowState, CameraWorkflowState.connected);

      await notifier.disconnect();

      final state = container.read(connectionProvider);
      expect(state.workflowState, CameraWorkflowState.waitingForWifi);
      expect(state.activeSession, isNull);
      expect(state.isWorking, isFalse);
    });

    test('setHost / setPort / setTransportMode 修改字段并持久化', () async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
      ]);
      addTearDown(() => container.dispose());

      final notifier = container.read(connectionProvider.notifier);

      notifier.setHost('192.168.0.50');
      expect(container.read(connectionProvider).hostInput, '192.168.0.50');

      notifier.setPort('11570');
      expect(container.read(connectionProvider).portInput, '11570');

      final raw = sp.getString('camera_connection_config');
      expect(raw, isNotNull);
      final saved = jsonDecode(raw!) as Map<String, dynamic>;
      expect(saved['host'], '192.168.0.50');
      expect(saved['port'], 11570);
    });

    test('2026-07-25 v3 fix: connectionProvider 反应式跟随 preferencesProvider (Settings 改 toggle 后 GalleryContainer 立刻看到新值)',
        () async {
      // 回归测试: v1 用 ref.watch(preferencesStoreProvider) 是 stable Provider,
      // 改设置后 connectionProvider 不会更新 → GalleryContainer 下载按钮永远按旧值走
      SharedPreferences.setMockInitialValues({
        'camera_connection_config': jsonEncode({
          'host': '192.168.1.1',
          'port': 15740,
          'transportMode': 'experimentalNikon',
          'autoExportToPhotoLibrary': false,
          'prioritizeJPEGDownloads': false,
        }),
      });
      final sp = await SharedPreferences.getInstance();
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
      ]);
      addTearDown(() => container.dispose());

      expect(container.read(connectionProvider).autoExportToPhotoLibrary, isFalse);
      expect(container.read(connectionProvider).prioritizeJPEGDownloads, isFalse);

      // 修改 preferencesProvider (Settings 页 toggle)
      container.read(preferencesProvider.notifier).setAutoExportToPhotoLibrary(true);
      container.read(preferencesProvider.notifier).setPrioritizeJPEGDownloads(true);

      // connectionProvider 应立即反应 (不需重启 app)
      expect(container.read(connectionProvider).autoExportToPhotoLibrary, isTrue,
          reason: '偏好改动后 connectionProvider 必须立刻反映');
      expect(container.read(connectionProvider).prioritizeJPEGDownloads, isTrue);
    });
  });
}
