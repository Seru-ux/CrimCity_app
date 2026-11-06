// lib/widgets/heist_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/heist.dart';

class HeistCard extends StatelessWidget {
  final Heist heist;
  final VoidCallback? onTap;
  final Widget? trailing;

  const HeistCard({
    super.key,
    required this.heist,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF262626), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFE11D48).withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _iconForKey(heist.icon),
                    color: const Color(0xFFE11D48),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        heist.name,
                        style: GoogleFonts.oswald(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ab Lv. ${heist.minLevel}',
                        style: GoogleFonts.rajdhani(
                          fontSize: 11,
                          color: const Color(0xFFA3A3A3),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            if (heist.description != null) ...[
              const SizedBox(height: 8),
              Text(
                heist.description!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFFA3A3A3),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            // Stats
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                _chip(Icons.bolt, '${heist.energyCost} Energie',
                    const Color(0xFFF59E0B)),
                _chip(Icons.timer, heist.durationLabel, const Color(0xFF3B82F6)),
                _chip(Icons.paid, heist.cashRangeLabel,
                    const Color(0xFF00FF88)),
                _chip(Icons.person_search, heist.requiredRoleLabel,
                    const Color(0xFFA3A3A3)),
              ],
            ),
            if (heist.drops.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: heist.drops.map((d) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: const Color(0xFF262626), width: 1),
                    ),
                    child: Text(
                      '${d.itemName} (${d.chanceLabel})',
                      style: GoogleFonts.robotoMono(
                        fontSize: 9,
                        color: const Color(0xFFA3A3A3),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.rajdhani(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  IconData _iconForKey(String key) {
    switch (key) {
      case 'local_gas_station':
        return Icons.local_gas_station;
      case 'diamond':
        return Icons.diamond;
      case 'account_balance':
        return Icons.account_balance;
      case 'local_pharmacy':
        return Icons.local_pharmacy;
      case 'casino':
        return Icons.casino;
      case 'directions_boat':
        return Icons.directions_boat;
      default:
        return Icons.local_police;
    }
  }
}