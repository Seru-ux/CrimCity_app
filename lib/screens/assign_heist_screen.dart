// lib/screens/assign_heist_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/assignment_controller.dart';
import '../controllers/heist_browser_controller.dart';
import '../controllers/npc_controller.dart';
import '../models/heist.dart';
import '../models/player_npc.dart';
import '../widgets/heist_card.dart';
import '../widgets/risk_selector.dart';

class AssignHeistScreen extends ConsumerStatefulWidget {
  final Heist heist; // Der gewählte Heist wird jetzt direkt übergeben

  const AssignHeistScreen({super.key, required this.heist});

  @override
  ConsumerState<AssignHeistScreen> createState() => _AssignHeistScreenState();
}

class _AssignHeistScreenState extends ConsumerState<AssignHeistScreen> {
  final Set<String> _selectedNpcIds = {};
  int _riskLevel = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Lade die eigene Crew
      ref.read(npcControllerProvider.notifier).loadCrew();
    });
  }

  @override
  Widget build(BuildContext context) {
    final npcState = ref.watch(npcControllerProvider);
    final assignState = ref.watch(assignmentControllerProvider);

    // Nur NPCs anzeigen, die verfügbar sind (idle)
    final availableNpcs = npcState.myCrew.where((n) => n.isIdle).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'CREW AUSWÄHLEN',
          style: GoogleFonts.oswald(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildHeistHeader(),
          Expanded(
            child: availableNpcs.isEmpty
                ? Center(
              child: Text(
                'Keine NPCs verfügbar (alle beschäftigt oder im Knast).',
                style: GoogleFonts.oswald(color: const Color(0xFFA3A3A3)),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: availableNpcs.length,
              itemBuilder: (context, index) {
                final npc = availableNpcs[index];
                final isSelected = _selectedNpcIds.contains(npc.id);

                return Card(
                  color: isSelected ? const Color(0xFF1A0F0F) : const Color(0xFF141414),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFFE11D48) : const Color(0xFF262626),
                      width: 1.5,
                    ),
                  ),
                  child: CheckboxListTile(
                    activeColor: const Color(0xFFE11D48),
                    checkColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    title: Text(
                      npc.definition?.name ?? 'NPC',
                      style: GoogleFonts.oswald(color: Colors.white, fontSize: 16),
                    ),
                    subtitle: Text(
                      'Skill: ${npc.skill} · Rolle: ${npc.definition?.roleLabel ?? "?"}',
                      style: GoogleFonts.rajdhani(color: const Color(0xFFA3A3A3)),
                    ),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedNpcIds.add(npc.id);
                        } else {
                          _selectedNpcIds.remove(npc.id);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          _bottomBar(availableNpcs.length),
        ],
      ),
    );
  }

  Widget _buildHeistHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        border: Border(bottom: BorderSide(color: Color(0xFF262626), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.heist.name.toUpperCase(),
            style: GoogleFonts.oswald(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            'Energie pro NPC: ${widget.heist.energyCost}',
            style: GoogleFonts.rajdhani(color: const Color(0xFFF59E0B), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(int maxNpcs) {
    final assignState = ref.watch(assignmentControllerProvider);
    final bool canStart = _selectedNpcIds.isNotEmpty && !assignState.isLoading;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        border: Border(top: BorderSide(color: Color(0xFF262626), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'RISIKO',
              style: GoogleFonts.oswald(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            RiskSelector(
              selected: _riskLevel,
              onChanged: (v) => setState(() => _riskLevel = v),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canStart ? _startHeist : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  disabledBackgroundColor: const Color(0xFF262626),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: assignState.isLoading
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : Text(
                  'RAUB STARTEN (${_selectedNpcIds.length} NPCs)',
                  style: GoogleFonts.oswald(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startHeist() async {
    // Der AssignmentController muss die neue Gruppen-Funktion aufrufen
    final success = await ref.read(assignmentControllerProvider.notifier).assignGroup(
      heistId: widget.heist.id,
      playerNpcIds: _selectedNpcIds.toList(),
      riskLevel: _riskLevel,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Raub gestartet!', style: GoogleFonts.plusJakartaSans()),
          backgroundColor: const Color(0xFF00FF88).withValues(alpha: 0.9),
        ),
      );
      Navigator.pop(context);
    } else {
      final err = ref.read(assignmentControllerProvider).error ?? 'Fehler';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err, style: GoogleFonts.plusJakartaSans()),
          backgroundColor: const Color(0xFFE11D48).withValues(alpha: 0.9),
        ),
      );
      ref.read(assignmentControllerProvider.notifier).clearError();
    }
  }
}