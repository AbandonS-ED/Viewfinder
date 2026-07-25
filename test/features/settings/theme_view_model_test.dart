import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viewfinder/features/settings/settings_view_model.dart';
import 'package:viewfinder/features/settings/theme_view_model.dart';
import 'package:viewfinder/features/shared/theme_palette.dart';

void main() {
  group('ThemeNotifier', () {
    test('build() 默认 themeID 为空时返回 amberPalette', () async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
      ]);
      addTearDown(() => container.dispose());

      expect(container.read(themeNotifierProvider), amberPalette);
    });

    test('select(id) 后 state 更新为对应 palette', () async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
      ]);
      addTearDown(() => container.dispose());

      container.read(themeNotifierProvider.notifier).select('forest');
      expect(container.read(themeNotifierProvider), forestPalette);

      container.read(themeNotifierProvider.notifier).select('terr');
      expect(container.read(themeNotifierProvider), terrPalette);
    });

    test('select(id) 持久化到 preferencesProvider.themeID', () async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
      ]);
      addTearDown(() => container.dispose());

      container.read(themeNotifierProvider.notifier).select('forest');
      expect(container.read(preferencesProvider).themeID, 'forest');

      final raw = sp.getString('camera_connection_config');
      expect(raw, isNotNull);
      expect(raw, contains('"themeID":"forest"'));
    });

    test('select(无效 id) 走 fallback amber', () async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
      ]);
      addTearDown(() => container.dispose());

      container.read(themeNotifierProvider.notifier).select('not-a-theme');
      expect(container.read(themeNotifierProvider), amberPalette);
    });
  });
}
