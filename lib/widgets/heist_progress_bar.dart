// lib/widgets/heist_progress_bar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeistProgressBar extends StatelessWidget {
  final double progress; // 0.0 – 1.0
  final Duration remaining;
  final String label;

  const HeistProgressBar({
    super.key,
    required this.progress,
    required this.remaining,
    this.label = 'RAUB LÄUFT',
  });

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF262626), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timer, size: 12, color: Color(0xFFF59E0B)),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.oswald(
                  fontSize: 11,
                  color: const Color(0xFFF59E0B),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                _fmt(remaining),
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                Container(
                  height: 6,
                  color: const Color(0xFF1A1A1A),
                ),
                FractionallySizedBox(
                  widthFactor: p,
                  child: Container(
                    height: 6,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE11D48), Color(0xFFF59E0B)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes % 60}m';
    }
    if (d.inMinutes > 0) {
      return '${d.inMinutes}m ${d.inSeconds % 60}s';
    }
    return '${d.inSeconds}s';
  }
}