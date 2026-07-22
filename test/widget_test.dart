import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:viewfinder/main.dart';

void main() {
  testWidgets('App 启动 smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ViewfinderApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}