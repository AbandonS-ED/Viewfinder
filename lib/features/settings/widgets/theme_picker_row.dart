import 'package:flutter/material.dart';

import '../../shared/theme_palette.dart';

class ThemePickerRow extends StatelessWidget {
  const ThemePickerRow({
    super.key,
    required this.selectedPalette,
    required this.onSelect,
  });

  final ThemePalette selectedPalette;
  final void Function(String id) onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: palettes.map((p) {
        final selected = p.id == selectedPalette.id;
        return GestureDetector(
          onTap: () => onSelect(p.id),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: p.a,
                  shape: BoxShape.circle,
                  border: selected
                      ? Border.all(color: p.t1, width: 3)
                      : null,
                ),
                child: selected
                    ? Icon(Icons.check, color: p.btnT, size: 18)
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                p.id,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: selected ? p.t1 : p.t2,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
