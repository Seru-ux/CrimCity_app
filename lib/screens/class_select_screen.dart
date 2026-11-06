import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/character_controller.dart';
import '../models/attribute_type.dart';
import '../models/character_class.dart';

class ClassSelectScreen extends ConsumerWidget {
  const ClassSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: Text(
          'Klasse wählen',
          style: GoogleFonts.oswald(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Wähle deine Klasse – endgültig.',
            style: GoogleFonts.oswald(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ...CharacterClass.values.map((c) => _ClassCard(characterClass: c)),
        ],
      ),
    );
  }
}

class _ClassCard extends ConsumerWidget {
  final CharacterClass characterClass;

  const _ClassCard({required this.characterClass});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attrs = characterClass.startingAttributes;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                characterClass.label,
                style: GoogleFonts.oswald(color: Colors.white, fontSize: 22),
              ),
              const Spacer(),
              Text(
                '⭐' * characterClass.difficultyStars,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            characterClass.description,
            style: GoogleFonts.roboto(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          ...attrs.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      e.key.shortLabel,
                      style: GoogleFonts.robotoMono(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: e.value / 6,
                      backgroundColor: const Color(0xFF2A2A2A),
                      color: const Color(0xFFB00020),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${e.value}',
                    style: GoogleFonts.robotoMono(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB00020),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _confirm(context, ref),
              child: Text(
                'WÄHLEN',
                style: GoogleFonts.oswald(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        title: Text(
          'Klasse endgültig wählen?',
          style: GoogleFonts.oswald(color: Colors.white),
        ),
        content: Text(
          'Du kannst deine Klasse später nicht ändern.',
          style: GoogleFonts.roboto(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Bestätigen',
              style: TextStyle(color: Color(0xFFB00020)),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final success = await ref
        .read(characterControllerProvider.notifier)
        .chooseClass(characterClass);
    if (success && context.mounted) {
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }
}
