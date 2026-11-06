import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/gang_screen.dart'; // NEU
import '../screens/inventory_screen.dart';
import '../screens/profile_screen.dart';

class AppSidebar extends StatelessWidget {
  final String username;
  final int level;
  final int money;
  final VoidCallback onLogout;

  const AppSidebar({
    super.key,
    required this.username,
    required this.level,
    required this.money,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0A0A0A),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF141414),
              border: Border(
                bottom: BorderSide(color: Color(0xFFB00020), width: 2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFB00020),
                  child: Icon(Icons.person, size: 35, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  username.toUpperCase(),
                  style: GoogleFonts.oswald(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Level $level · \$$money',
                  style: GoogleFonts.oswald(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),

          // Menüpunkte
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.grey),
            title: Text(
              'Profil',
              style: GoogleFonts.oswald(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
            title: Text(
              'Inventar',
              style: GoogleFonts.oswald(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InventoryScreen()),
              );
            },
          ),

          // === NEU: Gang ===
          ListTile(
            leading: const Icon(Icons.groups, color: Color(0xFFB00020)),
            title: Text(
              'Gang',
              style: GoogleFonts.oswald(
                color: const Color(0xFFB00020),
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GangScreen()),
              );
            },
          ),

          const Divider(color: Color(0xFF1A1A1A)),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFB00020)),
            title: Text(
              'Ausloggen',
              style: GoogleFonts.oswald(color: const Color(0xFFB00020)),
            ),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
