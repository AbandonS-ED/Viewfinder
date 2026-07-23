import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/domain/camera_app_error.dart';
import 'package:viewfinder/features/app_shell/app_shell_view_model.dart';

void main() {
  group('AppShellNotifier', () {
    test('setGlobalActivityTitle / dismissAlert / showAlert 状态切换', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final notifier = container.read(appShellProvider.notifier);

      expect(container.read(appShellProvider).globalActivityTitle, isNull);
      expect(container.read(appShellProvider).isShowingGlobalActivity, isFalse);

      notifier.setGlobalActivityTitle('加载中…');
      expect(container.read(appShellProvider).globalActivityTitle, '加载中…');
      expect(container.read(appShellProvider).isShowingGlobalActivity, isTrue);

      notifier.setGlobalActivityTitle(null);
      expect(container.read(appShellProvider).globalActivityTitle, isNull);

      notifier.showAlert(title: '错误', message: '网络超时');
      expect(container.read(appShellProvider).alertContext, isNotNull);
      expect(container.read(appShellProvider).alertContext!.title, '错误');
      expect(container.read(appShellProvider).alertContext!.message, '网络超时');

      notifier.dismissAlert();
      expect(container.read(appShellProvider).alertContext, isNull);
    });

    test('appendLog FIFO 30 条上限', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final notifier = container.read(appShellProvider.notifier);

      for (var i = 1; i <= 35; i++) {
        notifier.appendLog('log $i');
      }

      final log = container.read(appShellProvider).activityLog;
      expect(log.length, 30);
      expect(log.first.message, 'log 35');
      expect(log.last.message, 'log 6');
    });

    test('handleError 接受普通 Error → 写入 log + 显示 alert', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final notifier = container.read(appShellProvider.notifier);
      final result = notifier.handleError(StateError('boom'));

      expect(result, 'Bad state: boom');

      final log = container.read(appShellProvider).activityLog;
      expect(log.length, 1);
      expect(log.first.message, 'Bad state: boom');

      final alert = container.read(appShellProvider).alertContext;
      expect(alert, isNotNull);
      expect(alert!.message, 'Bad state: boom');
    });

    test('handleError 接受 CameraAppError → 用 error.message', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final notifier = container.read(appShellProvider.notifier);
      final result = notifier.handleError(
        const CameraAppError.networkProbeFailed('连接超时'),
      );

      expect(result, contains('连接相机失败'));

      final log = container.read(appShellProvider).activityLog;
      expect(log.length, 1);
      expect(log.first.message, contains('连接相机失败'));

      final alert = container.read(appShellProvider).alertContext;
      expect(alert, isNotNull);
      expect(alert!.message, contains('连接相机失败'));
    });
  });
}
