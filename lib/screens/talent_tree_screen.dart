// lib/screens/talent_tree_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/talent_controller.dart';
import '../models/talent.dart';
import '../models/talent_branch.dart';
import '../models/talent_tree.dart';

// ============================================================
// Farben (Design-System)
// ============================================================
const Color kBg = Color(0xFF0A0A0A);
const Color kCardDark = Color(0xFF141414);
const Color kCardDarker = Color(0xFF1A1A1A);
const Color kBorderGrey = Color(0xFF262626);
const Color kAccentRed = Color(0xFFE11D48);
const Color kMoneyGreen = Color(0xFF00FF88);
const Color kGold = Color(0xFFF59E0B);
const Color kBlue = Color(0xFF3B82F6);
const Color kTextMuted = Color(0xFFA3A3A3);

class TalentTreeScreen extends ConsumerStatefulWidget {
  const TalentTreeScreen({super.key});

  @override
  ConsumerState<TalentTreeScreen> createState() => _TalentTreeScreenState();
}

class _TalentTreeScreenState extends ConsumerState<TalentTreeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(talentControllerProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(talentControllerProvider);

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        title: Text(
          'TALENTE',
          style: GoogleFonts.oswald(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        actions: [
          if (uiState.state != null)
            _PointsChip(points: uiState.state!.talentPoints),
          IconButton(
            tooltip: 'Respec',
            icon: const Icon(Icons.refresh, color: kTextMuted),
            onPressed: uiState.isSubmitting
                ? null
                : () => _showRespecDialog(context, ref, uiState),
          ),
        ],
      ),
      body: _buildBody(uiState),
    );
  }

  Widget _buildBody(TalentUIState uiState) {
    if (uiState.isLoading && uiState.state == null) {
      return const Center(child: CircularProgressIndicator(color: kGold));
    }
    if (uiState.error != null && uiState.state == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: kAccentRed, size: 48),
              const SizedBox(height: 12),
              Text(
                uiState.error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(color: kTextMuted),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kAccentRed),
                onPressed: () =>
                    ref.read(talentControllerProvider.notifier).load(),
                child: Text('Erneut versuchen',
                    style: GoogleFonts.oswald(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final state = uiState.state;
    if (state == null || state.trees.isEmpty) {
      return Center(
        child: Text(
          'Noch keine Talente verfügbar.',
          style: GoogleFonts.plusJakartaSans(color: kTextMuted),
        ),
      );
    }

    final ownTrees = state.trees.where((t) {
      return t.classId == state.classId || t.classId == null;
    }).toList();

    return RefreshIndicator(
      color: kGold,
      backgroundColor: kCardDark,
      onRefresh: () => ref.read(talentControllerProvider.notifier).load(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (uiState.error != null) _buildBanner(uiState.error!, isError: true),
          if (uiState.lastMessage != null)
            _buildBanner(uiState.lastMessage!, isError: false),
          if (uiState.error != null || uiState.lastMessage != null)
            const SizedBox(height: 12),
          ...ownTrees.map((tree) => _buildTree(tree, state)),
        ],
      ),
    );
  }

  Widget _buildBanner(String text, {required bool isError}) {
    final color = isError ? kAccentRed : kMoneyGreen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.warning_amber : Icons.check_circle_outline,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: GoogleFonts.plusJakartaSans(color: color, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildTree(TalentTree tree, TalentState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              tree.name.toUpperCase(),
              style: GoogleFonts.oswald(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: kGold,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Container(height: 1, color: kBorderGrey)),
          ],
        ),
        const SizedBox(height: 4),
        Text(tree.description,
            style: GoogleFonts.plusJakartaSans(color: kTextMuted, fontSize: 12)),
        const SizedBox(height: 12),
        ...tree.branches.map((branch) => _buildBranch(branch, state)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBranch(TalentBranch branch, TalentState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCardDark,
        border: Border.all(color: kBorderGrey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            branch.name,
            style: GoogleFonts.oswald(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          Text(branch.description,
              style: GoogleFonts.plusJakartaSans(color: kTextMuted, fontSize: 11)),
          const SizedBox(height: 10),
          ...branch.talents.map((t) => _buildTalentRow(t, state)),
        ],
      ),
    );
  }

  Widget _buildTalentRow(Talent talent, TalentState state) {
    final canAfford = state.talentPoints > 0;
    final isMaxed = talent.isMaxed;
    final isStarted = talent.isStarted;

    final borderColor = isMaxed
        ? kGold
        : isStarted
        ? kGold.withOpacity(0.6)
        : kBorderGrey;

    return GestureDetector(
      onTap: () => _showTalentDetails(context, talent, state),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMaxed ? kCardDarker : kCardDark,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(10),
          boxShadow: isStarted
              ? [
            BoxShadow(
              color: kGold.withOpacity(0.08),
              blurRadius: 8,
              spreadRadius: 1,
            )
          ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: kBg,
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _iconForEffect(talent.effectType),
                color: isStarted ? kGold : kTextMuted,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          talent.name,
                          style: GoogleFonts.oswald(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (talent.isCross)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: kBlue.withOpacity(0.15),
                            border: Border.all(color: kBlue.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'CROSS',
                            style: GoogleFonts.robotoMono(
                              fontSize: 8,
                              color: kBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _talentEffectText(talent),
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      color: isStarted ? kMoneyGreen : kTextMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildLevelDots(talent),
            const SizedBox(width: 6),
            SizedBox(
              width: 34,
              height: 30,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMaxed ? kCardDarker : kAccentRed,
                  disabledBackgroundColor: kCardDarker,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: (isMaxed || !canAfford || !talent.isUnlocked)
                    ? null
                    : () async {
                  await ref
                      .read(talentControllerProvider.notifier)
                      .unlockOrUpgrade(talent.id);
                },
                child: isMaxed
                    ? const Icon(Icons.check, color: kGold, size: 16)
                    : const Text('+',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelDots(Talent talent) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(talent.maxLevel, (i) {
        final filled = i < talent.playerLevel;
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: filled ? kGold : kBorderGrey,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  String _talentEffectText(Talent talent) {
    final sign = talent.effectPerLevel >= 0 ? '+' : '';
    final percent = (talent.effectPerLevel * 100).toStringAsFixed(0);
    final current = (talent.currentBonus * 100).toStringAsFixed(0);
    if (talent.playerLevel == 0) {
      return '$sign$percent% ${talent.effectLabel} pro Level';
    }
    return '$sign$current% ${talent.effectLabel} '
        '(${talent.playerLevel}/${talent.maxLevel})';
  }

  IconData _iconForEffect(String effectType) {
    switch (effectType) {
      case 'sell_price_mult':
      case 'buy_price_mult':
      case 'docs_sell_bonus':
        return Icons.attach_money;
      case 'heist_loot_mult':
      case 'heist_success_bonus':
        return Icons.local_police;
      case 'heist_speed_bonus':
        return Icons.speed;
      case 'energy_regen_mult':
        return Icons.bolt;
      case 'max_health_bonus':
        return Icons.favorite;
      case 'inventory_bonus':
        return Icons.inventory_2;
      case 'jail_time_reduction':
        return Icons.gavel;
      case 'heat_mult':
        return Icons.local_fire_department;
      case 'crit_chance_bonus':
        return Icons.gps_fixed;
      case 'auction_fee_reduction':
        return Icons.gavel;
      default:
        return Icons.star;
    }
  }

  void _showTalentDetails(BuildContext context, Talent talent, TalentState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: kBorderGrey),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_iconForEffect(talent.effectType), color: kGold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    talent.name,
                    style: GoogleFonts.oswald(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Text(
                  'T${talent.tier}',
                  style: GoogleFonts.robotoMono(
                    color: kGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              talent.description,
              style: GoogleFonts.plusJakartaSans(
                color: kTextMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            _detailRow('Aktuell', '${(talent.currentBonus * 100).toStringAsFixed(0)}%'),
            _detailRow('Nächstes Level', '${(talent.nextBonus * 100).toStringAsFixed(0)}%'),
            _detailRow('Level', '${talent.playerLevel} / ${talent.maxLevel}'),
            if (talent.requiresTalent1 != null)
              _detailRow('Benötigt', '${talent.requiresTalent1} Lv. ${talent.requiresLevel1}'),
            if (talent.reqStrength > 0) _detailRow('Stärke', '${talent.reqStrength}'),
            if (talent.reqDexterity > 0) _detailRow('Geschick', '${talent.reqDexterity}'),
            if (talent.reqEndurance > 0) _detailRow('Ausdauer', '${talent.reqEndurance}'),
            if (talent.reqCharisma > 0) _detailRow('Charisma', '${talent.reqCharisma}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentRed,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: talent.isMaxed || state.talentPoints < 1
                    ? null
                    : () async {
                  Navigator.pop(context);
                  await ref
                      .read(talentControllerProvider.notifier)
                      .unlockOrUpgrade(talent.id);
                },
                child: Text(
                  talent.isMaxed ? 'MAXIMUM ERREICHT' : 'VERBESSERN (1 Punkt)',
                  style: GoogleFonts.oswald(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text('$label: ',
              style: GoogleFonts.plusJakartaSans(color: kTextMuted, fontSize: 12)),
          Text(value,
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }

  void _showRespecDialog(BuildContext context, WidgetRef ref, TalentUIState uiState) {
    final state = uiState.state;
    if (state == null) return;

    final isFree = !state.hasUsedFreeRespec;
    final canPayCoins = state.crimCoins >= 500;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: kBorderGrey),
        ),
        title: Text(
          'TALENTE ZURÜCKSETZEN',
          style: GoogleFonts.oswald(
            color: Colors.white,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isFree
                  ? 'Dein erster Respec ist kostenlos.'
                  : 'Kosten: 500 CrimCoins ODER \$1.000.000.',
              style: GoogleFonts.plusJakartaSans(color: kTextMuted, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Abbrechen', style: GoogleFonts.oswald(color: kTextMuted)),
          ),
          if (isFree)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kMoneyGreen),
              onPressed: () async {
                Navigator.pop(context);
                await ref.read(talentControllerProvider.notifier).respec(payment: 'coins');
              },
              child: Text('Kostenlos',
                  style: GoogleFonts.oswald(color: Colors.black, fontWeight: FontWeight.w700)),
            )
          else ...[
            if (canPayCoins)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kGold),
                onPressed: () async {
                  Navigator.pop(context);
                  await ref.read(talentControllerProvider.notifier).respec(payment: 'coins');
                },
                child: Text('500 Coins',
                    style: GoogleFonts.oswald(color: Colors.black, fontWeight: FontWeight.w700)),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kAccentRed),
              onPressed: () async {
                Navigator.pop(context);
                await ref.read(talentControllerProvider.notifier).respec(payment: 'money');
              },
              child: Text('\$1.000.000',
                  style: GoogleFonts.oswald(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}

class _PointsChip extends StatelessWidget {
  final int points;
  const _PointsChip({required this.points});

  @override
  Widget build(BuildContext context) {
    final active = points > 0;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: active ? kAccentRed.withOpacity(0.15) : kCardDark,
        border: Border.all(color: active ? kAccentRed : kBorderGrey),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium,
              color: active ? kAccentRed : kTextMuted, size: 16),
          const SizedBox(width: 6),
          Text('$points',
              style: GoogleFonts.rajdhani(
                color: active ? kAccentRed : kTextMuted,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              )),
        ],
      ),
    );
  }
}