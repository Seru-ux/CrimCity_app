// lib/screens/crew_dashboard_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/assignment_controller.dart';
import '../controllers/heat_controller.dart';
import '../controllers/npc_controller.dart';
import '../models/npc_assignment.dart';
import '../widgets/heat_meter.dart';
import '../widgets/heist_progress_bar.dart';
import 'heat_screen.dart';
import 'npc_hire_screen.dart';
import 'npc_roster_screen.dart';

class CrewDashboardScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const CrewDashboardScreen({super.key, this.embedded = false});

  @override
  ConsumerState<CrewDashboardScreen> createState() => _CrewDashboardScreenState();
}

class _CrewDashboardScreenState extends ConsumerState<CrewDashboardScreen> {
  static const Color bgDark = Color(0xFF0A0A0A);
  static const Color cardDark = Color(0xFF141414);
  static const Color borderGrey = Color(0xFF262626);
  static const Color bloodRed = Color(0xFFE11D48);
  static const Color gold = Color(0xFFF59E0B);
  static const Color neonGreen = Color(0xFF00FF88);

  Timer? _uiTicker;
  int _tickCounter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(assignmentControllerProvider.notifier).tick();
      await ref.read(npcControllerProvider.notifier).loadAll();
      await ref.read(heatControllerProvider.notifier).load();
      // Stamina-Regeneration direkt beim Start anstoßen
      await ref.read(npcControllerProvider.notifier).tickStamina();
    });

    _uiTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
        _tickCounter++;

        // Alle 5 Sekunden Server-Abfragen (Assignments + Stamina)
        if (_tickCounter % 5 == 0) {
          ref.read(assignmentControllerProvider.notifier).tick();
          ref.read(npcControllerProvider.notifier).tickStamina();
        }
      }
    });
  }

  @override
  void dispose() {
    _uiTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final npcState = ref.watch(npcControllerProvider);
    final heatState = ref.watch(heatControllerProvider);
    final assignState = ref.watch(assignmentControllerProvider);

    if (assignState.running.any((a) => (a.remainingTime?.inSeconds ?? 1) <= 0)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(assignmentControllerProvider.notifier).tick();
      });
    }

    final body = RefreshIndicator(
      onRefresh: () async {
        await ref.read(assignmentControllerProvider.notifier).tick();
        await ref.read(npcControllerProvider.notifier).loadAll();
        await ref.read(heatControllerProvider.notifier).load();
        await ref.read(npcControllerProvider.notifier).tickStamina();
      },
      color: bloodRed,
      backgroundColor: cardDark,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          HeatMeter(heat: heatState.heat, label: heatState.heatLabel),
          const SizedBox(height: 12),
          _quickActions(npcState),
          const SizedBox(height: 16),
          if (assignState.running.isNotEmpty) ...[
            _sectionTitle('LAUFENDE RAUBE'),
            const SizedBox(height: 8),
            ...assignState.running.map(_runningAssignment),
            const SizedBox(height: 12),
          ],
          _sectionTitle('LETZTE ERGEBNISSE'),
          const SizedBox(height: 8),
          if (assignState.resolved.isEmpty)
            _emptyResults()
          else
            ...assignState.resolved.take(10).map(_resolvedAssignment),
        ],
      ),
    );

    if (widget.embedded) {
      return Container(color: bgDark, child: body);
    }

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: cardDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'CREW',
          style: GoogleFonts.oswald(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: body,
    );
  }

  Widget _quickActions(NpcState npcState) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.groups,
            label: 'CREW',
            count: '${npcState.crewCount}/${npcState.crewSlots}',
            color: neonGreen,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NpcRosterScreen()),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _actionButton(
            icon: Icons.person_add,
            label: 'ANHEUERN',
            count: 'MARKT',
            color: bloodRed,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NpcHireScreen()),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _actionButton(
            icon: Icons.local_fire_department,
            label: 'HEAT',
            count: 'SENKEN',
            color: gold,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HeatScreen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required String count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderGrey, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.oswald(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              count,
              style: GoogleFonts.rajdhani(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _runningAssignment(NpcAssignment a) {
    final remaining = a.remainingTime ?? Duration.zero;
    final total = a.finishAt.difference(a.createdAt);
    final progress = total.inSeconds == 0
        ? 1.0
        : (remaining.inSeconds / total.inSeconds).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: HeistProgressBar(
        progress: progress,
        remaining: remaining,
        label: 'RAUB LÄUFT',
      ),
    );
  }

  Widget _resolvedAssignment(NpcAssignment a) {
    final success = a.wasSuccess;
    final color = success ? neonGreen : bloodRed;
    final icon = success ? Icons.check_circle : Icons.cancel;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  success
                      ? 'Erfolg'
                      : (a.wasJailed ? 'Im Knast' : 'Fehlgeschlagen'),
                  style: GoogleFonts.oswald(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  success
                      ? '+${_fmtNum(a.cashGained)} \$${a.wasCrit ? " · CRIT!" : ""}'
                      : 'Teil-Loot: ${_fmtNum(a.cashGained)} \$',
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFFA3A3A3),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyResults() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderGrey, width: 1),
      ),
      child: Center(
        child: Text(
          'Noch keine Raube abgeschlossen.',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFA3A3A3),
            fontSize: 12,
          ),
        ),
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

  String _fmtNum(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}