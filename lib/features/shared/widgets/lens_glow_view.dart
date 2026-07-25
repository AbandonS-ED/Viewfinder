import 'package:flutter/material.dart';

import '../../../domain/camera_workflow_state.dart';
import '../app_theme.dart';
import '../viewfinder_theme.dart';

/// 连接页中央的光圈。`isSearching=true` 时（connecting/loadingPhotos/downloading）1.4s 周期脉冲
class LensGlowView extends StatefulWidget {
  const LensGlowView({super.key, required this.state});

  final CameraWorkflowState state;

  @override
  State<LensGlowView> createState() => _LensGlowViewState();
}

class _LensGlowViewState extends State<LensGlowView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;
  late final Animation<double> _alpha;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    _alpha = Tween<double>(begin: 0.06, end: 0.22).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ViewfinderTheme.of(context);
    final state = widget.state;
    final glowColor = workflowColor(state);
    final isSearching = switch (state) {
      CameraWorkflowState.connecting => true,
      CameraWorkflowState.loadingPhotos => true,
      CameraWorkflowState.downloading => true,
      _ => false,
    };
    final iconColor =
        state == CameraWorkflowState.connected ? t.ok : t.t1;

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isSearching)
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) {
                return Container(
                  width: 140 * _scale.value,
                  height: 140 * _scale.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: glowColor.withValues(alpha: _alpha.value),
                  ),
                );
              },
            )
          else
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: glowColor.withValues(alpha: 0.08),
              ),
            ),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.surfaceElevated,
              boxShadow: [
                BoxShadow(
                  color: t.shadow,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          Icon(
            state == CameraWorkflowState.connected
                ? Icons.camera_alt
                : Icons.camera_alt_outlined,
            size: 38,
            color: iconColor,
          ),
        ],
      ),
    );
  }
}