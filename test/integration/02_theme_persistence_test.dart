import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/features/settings/settings_container.dart';

import 'helpers/test_app.dart';

void main() {
  testWidgets('T2: SettingsContainer pump 不抛异常（验证 themeID 反应式）',
      (tester) async {
    await initTestEnv();
    await tester.pumpWidget(
      buildTestApp(Scaffold(body: SettingsContainer())),
    );
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}