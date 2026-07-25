import 'package:flutter/material.dart';

import '../../domain/camera_session.dart';
import '../../domain/camera_workflow_state.dart';
import '../shared/shared_components.dart';
import '../shared/status_badge.dart';
import '../shared/viewfinder_theme.dart';
import 'connection_state.dart' as cs;
import 'hero_title.dart';

class ConnectionPage extends StatelessWidget {
  const ConnectionPage({
    super.key,
    required this.state,
    required this.onConnect,
    required this.onDisconnect,
  });

  final cs.ConnectionState state;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        _heroSection(context),
        const SizedBox(height: 32),
        _statusSection(context),
        const SizedBox(height: 24),
        _actionSection(context),
        if (state.workflowState == CameraWorkflowState.connected &&
            state.activeSession != null) ...[
          const SizedBox(height: 24),
          _readySection(context, state.activeSession!),
        ],
      ],
    );
  }

  Widget _heroSection(BuildContext context) {
    return Column(
      children: [
        LensGlowView(state: state.workflowState),
        const SizedBox(height: 16),
        HeroTitle(state: state.workflowState),
      ],
    );
  }

  Widget _statusSection(BuildContext context) {
    return Column(
      children: [
        StatusBadge(state: state.workflowState),
        const SizedBox(height: 12),
        Text(
          state.lastSummary,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _actionSection(BuildContext context) {
    final t = ViewfinderTheme.of(context);
    if (state.workflowState == CameraWorkflowState.connected) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        if (state.isWorking)
          const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          )
        else
          PrimaryActionButton(
            title: '连接相机',
            icon: Icons.wifi,
            onPressed: onConnect,
          ),
        const SizedBox(height: 8),
        Text(
          _actionHintText(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: t.t2),
        ),
      ],
    );
  }

  /// 底部 Action 区文案随状态切换
  String _actionHintText() {
    switch (state.workflowState) {
      case CameraWorkflowState.waitingForWifi:
        return '请先在相机上启用 Wi-Fi 热点';
      case CameraWorkflowState.connecting:
        return '正在搜索相机…';
      case CameraWorkflowState.loadingPhotos:
        return '正在读取相册…';
      case CameraWorkflowState.downloading:
        return '正在下载照片…';
      case CameraWorkflowState.connected:
        return '已连接';
      case CameraWorkflowState.error:
        return '连接失败，请检查相机 Wi-Fi 设置';
    }
  }

  Widget _readySection(BuildContext context, CameraSession session) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 20,
                color: ViewfinderTheme.of(context).t2,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  session.cameraName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${session.capabilities.length} 张照片',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          PrimaryActionButton(
            title: '重新读取',
            icon: Icons.refresh,
            onPressed: onConnect,
          ),
          const SizedBox(height: 8),
          SecondaryActionButton(
            title: '断开连接',
            onPressed: onDisconnect,
          ),
        ],
      ),
    );
  }
}
