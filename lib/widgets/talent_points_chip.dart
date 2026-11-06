// lib/widgets/talent_points_chip.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/talent_controller.dart';

class TalentPointsChip extends ConsumerWidget {
  final VoidCallback? onTap;
  const TalentPointsChip({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(talentControllerProvider);
    final points = uiState.state?.talentPoints ?? 0;

    if (points <= 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE11D48).withOpacity(0.15),
          border: Border.all(color: const Color(0xFFE11D48).withOpacity(0.6)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium,
                color: Color(0xFFE11D48), size: 14),
            const SizedBox(width: 4),
            Text('$points',
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFFE11D48),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                )),
          ],
        ),
      ),
    );
  }
}