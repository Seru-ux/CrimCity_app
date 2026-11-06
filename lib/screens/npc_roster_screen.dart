// lib/screens/npc_roster_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/npc_controller.dart';
import '../models/player_npc.dart';
import '../widgets/npc_card.dart';
import 'npc_detail_screen.dart';
import 'npc_hire_screen.dart';

class NpcRosterScreen extends ConsumerStatefulWidget {
  const NpcRosterScreen({super.key});

  @override
  ConsumerState<NpcRosterScreen> createState() => _NpcRosterScreenState();
}

class _NpcRosterScreenState extends ConsumerState<NpcRosterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(npcControllerProvider.notifier).loadCrew();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(npcControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'MEINE CREW',
          style: GoogleFonts.oswald(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${state.crewCount}/${state.crewSlots}',
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  color: state.isCrewFull
                      ? const Color(0xFFE11D48)
                      : const Color(0xFF00FF88),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: state.isCrewFull
          ? null
          : FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NpcHireScreen()),
        ).then((_) =>
            ref.read(npcControllerProvider.notifier).loadCrew()),
        backgroundColor: const Color(0xFFE11D48),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'ANHEUERN',
          style: GoogleFonts.oswald(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(npcControllerProvider.notifier).loadCrew(),
        color: const Color(0xFFE11D48),
        backgroundColor: const Color(0xFF141414),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(NpcState state) {
    if (state.isLoading && state.myCrew.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE11D48)),
      );
    }

    if (state.myCrew.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          const Icon(Icons.groups, color: Color(0xFFA3A3A3), size: 64),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Deine Crew ist leer',
              style: GoogleFonts.oswald(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Heuere NPCs an, um Raube zu starten.',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFA3A3A3),
                fontSize: 13,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      itemCount: state.myCrew.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final npc = state.myCrew[index];
        return NpcCard.crew(
          npc: npc,
          trailing: npc.isJailed ? _buyoutButton(npc) : null,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NpcDetailScreen(playerNpcId: npc.id),
            ),
          ).then((_) => ref.read(npcControllerProvider.notifier).loadCrew()),
        );
      },
    );
  }

  Widget _buyoutButton(PlayerNpc npc) {
    return ElevatedButton(
      onPressed: () => _confirmBuyout(npc),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE11D48),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Text(
        'FREIKAUF',
        style: GoogleFonts.oswald(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Future<void> _confirmBuyout(PlayerNpc npc) async {
    final currency = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        title: Text(
          'Freikauf',
          style: GoogleFonts.oswald(color: Colors.white, fontSize: 18),
        ),
        content: Text(
          'Mit welcher Währung möchtest du ${npc.definition?.name ?? "diesen NPC"} freikaufen?',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFA3A3A3),
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text('ABBRECHEN',
                style: GoogleFonts.oswald(color: const Color(0xFFA3A3A3))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cash'),
            child: Text('BARGELD',
                style: GoogleFonts.oswald(color: const Color(0xFF00FF88))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'crimcoins'),
            child: Text('CRIMCOINS',
                style: GoogleFonts.oswald(color: const Color(0xFFF59E0B))),
          ),
        ],
      ),
    );

    if (currency == null) return;
    final success = await ref
        .read(npcControllerProvider.notifier)
        .buyout(npc.id, currency: currency);
    if (!mounted) return;
    if (success) {
      _snack('NPC freigekauft', const Color(0xFF00FF88));
    } else {
      final err = ref.read(npcControllerProvider).error ?? 'Fehler';
      _snack(err, const Color(0xFFE11D48));
      ref.read(npcControllerProvider.notifier).clearError();
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.plusJakartaSans()),
        backgroundColor: color.withValues(alpha: 0.9),
      ),
    );
  }
}