import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'sub_skill_screen.dart';
import 'talent_tree_screen.dart';

class CharacterHubScreen extends StatelessWidget {
  const CharacterHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: Text(
          'Charakter',
          style: GoogleFonts.oswald(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile(context, 'Talente', Icons.account_tree, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TalentTreeScreen()),
            );
          }),
          _tile(context, 'Unter-Skills', Icons.tune, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubSkillScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      color: const Color(0xFF141414),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFB00020)),
        title: Text(label, style: GoogleFonts.oswald(color: Colors.white)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }
}
