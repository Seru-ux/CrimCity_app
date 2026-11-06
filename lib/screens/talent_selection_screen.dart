// lib/screens/talent_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/npc_detail_controller.dart';
import '../models/npc_talent.dart';

class TalentSelectionScreen extends ConsumerStatefulWidget {
  final String playerNpcId;

  const TalentSelectionScreen({super.key, required this.playerNpcId});

  @override
  ConsumerState<TalentSelectionScreen> createState() =>
      _TalentSelectionScreenState();
}

class _TalentSelectionScreenState extends ConsumerState<TalentSelectionScreen> {
  List<NpcTalent> _choices = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChoices();
  }

  Future<void> _loadChoices() async {
    try {
      final choices = await ref
          .read(npcTalentServiceProvider)
          .fetchTalentChoices(widget.playerNpcId);
      if (mounted) {
        setState(() {
          _choices = choices;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _choose(NpcTalent talent) async {
    final success = await ref
        .read(npcDetailControllerProvider(widget.playerNpcId).notifier)
        .chooseTalent(talent.id);
    if (mounted && success) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'TALENT WÄHLEN',
          style: GoogleFonts.oswald(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFFE11D48)),
      )
          : _error != null
          ? Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
        ),
      )
          : _choices.isEmpty
          ? const Center(
        child: Text(
          'Keine Talente mehr verfügbar.',
          style: TextStyle(color: Colors.white54),
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Wähle eine neue Fähigkeit. Diese Entscheidung ist permanent.',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFA3A3A3),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ..._choices.map((t) => _TalentCard(t: t, onChoose: _choose)),
        ],
      ),
    );
  }
}

class _TalentCard extends StatelessWidget {
  final NpcTalent t;
  final ValueChanged<NpcTalent> onChoose;

  const _TalentCard({required this.t, required this.onChoose});

  @override
  Widget build(BuildContext context) {
    final rarityColor = _rarityColor(t.rarity);

    return InkWell(
      onTap: () => onChoose(t),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: rarityColor.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: rarityColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.name.toUpperCase(),
                    style: GoogleFonts.oswald(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  t.rarity.toUpperCase(),
                  style: GoogleFonts.robotoMono(
                    fontSize: 9,
                    color: rarityColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              t.description,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFA3A3A3),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _rarityColor(String q) {
    switch (q) {
      case 'common': return const Color(0xFFA3A3A3);
      case 'rare': return const Color(0xFF3B82F6);
      case 'epic': return const Color(0xFFA855F7);
      case 'legendary': return const Color(0xFFF59E0B);
      default: return const Color(0xFFA3A3A3);
    }
  }
}