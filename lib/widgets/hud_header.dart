import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/dashboard_controller.dart';

class HudHeader extends ConsumerWidget {
  static const double height = 135; // Perfekte Höhe für das freie Design

  const HudHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider);
    final profile = state.profile;

    if (profile == null) {
      return Container(
        height: height,
        color: const Color(0xFF0A0A0A),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Color(0xFFE11D48)),
      );
    }

    final energyPercent = (state.displayEnergy / profile.energyMax).clamp(0.0, 1.0);
    final hpPercent = (profile.health / profile.maxHealth).clamp(0.0, 1.0);

    // Fallback für Gang-Name
    final displayGangName = (profile.gangName != null && profile.gangName!.isNotEmpty)
        ? profile.gangName!.toUpperCase()
        : (profile.gangId != null ? 'VALENTI SYNDIKAT' : 'KEINE GANG');

    final crimcoins = 450;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A), // Tiefes Schwarz
        // Kein harter Rahmen mehr, nur ein weicher Verlauf nach unten
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0A0A), Color(0xFF050505)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- 1. AVATAR (Groß, schwebend, mit Glow) ---
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE11D48), width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE11D48).withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  // Level (unten rechts am Avatar)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF0A0A0A), width: 2),
                      ),
                      child: Text(
                        profile.level.toString(),
                        style: GoogleFonts.rajdhani(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // --- 2. MITTE: Name, Gang, Respekt, Balken ---
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name & Menü
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          profile.username.toUpperCase(),
                          style: GoogleFonts.rajdhani(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Scaffold.of(context).openEndDrawer(),
                          child: const Icon(Icons.menu, color: Colors.white, size: 24),
                        ),
                      ],
                    ),

                    // Gang & Respekt (Schön groß, ohne Boxen)
                    Row(
                      children: [
                        const Icon(Icons.shield, color: Color(0xFF0088FF), size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            displayGangName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.rajdhani(
                              fontSize: 12,
                              color: const Color(0xFF0088FF),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Icon(Icons.stars, color: Color(0xFFF59E0B), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          profile.respect.toString(),
                          style: GoogleFonts.robotoMono(fontSize: 12, color: const Color(0xFFF59E0B), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // HP & Energie (Schön dick und modern)
                    Row(
                      children: [
                        // HP
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.favorite, size: 10, color: Color(0xFFE11D48)),
                                  const SizedBox(width: 4),
                                  Text('HP', style: GoogleFonts.robotoMono(fontSize: 9, color: Colors.grey[400])),
                                ],
                              ),
                              const SizedBox(height: 3),
                              _buildModernBar(const Color(0xFFE11D48), hpPercent),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Energie
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.bolt, size: 10, color: Color(0xFFF59E0B)),
                                  const SizedBox(width: 4),
                                  Text('ENERGIE', style: GoogleFonts.robotoMono(fontSize: 9, color: Colors.grey[400])),
                                ],
                              ),
                              const SizedBox(height: 3),
                              _buildModernBar(const Color(0xFFF59E0B), energyPercent),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // --- 3. RECHTS: Währungen (Groß & Clean) ---
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildCurrency(Icons.money, const Color(0xFF00FF88), profile.money.toString()),
                  const SizedBox(height: 8),
                  _buildCurrency(Icons.diamond, const Color(0xFF00D8FF), crimcoins.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- MODERNER BALKEN (Dicker, ohne harte Boxen) ---
  Widget _buildModernBar(Color color, double percent) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: percent,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6)],
          ),
        ),
      ),
    );
  }

  // --- MODERNE WÄHRUNG (Keine Box, nur Icon & Text) ---
  Widget _buildCurrency(IconData icon, Color color, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value,
          style: GoogleFonts.rajdhani(
            fontSize: 16, // Schön groß
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Icon(icon, size: 18, color: color),
      ],
    );
  }
}