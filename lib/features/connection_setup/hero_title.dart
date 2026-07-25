import 'package:flutter/material.dart';

import '../../../domain/camera_workflow_state.dart';
import '../shared/viewfinder_theme.dart';

/// hero 标题状态机：根据 workflow state 切换 6 个状态文案
class HeroTitleStateMachine {
  const HeroTitleStateMachine._();

  /// 取当前状态的 hero 标题
  static String titleFor(CameraWorkflowState state) {
    switch (state) {
      case CameraWorkflowState.waitingForWifi:
        return 'Viewfinder';
      case CameraWorkflowState.connecting:
        return '搜索相机…';
      case CameraWorkflowState.loadingPhotos:
        return '读取相册…';
      case CameraWorkflowState.downloading:
        return '下载照片…';
      case CameraWorkflowState.connected:
        return '已连接';
      case CameraWorkflowState.error:
        return '连接失败';
    }
  }

  /// hero 副标题（state 解释）
  static String subtitleFor(CameraWorkflowState state) {
    switch (state) {
      case CameraWorkflowState.waitingForWifi:
        return '准备好后点连接';
      case CameraWorkflowState.connecting:
        return '正在握手';
      case CameraWorkflowState.loadingPhotos:
        return '正在遍历相机内相册';
      case CameraWorkflowState.downloading:
        return '后台传输照片中';
      case CameraWorkflowState.connected:
        return '可以开始传输';
      case CameraWorkflowState.error:
        return '请检查相机 Wi-Fi';
    }
  }
}

/// HeroSection 标题：随状态切换文案 + 淡入淡出
class HeroTitle extends StatelessWidget {
  const HeroTitle({super.key, required this.state});

  final CameraWorkflowState state;

  @override
  Widget build(BuildContext context) {
    final t = ViewfinderTheme.of(context);
    final title = HeroTitleStateMachine.titleFor(state);
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.15),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          ),
          child: Text(
            title,
            key: ValueKey(title),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: t.t1,
            ),
          ),
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Text(
            HeroTitleStateMachine.subtitleFor(state),
            key: ValueKey('subtitle_${state.name}'),
            style: TextStyle(fontSize: 13, color: t.t2),
          ),
        ),
      ],
    );
  }
}