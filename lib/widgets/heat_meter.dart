// lib/widgets/heat_meter.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeatMeter extends StatelessWidget {
  final int heat;
  final String label;
  final bool compact;

  const HeatMeter({
    super.key,
    required this.heat,
    required this.label,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (heat / 100.0).clamp(0.0, 1.0);
    final color = _colorForHeat(heat);

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$heat',
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF262626), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                'HEAT',
                style: GoogleFonts.oswald(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.robotoMono(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Balken
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withValues(alpha: 0.6), color],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '$heat / 100',
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                _lootBonusLabel(heat),
                style: GoogleFonts.rajdhani(
                  fontSize: 11,
                  color: const Color(0xFF00FF88),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _colorForHeat(int heat) {
    if (heat <= 30) return const Color(0xFF00FF88);
    if (heat <= 70) return const Color(0xFFF59E0B);
    if (heat <= 100) return const Color(0xFFE11D48);
    return const Color(0xFFA855F7);
  }

  String _lootBonusLabel(int heat) {
    if (heat <= 30) return 'Loot x1.00';
    if (heat <= 70) return 'Loot x1.25';
    if (heat <= 100) return 'Loot x1.50';
    return 'Loot x1.75';
  }
}