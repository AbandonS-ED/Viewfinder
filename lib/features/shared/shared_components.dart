import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/active_download_progress.dart';
import '../../domain/camera_workflow_state.dart';
import 'app_theme.dart';
import 'formatters.dart' as fmt;

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.dmMono(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: AppThemeColors.tm,
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  const CustomCard({super.key, this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 2),
            child: Text(
              title!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppThemeColors.t1,
              ),
            ),
          ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppThemeColors.surfaceElevated,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: AppThemeColors.shadow,
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}

class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    super.key,
    required this.title,
    this.icon,
    this.enabled = true,
    this.expands = true,
    required this.onPressed,
  });

  final String title;
  final IconData? icon;
  final bool enabled;
  final bool expands;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expands ? double.infinity : null,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: expands ? 20 : 18,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: enabled ? AppThemeColors.btn : AppThemeColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppThemeRadius.pill),
          ),
          child: Row(
            mainAxisSize: expands ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppThemeColors.btnT),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: enabled ? AppThemeColors.btnT : AppThemeColors.t2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SecondaryActionButton extends StatelessWidget {
  const SecondaryActionButton({
    super.key,
    required this.title,
    this.icon,
    this.enabled = true,
    this.expands = true,
    this.foreground,
    required this.onPressed,
  });

  final String title;
  final IconData? icon;
  final bool enabled;
  final bool expands;
  final Color? foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final fg = foreground ?? AppThemeColors.t1;
    return SizedBox(
      width: expands ? double.infinity : null,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: expands ? 20 : 18,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: AppThemeColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppThemeRadius.pill),
            border: Border.all(color: AppThemeColors.bdr),
          ),
          child: Row(
            mainAxisSize: expands ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: enabled ? fg : AppThemeColors.t2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GridRowItem extends StatelessWidget {
  const GridRowItem({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 16, color: AppThemeColors.t2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppThemeColors.t1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DownloadProgressDetails extends StatelessWidget {
  const DownloadProgressDetails({super.key, required this.progress});

  final ActiveDownloadProgress progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    progress.fileName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '第 ${progress.currentItemNumber} / ${progress.totalItemCount} 项',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              progress.percentageText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppThemeColors.aS,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.fractionCompleted,
            backgroundColor: AppThemeColors.surfaceMuted,
            valueColor: const AlwaysStoppedAnimation(AppThemeColors.aS),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${fmt.fileSize(progress.bytesTransferred)} / ${fmt.fileSize(progress.totalBytes)}',
          style: GoogleFonts.dmMono(
            textStyle: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}

class Haptics {
  Haptics._();

  static void impactLight() {}
  static void impactMedium() {}
  static void impactHeavy() {}
  static void notificationSuccess() {}
  static void notificationWarning() {}
  static void notificationError() {}
}

class ShimmerView extends StatelessWidget {
  const ShimmerView({super.key, this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppThemeColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class LensGlowView extends StatelessWidget {
  const LensGlowView({super.key, required this.state});

  final CameraWorkflowState state;

  @override
  Widget build(BuildContext context) {
    final glowColor = workflowColor(state);
    final isSearching = switch (state) {
      CameraWorkflowState.connecting => true,
      CameraWorkflowState.loadingPhotos => true,
      CameraWorkflowState.downloading => true,
      _ => false,
    };
    final iconColor = state == CameraWorkflowState.connected
        ? AppThemeColors.ok
        : AppThemeColors.t1;

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isSearching)
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: glowColor.withValues(alpha: 0.15),
              ),
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppThemeColors.surfaceElevated,
              boxShadow: [
                BoxShadow(
                  color: AppThemeColors.shadow,
                  blurRadius: 20,
                  offset: Offset(0, 10),
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
