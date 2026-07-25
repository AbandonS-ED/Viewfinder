import 'package:flutter/material.dart';

import '../../shared/app_theme.dart';
import 'haptics.dart';
import '../viewfinder_theme.dart';

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