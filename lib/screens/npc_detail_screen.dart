// lib/screens/npc_detail_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/npc_detail_controller.dart';
import '../controllers/npc_controller.dart';
import '../models/player_npc.dart';
import '../models/player_npc_gear.dart';
import '../models/player_npc_talent.dart';
import '../widgets/npc_status_badge.dart';
import '../widgets/quality_badge.dart';
import 'gear_shop_screen.dart';
import 'talent_selection_screen.dart';

class NpcDetailScreen extends ConsumerStatefulWidget {
  final String playerNpcId;

  const NpcDetailScreen({super.key, required this.playerNpcId});

  @override
  ConsumerState<NpcDetailScreen> createState() => _NpcDetailScreenState();
}

class _NpcDetailScreenState extends ConsumerState<NpcDetailScreen> {
  static const Color bgDark = Color(0xFF0A0A0A);
  static const Color cardDark = Color(0xFF141414);
  static const Color borderGrey = Color(0xFF262626);
  static const Color bloodRed = Color(0xFFE11D48);
  static const Color gold = Color(0xFFF59E0B);
  static const Color neonGreen = Color(0xFF00FF88);

  Timer? _staminaTicker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(npcDetailControllerProvider(widget.playerNpcId).notifier).load();
    });

    // Stamina-Server-Refresh alle 5s, damit die Werte aktuell bleiben
    _staminaTicker = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      ref
          .read(npcDetailControllerProvider(widget.playerNpcId).notifier)
          .load();
    });
  }

  @override
  void dispose() {
    _staminaTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(npcDetailControllerProvider(widget.playerNpcId));

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: cardDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'CREW-MITGLIED',
          style: GoogleFonts.oswald(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: bloodRed))
          : state.npc == null
          ? Center(
        child: Text(
          'NPC nicht gefunden',
          style: GoogleFonts.oswald(color: Colors.white),
        ),
      )
          : _buildBody(state, state.npc!),
    );
  }

  Widget _buildBody(NpcDetailState state, PlayerNpc npc) {
    return RefreshIndicator(
      onRefresh: () => ref
          .read(npcDetailControllerProvider(widget.playerNpcId).notifier)
          .load(),
      color: bloodRed,
      backgroundColor: cardDark,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildHeader(npc),
          const SizedBox(height: 16),
          _buildStats(npc),
          const SizedBox(height: 12),
          _buildStaminaSection(npc),
          const SizedBox(height: 16),
          _buildProgressBars(npc),
          const SizedBox(height: 16),
          _buildActions(npc),
          const SizedBox(height: 24),
          _sectionTitle('AUSRÜSTUNG (${npc.gear.length}/${npc.gearSlots})'),
          const SizedBox(height: 8),
          _buildGearSlots(npc, state),
          const SizedBox(height: 24),
          _sectionTitle('TALENTE (${npc.talents.length}/${npc.talentSlots})'),
          const SizedBox(height: 8),
          _buildTalentSlots(npc, state),
        ],
      ),
    );
  }

  Widget _buildHeader(PlayerNpc npc) {
    final def = npc.definition;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderGrey, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _roleIcon(def?.role ?? 'muscle'),
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  def?.name ?? 'Unbekannt',
                  style: GoogleFonts.oswald(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    QualityBadge(quality: npc.quality, large: true),
                    const SizedBox(width: 8),
                    NpcStatusBadge(npc: npc),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(PlayerNpc npc) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _statChip(Icons.bolt, 'Skill', '${npc.effectiveSkill}', gold),
        _statChip(Icons.favorite, 'HP', '${npc.hp}/${npc.effectiveMaxHp}', bloodRed),
        _statChip(Icons.psychology, 'Moral', '${npc.morale}/100', neonGreen),
      ],
    );
  }

  Widget _buildStaminaSection(PlayerNpc npc) {
    final current = npc.currentStamina;
    final ratio = npc.staminaRatio;
    final Color color;
    if (npc.isExhausted) {
      color = bloodRed;
    } else if (ratio < 0.5) {
      color = gold;
    } else {
      color = neonGreen;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: npc.isExhausted ? bloodRed.withValues(alpha: 0.5) : borderGrey,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.battery_charging_full, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                    'STAMINA',
                    style: GoogleFonts.oswald(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Text(
                '$current/${npc.maxStamina}',
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: const Color(0xFF1A1A1A),
              color: color,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            npc.isExhausted
                ? 'Erschöpft – regeneriert sich automatisch (+2 pro Minute)'
                : (npc.isFullyRested
                ? 'Voll ausgeruht – bereit für den nächsten Raub'
                : 'Regeneration: +2 pro Minute · noch ~${npc.minutesUntilFull} Min bis voll'),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: const Color(0xFFA3A3A3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFFA3A3A3),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.rajdhani(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBars(PlayerNpc npc) {
    return Column(
      children: [
        _progressBar('XP (Lv. ${npc.level})', npc.xp / (npc.level * 50), gold),
        const SizedBox(height: 8),
        _progressBar('Qualität-Splitter', npc.qualityShards / 100, neonGreen),
      ],
    );
  }

  Widget _progressBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: GoogleFonts.rajdhani(
              color: const Color(0xFFA3A3A3),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFF1A1A1A),
              color: color,
              minHeight: 6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(PlayerNpc npc) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _actionButton(
          icon: Icons.fitness_center,
          label: 'TRAINIEREN (50k)',
          color: gold,
          onTap: () async {
            final ok = await ref
                .read(npcDetailControllerProvider(widget.playerNpcId).notifier)
                .trainNpc();
            _showResult(ok, 'Training erfolgreich', 'Training fehlgeschlagen');
          },
        ),
        if (npc.isInjured)
          _actionButton(
            icon: Icons.healing,
            label: 'HEILEN (100k)',
            color: neonGreen,
            onTap: () async {
              final ok = await ref
                  .read(npcDetailControllerProvider(widget.playerNpcId).notifier)
                  .healNpc();
              _showResult(ok, 'Geheilt', 'Heilung fehlgeschlagen');
            },
          ),
        if (npc.isJailed)
          _actionButton(
            icon: Icons.lock_open,
            label: 'FREIKAUF',
            color: gold,
            onTap: () async {
              final ok = await ref
                  .read(npcControllerProvider.notifier)
                  .buyout(npc.id, currency: 'cash');
              if (ok) {
                ref
                    .read(npcDetailControllerProvider(widget.playerNpcId).notifier)
                    .load();
              }
            },
          ),
        if (npc.quality != 'mythic' && npc.qualityShards >= 100)
          _actionButton(
            icon: Icons.upgrade,
            label: 'QUALITÄT UPGRADE',
            color: const Color(0xFFA855F7),
            onTap: () async {
              final ok = await ref
                  .read(npcDetailControllerProvider(widget.playerNpcId).notifier)
                  .upgradeQuality();
              _showResult(ok, 'Qualität erhöht!', 'Upgrade fehlgeschlagen');
            },
          ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        label,
        style: GoogleFonts.oswald(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget _buildGearSlots(PlayerNpc npc, NpcDetailState state) {
    final gearBySlot = {
      'weapon': <PlayerNpcGear>[],
      'armor': <PlayerNpcGear>[],
      'gadget': <PlayerNpcGear>[],
      'vehicle_upgrade': <PlayerNpcGear>[],
    };

    for (var g in npc.gear) {
      if (g.equipped && g.gear != null) {
        gearBySlot[g.gear!.slot]!.add(g);
      }
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _gearSlot('weapon', gearBySlot['weapon']!, npc),
            _gearSlot('armor', gearBySlot['armor']!, npc),
            _gearSlot('gadget', gearBySlot['gadget']!, npc),
            if (npc.gearSlots >= 4)
              _gearSlot('vehicle_upgrade', gearBySlot['vehicle_upgrade']!, npc),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GearShopScreen(playerNpcId: widget.playerNpcId),
            ),
          ),
          icon: const Icon(Icons.store, size: 16),
          label: Text(
            'ZUM AUSRÜSTUNGS-SHOP',
            style: GoogleFonts.oswald(fontSize: 12, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A1A1A),
            side: const BorderSide(color: borderGrey),
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  Widget _gearSlot(String slot, List<PlayerNpcGear> equipped, PlayerNpc npc) {
    final empty = equipped.isEmpty;
    final gear = empty ? null : equipped.first.gear;

    return InkWell(
      onTap: () {
        if (!empty) {
          ref
              .read(npcDetailControllerProvider(widget.playerNpcId).notifier)
              .unequipGear(equipped.first.id);
        }
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: empty ? const Color(0xFF1A1A1A) : const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: empty ? borderGrey : const Color(0xFF00FF88),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _iconForSlot(slot),
              size: 24,
              color: empty ? const Color(0xFF666666) : const Color(0xFF00FF88),
            ),
            const SizedBox(height: 4),
            Text(
              empty ? 'Leer' : (gear?.name.split(' ').first ?? ''),
              style: GoogleFonts.rajdhani(
                fontSize: 10,
                color: empty ? const Color(0xFF666666) : Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTalentSlots(PlayerNpc npc, NpcDetailState state) {
    return Column(
      children: [
        ...npc.talents.map((t) => _talentTile(t)),
        if (npc.talents.length < npc.talentSlots)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TalentSelectionScreen(
                      playerNpcId: widget.playerNpcId,
                    ),
                  ),
                );
                if (result == true) {
                  ref
                      .read(npcDetailControllerProvider(widget.playerNpcId).notifier)
                      .load();
                }
              },
              icon: const Icon(Icons.add, size: 16),
              label: Text(
                'NEUES TALENT WÄHLEN',
                style: GoogleFonts.oswald(fontSize: 12, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                side: const BorderSide(color: borderGrey),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
      ],
    );
  }

  Widget _talentTile(PlayerNpcTalent t) {
    final talent = t.talent;
    if (talent == null) return const SizedBox();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderGrey),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: gold, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  talent.name,
                  style: GoogleFonts.oswald(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  talent.description,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFA3A3A3),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.oswald(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
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

  IconData _roleIcon(String role) {
    switch (role) {
      case 'driver': return Icons.directions_car;
      case 'muscle': return Icons.fitness_center;
      case 'hacker': return Icons.computer;
      case 'lookout': return Icons.visibility;
      default: return Icons.person;
    }
  }

  void _showResult(bool ok, String successMsg, String errorMsg) {
    if (!mounted) return;
    final err = ref.read(npcDetailControllerProvider(widget.playerNpcId)).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? successMsg : (err ?? errorMsg)),
        backgroundColor: ok ? const Color(0xFF00FF88) : bloodRed,
      ),
    );
    if (!ok) {
      ref
          .read(npcDetailControllerProvider(widget.playerNpcId).notifier)
          .clearError();
    }
  }
}