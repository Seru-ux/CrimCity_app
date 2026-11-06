// lib/widgets/risk_selector.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RiskSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const RiskSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _options = [
    (1, 'SICHER', 'x1.0 Loot', Color(0xFF00FF88), Icons.shield),
    (2, 'RISKANT', 'x1.8 Loot', Color(0xFFF59E0B), Icons.warning),
    (3, 'SELBSTMORD', 'x3.0 Loot', Color(0xFFE11D48), Icons.dangerous),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _options.map((opt) {
        final (level, label, sub, color, icon) = opt;
        final isSelected = selected == level;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: InkWell(
              onTap: () => onChanged(level),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.15)
                      : const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : const Color(0xFF262626),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(icon, size: 18, color: color),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: GoogleFonts.oswald(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? color : Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: GoogleFonts.rajdhani(
                        fontSize: 10,
                        color: const Color(0xFFA3A3A3),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}