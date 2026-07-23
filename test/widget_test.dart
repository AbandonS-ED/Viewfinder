import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:viewfinder/app.dart';
import 'package:viewfinder/features/settings/settings_view_model.dart';

void main() {
  testWidgets('App 启动 smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sp),
        ],
        child: const ViewfinderApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
