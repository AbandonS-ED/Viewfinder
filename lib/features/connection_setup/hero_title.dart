import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/camera_workflow_state.dart';
import '../shared/viewfinder_theme.dart';

/// hero 标题状态机：根据 workflow state 切换 6 个状态文案
class HeroTitleStateMachine {
  const HeroTitleStateMachine._();

  /// waitingForWifi 时循环显示的品牌文案（每 3s 切换）
  static const brandTexts = <String>[
    'Viewfinder',
    '取景器',
    '为 Nikon 而生',
  ];

  /// 轮播间隔
  static const brandRotationInterval = Duration(seconds: 3);

  /// 取当前状态的 hero 标题
  ///
  /// waitingForWifi 状态由 [brandIndex] 决定具体显示哪个品牌文案（轮播用），
  /// 其他状态走静态文案。
  static String titleFor(CameraWorkflowState state, {int brandIndex = 0}) {
    if (state == CameraWorkflowState.waitingForWifi) {
      return brandTexts[brandIndex % brandTexts.length];
    }
    switch (state) {
      case CameraWorkflowState.waitingForWifi:
        return brandTexts[0];
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

/// HeroSection 标题：
/// - waitingForWifi 时在 [HeroTitleStateMachine.brandTexts] 间每 3s 轮播
/// - 其他 state 走静态文案 + 淡入淡出切换
class HeroTitle extends StatefulWidget {
  const HeroTitle({super.key, required this.state});

  final CameraWorkflowState state;

  @override
  State<HeroTitle> createState() => _HeroTitleState();
}

class _HeroTitleState extends State<HeroTitle> {
  int _brandIndex = 0;
  Timer? _brandTimer;

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(HeroTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      setState(() => _brandIndex = 0);
      _syncTimer();
    }
  }

  @override
  void dispose() {
    _brandTimer?.cancel();
    super.dispose();
  }

  void _syncTimer() {
    _brandTimer?.cancel();
    if (widget.state == CameraWorkflowState.waitingForWifi) {
      _brandTimer = Timer.periodic(
        HeroTitleStateMachine.brandRotationInterval,
        (_) {
          if (!mounted) return;
          setState(() => _brandIndex = (_brandIndex + 1) %
              HeroTitleStateMachine.brandTexts.length);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ViewfinderTheme.of(context);
    final title = HeroTitleStateMachine.titleFor(
      widget.state,
      brandIndex: _brandIndex,
    );
    final subtitle = HeroTitleStateMachine.subtitleFor(widget.state);
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
            key: ValueKey('title_${widget.state.name}_$_brandIndex'),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: t.t1,
            ),
          ),
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Text(
            subtitle,
            key: ValueKey('subtitle_${widget.state.name}'),
            style: TextStyle(fontSize: 13, color: t.t2),
          ),
        ),
      ],
    );
  }
}