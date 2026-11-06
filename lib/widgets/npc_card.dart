// lib/widgets/npc_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/npc.dart';
import '../models/player_npc.dart';
import 'npc_status_badge.dart';

class NpcCard extends StatelessWidget {
  /// Markt-Modus: NPC-Definition
  final Npc? definition;

  /// Crew-Modus: eigener NPC
  final PlayerNpc? playerNpc;

  final VoidCallback? onTap;
  final Widget? trailing;

  /// Markt-Karte
  NpcCard.market({
    super.key,
    required Npc npc,
    this.onTap,
    this.trailing,
  })  : definition = npc,
        playerNpc = null;

  /// Crew-Karte
  NpcCard.crew({
    super.key,
    required PlayerNpc npc,
    this.onTap,
    this.trailing,
  })  : playerNpc = npc,
        definition = npc.definition;

  bool get _isCrew => playerNpc != null;

  static const Color gold = Color(0xFFF59E0B);
  static const Color bloodRed = Color(0xFFE11D48);
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color grey = Color(0xFFA3A3A3);

  @override
  Widget build(BuildContext context) {
    final def = definition;
    final rarityColor = _rarityColor(def?.rarity ?? 'common');

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: rarityColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: rarityColor.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Icon(
                _iconForRole(def?.role ?? 'muscle'),
                color: rarityColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            // Inhalt
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          def?.name ?? 'Unbekannt',
                          style: GoogleFonts.oswald(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isCrew) NpcStatusBadge(npc: playerNpc!),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        def?.roleLabel ?? '?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: rarityColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          (def?.rarityLabel ?? '').toUpperCase(),
                          style: GoogleFonts.robotoMono(
                            fontSize: 8,
                            color: rarityColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Stats-Zeile
                  Row(
                    children: [
                      _stat(
                        Icons.bolt,
                        _isCrew
                            ? '${playerNpc!.skill}'
                            : '${def?.baseSkill ?? 0}',
                        gold,
                      ),
                      const SizedBox(width: 10),
                      if (_isCrew) ...[
                        _stat(
                          Icons.favorite,
                          '${playerNpc!.hp}/${playerNpc!.maxHp}',
                          bloodRed,
                        ),
                        const SizedBox(width: 10),
                        _stat(
                          Icons.trending_up,
                          'Lv. ${playerNpc!.level}',
                          neonGreen,
                        ),
                      ] else ...[
                        _stat(
                          Icons.favorite,
                          '${def?.baseHp ?? 0}',
                          bloodRed,
                        ),
                        const SizedBox(width: 10),
                        _stat(
                          Icons.paid,
                          def?.formattedHireCost ?? '?',
                          neonGreen,
                        ),
                      ],
                    ],
                  ),
                  // Stamina-Balken (nur Crew, immer sichtbar)
                  if (_isCrew) ...[
                    const SizedBox(height: 8),
                    _staminaBar(playerNpc!),
                  ],
                  // Jail-Info
                  if (_isCrew && playerNpc!.isJailed) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.lock_clock, size: 11, color: bloodRed),
                        const SizedBox(width: 4),
                        Text(
                          'Freikauf: ${_formatNum(playerNpc!.buyoutCost)} \$',
                          style: GoogleFonts.rajdhani(
                            fontSize: 11,
                            color: bloodRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _staminaBar(PlayerNpc npc) {
    final ratio = npc.staminaRatio;
    final Color color;
    if (npc.isExhausted) {
      color = bloodRed;
    } else if (ratio < 0.5) {
      color = gold;
    } else {
      color = neonGreen;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STAMINA',
              style: GoogleFonts.robotoMono(
                fontSize: 8,
                color: grey,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              '${npc.currentStamina}/${npc.maxStamina}',
              style: GoogleFonts.rajdhani(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: const Color(0xFF1A1A1A),
            color: color,
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _stat(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          text,
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  IconData _iconForRole(String role) {
    switch (role) {
      case 'driver':
        return Icons.directions_car;
      case 'muscle':
        return Icons.fitness_center;
      case 'hacker':
        return Icons.computer;
      case 'lookout':
        return Icons.visibility;
      default:
        return Icons.person;
    }
  }

  Color _rarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return const Color(0xFFA3A3A3);
      case 'rare':
        return const Color(0xFF3B82F6);
      case 'epic':
        return const Color(0xFFA855F7);
      case 'legendary':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFA3A3A3);
    }
  }

  String _formatNum(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}