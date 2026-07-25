import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/features/connection_setup/connection_container.dart';

import 'helpers/test_app.dart';

void main() {
  testWidgets('T1: 4 Tab 启动后渲染首页 ConnectionContainer 不抛异常',
      (tester) async {
    await initTestEnv();
    await tester.pumpWidget(
      buildTestApp(Scaffold(body: ConnectionContainer())),
    );
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}