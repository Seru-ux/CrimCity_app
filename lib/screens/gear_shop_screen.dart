// lib/screens/gear_shop_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/npc_detail_controller.dart';
import '../models/npc_gear.dart';
import '../widgets/quality_badge.dart';

class GearShopScreen extends ConsumerStatefulWidget {
  final String playerNpcId;

  const GearShopScreen({super.key, required this.playerNpcId});

  @override
  ConsumerState<GearShopScreen> createState() => _GearShopScreenState();
}

class _GearShopScreenState extends ConsumerState<GearShopScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(npcDetailControllerProvider(widget.playerNpcId).notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(npcDetailControllerProvider(widget.playerNpcId));

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'WAFFEN & AUSRÜSTUNG',
          style: GoogleFonts.oswald(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: state.isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFFE11D48)),
      )
          : ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ...state.availableGear.map(
                (g) => _GearCard(gear: g, npcId: widget.playerNpcId),
          ),
        ],
      ),
    );
  }
}

class _GearCard extends ConsumerWidget {
  final NpcGear gear;
  final String npcId;

  const _GearCard({required this.gear, required this.npcId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF262626), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _iconForSlot(gear.slot),
              color: const Color(0xFFA3A3A3),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        gear.name,
                        style: GoogleFonts.oswald(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    QualityBadge(quality: gear.rarity),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    if (gear.lootBonus > 0) _bonus('Loot', '+${(gear.lootBonus*100).toInt()}%', const Color(0xFF00FF88)),
                    if (gear.successBonus > 0) _bonus('Erfolg', '+${(gear.successBonus*100).toInt()}%', const Color(0xFF00FF88)),
                    if (gear.stealthBonus > 0) _bonus('Stealth', '+${(gear.stealthBonus*100).toInt()}%', const Color(0xFF00FF88)),
                    if (gear.jailRiskMod > 0) _bonus('Jail', '+${(gear.jailRiskMod*100).toInt()}%', const Color(0xFFE11D48)),
                    if (gear.successMalus > 0) _bonus('Mali', '-${(gear.successMalus*100).toInt()}%', const Color(0xFFE11D48)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              final ok = await ref
                  .read(npcDetailControllerProvider(npcId).notifier)
                  .buyGear(gear.id);
              if (ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gekauft!'),
                    backgroundColor: Color(0xFF00FF88),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            child: Text(
              '${(gear.priceCash / 1000).toInt()}k \$',
              style: GoogleFonts.rajdhani(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bonus(String label, String value, Color color) {
    return Text(
      '$label $value',
      style: GoogleFonts.rajdhani(
        fontSize: 11,
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  IconData _iconForSlot(String slot) {
    switch (slot) {
      case 'weapon': return Icons.gps_fixed;
      case 'armor': return Icons.shield;
      case 'gadget': return Icons.build;
      case 'vehicle_upgrade': return Icons.directions_car;
      default: return Icons.help;
    }
  }
}