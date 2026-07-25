import 'package:flutter/material.dart';

import '../../shared/app_theme.dart';
import 'haptics.dart';
import '../viewfinder_theme.dart';

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