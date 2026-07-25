import 'package:flutter/material.dart';

import '../shared/shared_components.dart';
import '../shared/theme_palette.dart';
import 'widgets/theme_picker_row.dart';

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({
    super.key,
    required this.selectedPalette,
    required this.onSelectTheme,
  });

  final ThemePalette selectedPalette;
  final void Function(String) onSelectTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('外观'),
        const SizedBox(height: 12),
        CustomCard(
          child: ThemePickerRow(
            selectedPalette: selectedPalette,
            onSelect: onSelectTheme,
          ),
        ),
      ],
    );
  }
}
