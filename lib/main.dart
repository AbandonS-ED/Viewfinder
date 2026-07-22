import 'package:flutter/material.dart';

void main() {
  runApp(const ViewfinderApp());
}

/// 占位 app。Phase 0 仅验证工程能跑起来；真正的 UI 在 Phase 4 写。
class ViewfinderApp extends StatelessWidget {
  const ViewfinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Viewfinder',
      home: Scaffold(
        body: Center(
          child: Text('Viewfinder (取景器) — Phase 0 工程骨架就位'),
        ),
      ),
    );
  }
}