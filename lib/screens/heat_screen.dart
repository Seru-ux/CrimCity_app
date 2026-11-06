// lib/screens/heat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/heat_controller.dart';
import '../models/heat_action.dart';
import '../widgets/heat_meter.dart';

class HeatScreen extends ConsumerStatefulWidget {
  const HeatScreen({super.key});

  @override
  ConsumerState<HeatScreen> createState() => _HeatScreenState();
}

class _HeatScreenState extends ConsumerState<HeatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(heatControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(heatControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'HEAT',
          style: GoogleFonts.oswald(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(heatControllerProvider.notifier).load(),
        color: const Color(0xFFE11D48),
        backgroundColor: const Color(0xFF141414),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            HeatMeter(heat: state.heat, label: state.heatLabel),
            const SizedBox(height: 16),
            Text(
              'HEAT SENKEN',
              style: GoogleFonts.oswald(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            ...state.actions.map(_actionTile),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(HeatAction action) {
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
              ),
            ),
            child: Icon(_iconFor(action.icon),
                color: const Color(0xFF3B82F6), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.name,
                  style: GoogleFonts.oswald(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '-${action.heatReduce} Heat · ${action.costLabel} · ${action.cooldownLabel}',
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFFA3A3A3),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _reduce(action.key),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              'NUTZEN',
              style: GoogleFonts.oswald(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reduce(String key) async {
    final ok = await ref.read(heatControllerProvider.notifier).reduceHeat(key);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Heat gesenkt', style: GoogleFonts.plusJakartaSans()),
          backgroundColor: const Color(0xFF00FF88).withValues(alpha: 0.9),
        ),
      );
    } else {
      final err = ref.read(heatControllerProvider).error ?? 'Fehler';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err, style: GoogleFonts.plusJakartaSans()),
          backgroundColor: const Color(0xFFE11D48).withValues(alpha: 0.9),
        ),
      );
      ref.read(heatControllerProvider.notifier).clearError();
    }
  }

  IconData _iconFor(String key) {
    switch (key) {
      case 'local_police':
        return Icons.local_police;
      case 'hotel':
        return Icons.hotel;
      case 'gavel':
        return Icons.gavel;
      default:
        return Icons.local_fire_department;
    }
  }
}