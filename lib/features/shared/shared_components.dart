import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/active_download_progress.dart';
import '../../domain/camera_workflow_state.dart';
import 'app_theme.dart';
import 'formatters.dart' as fmt;
import 'viewfinder_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final t = ViewfinderTheme.of(context);
    return Text(
      title,
      style: GoogleFonts.dmMono(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: t.tm,
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
    final t = ViewfinderTheme.of(context);
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
                color: t.t1,
              ),
            ),
          ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: t.surfaceElevated,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: t.shadow,
                blurRadius: 18,
                offset: const Offset(0, 8),
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
    final t = ViewfinderTheme.of(context);
    return SizedBox(
      width: expands ? double.infinity : null,
      child: GestureDetector(
        onTap: enabled
            ? () {
                Haptics.impactLight();
                onPressed();
              }
            : null,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: expands ? 20 : 18,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: enabled ? t.btn : t.surfaceMuted,
            borderRadius: BorderRadius.circular(AppThemeRadius.pill),
          ),
          child: Row(
            mainAxisSize: expands ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: t.btnT),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: enabled ? t.btnT : t.t2,
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
    final t = ViewfinderTheme.of(context);
    final fg = foreground ?? t.t1;
    return SizedBox(
      width: expands ? double.infinity : null,
      child: GestureDetector(
        onTap: enabled
            ? () {
                Haptics.impactLight();
                onPressed();
              }
            : null,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: expands ? 20 : 18,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: t.surfaceElevated,
            borderRadius: BorderRadius.circular(AppThemeRadius.pill),
            border: Border.all(color: t.bdr),
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
                  color: enabled ? fg : t.t2,
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
    final t = ViewfinderTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 16, color: t.t2),
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
                color: t.t1,
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
    final t = ViewfinderTheme.of(context);
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
                color: t.aS,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.fractionCompleted,
            backgroundColor: t.surfaceMuted,
            valueColor: AlwaysStoppedAnimation(t.aS),
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

  static void impactLight() {
    HapticFeedback.lightImpact();
  }

  static void impactMedium() {
    HapticFeedback.mediumImpact();
  }

  static void impactHeavy() {
    HapticFeedback.heavyImpact();
  }

  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Android 用 vibrate，iOS 上 HapticFeedback 没有原生对应
  static void vibrate() {
    HapticFeedback.vibrate();
  }

  static void notificationSuccess() => vibrate();
  static void notificationWarning() => vibrate();
  static void notificationError() => vibrate();
}

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
        // 用 Color.lerp 在 surfaceMuted ↔ controlBg 之间循环
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