import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/attribute_type.dart';

class AttributeCard extends StatelessWidget {
  final AttributeType type;
  final int value;
  final bool canSpend;
  final VoidCallback onSpend;

  const AttributeCard({
    super.key,
    required this.type,
    required this.value,
    required this.canSpend,
    required this.onSpend,
  });

  IconData get _icon => switch (type) {
    AttributeType.strength => Icons.fitness_center,
    AttributeType.dexterity => Icons.directions_run,
    AttributeType.endurance => Icons.favorite,
    AttributeType.charisma => Icons.record_voice_over,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          Icon(_icon, color: const Color(0xFFB00020), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.label,
                  style: GoogleFonts.oswald(color: Colors.white, fontSize: 16),
                ),
                Text(
                  type.shortLabel,
                  style: GoogleFonts.robotoMono(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$value',
            style: GoogleFonts.robotoMono(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: canSpend ? onSpend : null,
            icon: Icon(
              Icons.add_circle,
              color: canSpend ? const Color(0xFF00FF88) : Colors.white24,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
