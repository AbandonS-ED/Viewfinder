import 'package:flutter/material.dart';

import '../viewfinder_theme.dart';

/// 自定义 StatusBar 装饰（page 顶部装饰条，不替换系统状态栏）
class StatusBarWidget extends StatelessWidget {
  const StatusBarWidget({
    super.key,
    this.height = 24,
    this.title,
  });

  final double height;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final t = ViewfinderTheme.of(context);
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: t.bg,
        border: Border(
          bottom: BorderSide(color: t.bdr, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: title == null
          ? const SizedBox.shrink()
          : Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.3,
                  color: t.tm,
                ),
              ),
            ),
    );
  }
}