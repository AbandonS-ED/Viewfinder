import 'package:flutter/material.dart';

import '../viewfinder_theme.dart';

/// 加载占位闪烁动画。1.4s 周期循环，surfaceMuted ↔ controlBg 之间 Color.lerp
class ShimmerView extends StatefulWidget {
  const ShimmerView({super.key, this.width, this.height});

  final double? width;
  final double? height;

  @override
  State<ShimmerView> createState() => _ShimmerViewState();
}

class _ShimmerViewState extends State<ShimmerView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ViewfinderTheme.of(context);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final v = _ctrl.value;
        final color = Color.lerp(t.surfaceMuted, t.controlBg, v)!;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
  }
}