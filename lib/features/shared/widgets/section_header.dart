import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../viewfinder_theme.dart';

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