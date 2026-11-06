// lib/widgets/npc_status_badge.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/player_npc.dart';

class NpcStatusBadge extends StatelessWidget {
  final PlayerNpc npc;

  const NpcStatusBadge({super.key, required this.npc});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = _style();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.robotoMono(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData, String) _style() {
    // Priorität: jailed > busy > exhausted > idle
    if (npc.isJailed) {
      return (const Color(0xFFE11D48), Icons.lock, 'IM KNAST');
    }
    if (npc.isBusy) {
      return (const Color(0xFFF59E0B), Icons.timer, 'IM EINSATZ');
    }
    if (npc.isExhausted) {
      return (const Color(0xFFF59E0B), Icons.battery_alert, 'ERSCHÖPFT');
    }
    switch (npc.status) {
      case 'idle':
        return (const Color(0xFF00FF88), Icons.check_circle, 'BEREIT');
      default:
        return (const Color(0xFFA3A3A3), Icons.help, npc.status.toUpperCase());
    }
  }
}