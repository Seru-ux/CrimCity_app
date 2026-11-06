// lib/widgets/quality_badge.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QualityBadge extends StatelessWidget {
  final String quality;
  final bool large;

  const QualityBadge({super.key, required this.quality, this.large = false});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(quality);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 8 : 5,
        vertical: large ? 3 : 1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        quality.toUpperCase(),
        style: GoogleFonts.robotoMono(
          fontSize: large ? 11 : 9,
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Color _colorFor(String q) {
    switch (q) {
      case 'common':
        return const Color(0xFFA3A3A3);
      case 'rare':
        return const Color(0xFF3B82F6);
      case 'epic':
        return const Color(0xFFA855F7);
      case 'legendary':
        return const Color(0xFFF59E0B);
      case 'mythic':
        return const Color(0xFFE11D48);
      default:
        return const Color(0xFFA3A3A3);
    }
  }
}