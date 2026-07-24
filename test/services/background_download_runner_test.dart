import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/services/background_download_runner.dart';

class _FakeBackgroundRunner implements BackgroundDownloadRunner {
  bool _active = false;

  @override
  Future<void> begin({required String name, void Function()? onExpiration}) async {
    _active = true;
  }

  @override
  Future<void> end() async {
    _active = false;
  }

  @override
  Future<bool> get isActive async => _active;
}

void main() {
  group('BackgroundDownloadRunner 接口', () {
    late _FakeBackgroundRunner runner;

    setUp(() {
      runner = _FakeBackgroundRunner();
    });

    test('begin 激活后台', () async {
      await runner.begin(name: 'test');
      expect(await runner.isActive, isTrue);
    });

    test('end 去激活', () async {
      await runner.begin(name: 'test');
      await runner.end();
      expect(await runner.isActive, isFalse);
    });

    test('重复 begin 不再重新激活', () async {
      await runner.begin(name: 'a');
      await runner.begin(name: 'b');
      expect(await runner.isActive, isTrue);
      await runner.end();
      expect(await runner.isActive, isFalse);
    });
  });
}
