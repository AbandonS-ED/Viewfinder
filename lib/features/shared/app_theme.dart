import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/camera_workflow_state.dart';

class AppThemeColors {
  AppThemeColors._();

  static const bg = Color(0xFFF9F9F8);
  static const card = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF5F5F5);
  static const controlBg = Color(0xFFF2F2F3);
  static const bdr = Color(0x12000000);
  static const div = Color(0x0A000000);
  static const sep = Color(0x14000000);
  static const shadow = Color(0x0D000000);
  static const t1 = Color(0xFF1A1A1A);
  static const t2 = Color(0xFF6B7079);
  static const tm = Color(0xFFB5AFA6);
  static const a = Color(0xFFD4A24E);
  static const aS = Color(0xFFE8B84B);
  static const aL = Color(0xFFF5E6C8);
  static const info = Color(0xFF4069B3);
  static const ok = Color(0xFF5B8C5A);
  static const warn = Color(0xFFD47507);
  static const er = Color(0xFFDB262E);
  static const btn = Color(0xFF1A1A1A);
  static const btnT = Color(0xFFFFFFFF);
}

Color workflowColor(CameraWorkflowState state) {
  switch (state) {
    case CameraWorkflowState.waitingForWifi:
      return AppThemeColors.info;
    case CameraWorkflowState.connecting:
    case CameraWorkflowState.loadingPhotos:
    case CameraWorkflowState.downloading:
      return AppThemeColors.warn;
    case CameraWorkflowState.connected:
      return AppThemeColors.ok;
    case CameraWorkflowState.error:
      return AppThemeColors.er;
  }
}

class AppThemeSpacing {
  AppThemeSpacing._();
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 36;
}

class AppThemeRadius {
  AppThemeRadius._();
  static const double s = 8;
  static const double m = 12;
  static const double l = 18;
  static const double pill = 100;
}

ThemeData amberTheme() {
  final base = ThemeData.light(useMaterial3: true);
  final instrumentSerif = GoogleFonts.instrumentSerifTextTheme(base.textTheme);
  final dmMono = GoogleFonts.dmMonoTextTheme(base.textTheme);
  return base.copyWith(
    scaffoldBackgroundColor: AppThemeColors.bg,
    colorScheme: const ColorScheme.light(
      primary: AppThemeColors.a,
      onPrimary: AppThemeColors.btnT,
      secondary: AppThemeColors.aS,
      surface: AppThemeColors.card,
      error: AppThemeColors.er,
    ),
    textTheme: TextTheme(
      displayLarge: instrumentSerif.headlineLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppThemeColors.t1,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: AppThemeColors.t1,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.normal,
        color: AppThemeColors.t1,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: AppThemeColors.t2,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppThemeColors.t1,
      ),
      labelSmall: dmMono.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppThemeColors.tm,
      ),
    ),
  );
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final c = accent ?? AppThemeColors.t1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppThemeColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppThemeRadius.l),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 16, color: c),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleMedium),
                Text(label, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
