// lib/screens/docs_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class DocsScreen extends ConsumerWidget {
  const DocsScreen({super.key});

  static const Color bgDark = Color(0xFF0A0A0A);
  static const Color cardDark = Color(0xFF141414);
  static const Color borderGrey = Color(0xFF262626);
  static const Color gold = Color(0xFFF59E0B);
  static const Color bloodRed = Color(0xFFE11D48);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: bgDark,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Icon(Icons.description, color: gold, size: 24),
              const SizedBox(width: 8),
              Text(
                'DOKUMENTE',
                style: GoogleFonts.oswald(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Fälschungen, Ausweise und Papiere für den Schwarzmarkt.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFFA3A3A3),
            ),
          ),
          const SizedBox(height: 16),

          // Platzhalter-Karte
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderGrey),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.construction,
                  size: 48,
                  color: Color(0xFFA3A3A3),
                ),
                const SizedBox(height: 12),
                Text(
                  'Docs-System in Arbeit',
                  style: GoogleFonts.oswald(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Hier entstehen bald gefälschte Papiere, Ausweise und '
                      'Dokumente für den Weiterverkauf. Der Preis hängt von '
                      'deinem Ruf und deinen Talenten ab.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFFA3A3A3),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: bloodRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: bloodRed.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    'BALD VERFÜGBAR',
                    style: GoogleFonts.robotoMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: bloodRed,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}