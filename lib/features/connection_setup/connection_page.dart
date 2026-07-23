import 'package:flutter/material.dart';

import '../../domain/camera_session.dart';
import '../../domain/camera_workflow_state.dart';
import '../shared/app_theme.dart';
import '../shared/shared_components.dart';
import '../shared/status_badge.dart';
import 'connection_state.dart' as cs;

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
        Text(
          'Viewfinder',
          style: Theme.of(context).textTheme.displayLarge,
        ),
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
    if (state.isWorking) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }
    if (state.workflowState == CameraWorkflowState.connected) return const SizedBox.shrink();
    return PrimaryActionButton(
      title: '连接相机',
      icon: Icons.wifi,
      onPressed: onConnect,
    );
  }

  Widget _readySection(BuildContext context, CameraSession session) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.camera_alt_outlined, size: 20, color: AppThemeColors.t2),
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
