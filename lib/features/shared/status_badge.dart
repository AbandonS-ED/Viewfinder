import 'package:flutter/material.dart';

import '../../domain/camera_workflow_state.dart';
import 'app_theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.state});

  final CameraWorkflowState state;

  @override
  Widget build(BuildContext context) {
    final color = workflowColor(state);
    final label = cameraWorkflowStateTitle(state);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppThemeRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
