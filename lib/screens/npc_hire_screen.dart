// lib/screens/npc_hire_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/npc_controller.dart';
import '../widgets/npc_card.dart';

class NpcHireScreen extends ConsumerStatefulWidget {
  const NpcHireScreen({super.key});

  @override
  ConsumerState<NpcHireScreen> createState() => _NpcHireScreenState();
}

class _NpcHireScreenState extends ConsumerState<NpcHireScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(npcControllerProvider.notifier).loadAll();
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
          'NPC-MARKT',
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
      body: RefreshIndicator(
        onRefresh: () => ref.read(npcControllerProvider.notifier).loadAll(),
        color: const Color(0xFFE11D48),
        backgroundColor: const Color(0xFF141414),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(NpcState state) {
    if (state.isLoading && state.availableNpcs.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE11D48)),
      );
    }

    if (state.error != null && state.availableNpcs.isEmpty) {
      return _errorView(state.error!);
    }

    if (state.availableNpcs.isEmpty) {
      return _emptyView();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: state.availableNpcs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final npc = state.availableNpcs[index];
        return NpcCard.market(
          npc: npc,
          trailing: _hireButton(npc.id, state),
        );
      },
    );
  }

  Widget _hireButton(String npcId, NpcState state) {
    final disabled = state.isCrewFull || state.isLoading;
    return ElevatedButton(
      onPressed: disabled ? null : () => _confirmHire(npcId),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE11D48),
        disabledBackgroundColor: const Color(0xFF262626),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Text(
        'ANHEUERN',
        style: GoogleFonts.oswald(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Future<void> _confirmHire(String npcId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        title: Text(
          'NPC anheuern?',
          style: GoogleFonts.oswald(color: Colors.white, fontSize: 18),
        ),
        content: Text(
          'Möchtest du diesen NPC wirklich anheuern? Die Kosten werden sofort abgezogen.',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFA3A3A3),
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'ABBRECHEN',
              style: GoogleFonts.oswald(color: const Color(0xFFA3A3A3)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
            ),
            child: Text(
              'ANHEUERN',
              style: GoogleFonts.oswald(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (ok != true) return;
    final success =
    await ref.read(npcControllerProvider.notifier).hire(npcId);
    if (!mounted) return;
    if (success) {
      _showSnack('NPC erfolgreich angeheuert', const Color(0xFF00FF88));
    } else {
      final err = ref.read(npcControllerProvider).error ?? 'Fehler';
      _showSnack(err, const Color(0xFFE11D48));
      ref.read(npcControllerProvider.notifier).clearError();
    }
  }

  Widget _errorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFE11D48), size: 48),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFA3A3A3),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(npcControllerProvider.notifier).loadAll(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
              ),
              child: Text('ERNEUT VERSUCHEN',
                  style: GoogleFonts.oswald(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyView() {
    return ListView(
      children: [
        const SizedBox(height: 100),
        const Icon(Icons.person_off, color: Color(0xFFA3A3A3), size: 48),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Keine NPCs verfügbar',
            style: GoogleFonts.oswald(
              color: const Color(0xFFA3A3A3),
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.plusJakartaSans()),
        backgroundColor: color.withValues(alpha: 0.9),
      ),
    );
  }
}