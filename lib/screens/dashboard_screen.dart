// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/dashboard_controller.dart';
import '../controllers/heist_browser_controller.dart'; // NEU
import '../models/game_state.dart';
import '../widgets/app_drawer.dart';
import '../widgets/heist_card.dart'; // NEU
import '../widgets/hud_header.dart';

// HIER IMPORTIEREN WIR DEINE ECHTEN SCREENS
import 'assign_heist_screen.dart'; // NEU
import 'login_screen.dart';
import 'profile_screen.dart';
import 'shop_screen.dart';

// NEU: Unterwelt (Crew + Gang + Docs)
import 'underworld_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  // NEU: Umschalter für Raub-Modus (0 = Crew, 1 = Selbst)
  int _raubMode = 0;

  // Farbpalette
  static const Color bgDark = Color(0xFF0A0A0A);
  static const Color cardDark = Color(0xFF141414);
  static const Color borderGrey = Color(0xFF262626);
  static const Color bloodRed = Color(0xFFE11D48);
  static const Color gold = Color(0xFFF59E0B);
  static const Color neonGreen = Color(0xFF00FF88);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardControllerProvider);
    final controller = ref.read(dashboardControllerProvider.notifier);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: bgDark,
        body: Center(child: CircularProgressIndicator(color: bloodRed)),
      );
    }

    // HIER SIND ALLE 5 TABS DEFINIERT
    final pages = [
      _buildDashboardTab(state, controller), // 0: Zentrale
      _buildRaubTab(controller),             // 1: Raub
      ShopScreen(                            // 2: Markt
        playerMoney: state.profile?.money ?? 0,
        onPurchaseSuccess: () => controller.loadProfile(showLoading: false),
      ),
      const UnderworldScreen(),              // 3: Unterwelt (Crew|Gang|Docs)
      const ProfileScreen(),                 // 4: Profil
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgDark,

      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(HudHeader.height),
        child: HudHeader(),
      ),

      endDrawer: AppSidebar(
        username: state.profile?.username ?? 'Unbekannt',
        level: state.profile?.level ?? 1,
        money: state.profile?.money ?? 0,
        onLogout: () async {
          await controller.logout();
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        },
      ),

      body: pages[_currentIndex],

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0A),
          border: Border(top: BorderSide(color: borderGrey, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            if (index == 0) controller.loadProfile(showLoading: false);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: gold,
          unselectedItemColor: const Color(0xFF666666),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 9,
          unselectedFontSize: 9,
          selectedLabelStyle: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.rajdhani(
            fontWeight: FontWeight.bold,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Zentrale',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.masks), label: 'Raub'),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Markt',
            ),
            // NEU: Unterwelt statt Crew
            BottomNavigationBarItem(
              icon: Icon(Icons.dark_mode),
              label: 'Unterwelt',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 0: ZENTRALE (Dein Hauptdashboard)
  // ==========================================
  Widget _buildDashboardTab(GameState state, DashboardController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLiveEventBanner(),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              _buildFeatureCard(
                title: 'Raub & Diebstahl',
                subtitle: 'Bankraub & Coups',
                icon: Icons.masks,
                iconColor: bloodRed,
                badgeText: '-10 EN',
                badgeColor: bloodRed,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _buildFeatureCard(
                title: 'Nachtleben',
                subtitle: 'Clubs & VIP-Bars',
                icon: Icons.wine_bar,
                iconColor: gold,
                badgeText: '+EN',
                badgeColor: gold,
                onTap: () => _showNightlifeModal(),
              ),
              _buildFeatureCard(
                title: 'Schwarzmarkt',
                subtitle: 'Waffen & Ausrüstung',
                icon: Icons.gavel,
                iconColor: gold,
                badgeText: 'MARKT',
                badgeColor: gold,
                onTap: () => setState(() => _currentIndex = 2),
              ),
              _buildFeatureCard(
                title: 'Produktion',
                subtitle: 'Drogenlabore',
                icon: Icons.science,
                iconColor: neonGreen,
                badgeText: '\$32k/h',
                badgeColor: neonGreen,
                onTap: () => _showGeneralModal(
                  'Drogenküche & Labor',
                  'Produziere und verkaufe Substanzen auf dem Markt für maximalen Bargeldgewinn.',
                  'PRODUZIEREN',
                ),
              ),
              // NEU: Unterwelt-Kachel
              _buildFeatureCard(
                title: 'Unterwelt',
                subtitle: 'Crew · Gang · Docs',
                icon: Icons.dark_mode,
                iconColor: gold,
                badgeText: 'MANAGEN',
                badgeColor: gold,
                onTap: () => setState(() => _currentIndex = 3),
              ),
              _buildFeatureCard(
                title: 'Immobilien',
                subtitle: 'Geldwäsche',
                icon: Icons.apartment,
                iconColor: Colors.grey[400]!,
                badgeText: '4 OBJEKTE',
                badgeColor: Colors.grey[400]!,
                onTap: () => _showGeneralModal(
                  'Immobilien & Geldwäsche',
                  'Kaufe Casinos und Waschanlagen, um Schwarzgeld legal zu machen.',
                  'KAUFEN',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLiveTicker(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: RAUB (NEU: Umschalter Crew vs. Selbst)
  // ==========================================
  Widget _buildRaubTab(DashboardController controller) {
    return Column(
      children: [
        // --- UMSCHALTER ---
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: cardDark,
            border: Border(bottom: BorderSide(color: borderGrey)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _modeButton(
                  label: 'CREW SCHICKEN',
                  isActive: _raubMode == 0,
                  icon: Icons.groups,
                  onTap: () => setState(() => _raubMode = 0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _modeButton(
                  label: 'SELBST RAUBEN',
                  isActive: _raubMode == 1,
                  icon: Icons.person,
                  onTap: () => setState(() => _raubMode = 1),
                ),
              ),
            ],
          ),
        ),

        // --- INHALT ---
        Expanded(
          child: _raubMode == 0
              ? _buildCrewRaubTab()
              : _buildSelfRaubTab(controller),
        ),
      ],
    );
  }

  Widget _modeButton({
    required String label,
    required bool isActive,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? bloodRed.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? bloodRed : borderGrey,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isActive ? bloodRed : const Color(0xFFA3A3A3)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.oswald(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFFA3A3A3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CREW RAUB (Heists aus DB) ---
  Widget _buildCrewRaubTab() {
    final heistState = ref.watch(heistBrowserControllerProvider);

    if (heistState.heists.isEmpty && !heistState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(heistBrowserControllerProvider.notifier).load(
          playerLevel: ref.read(dashboardControllerProvider).profile?.level ?? 1,
        );
      });
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(heistBrowserControllerProvider.notifier).load(
        playerLevel: ref.read(dashboardControllerProvider).profile?.level ?? 1,
      ),
      color: bloodRed,
      backgroundColor: cardDark,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'HEISTS FÜR DEINE CREW',
            style: GoogleFonts.rajdhani(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Wähle einen Raub und schicke deine NPCs los.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFFA3A3A3),
            ),
          ),
          const SizedBox(height: 20),
          if (heistState.isLoading)
            const Center(child: CircularProgressIndicator(color: bloodRed))
          else if (heistState.heists.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  'Keine Heists verfügbar.',
                  style: GoogleFonts.oswald(color: const Color(0xFFA3A3A3)),
                ),
              ),
            )
          else
            ...heistState.heists.map((heist) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: HeistCard(
                  heist: heist,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AssignHeistScreen(heist: heist),
                      ),
                    );
                    if (result == true) {
                      ref.read(heistBrowserControllerProvider.notifier).load(
                        playerLevel: ref.read(dashboardControllerProvider).profile?.level ?? 1,
                      );
                    }
                  },
                ),
              );
            }),
        ],
      ),
    );
  }

  // --- SELBST RAUBEN (Alte commit_crime Logik) ---
  Widget _buildSelfRaubTab(DashboardController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STREET CRIMES',
            style: GoogleFonts.rajdhani(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gehe selbst auf Raub. Kostet deine Energie.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFFA3A3A3),
            ),
          ),
          const SizedBox(height: 20),

          _buildActionOption(
            title: 'Taschendiebstahl',
            subtitle: 'Erfolg: 95% • +\$50 bis \$200',
            cost: '-10 EN',
            costColor: gold,
            onTap: () => _executeCrime(controller, 'taschendiebstahl', 0),
          ),
          const SizedBox(height: 12),
          _buildActionOption(
            title: 'Auto knacken',
            subtitle: 'Erfolg: 75% • +\$850',
            cost: '-25 EN',
            costColor: gold,
            onTap: () => _executeCrime(controller, 'auto_knacken', 2),
          ),
          const SizedBox(height: 12),
          _buildActionOption(
            title: 'Banküberfall',
            subtitle: 'Erfolg: 50% • +\$18,000',
            cost: '-50 EN',
            costColor: gold,
            onTap: () => _executeCrime(controller, 'bankueberfall', 3),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MODALS & HILFS-WIDGETS
  // ==========================================
  void _showNightlifeModal() {}

  void _showGeneralModal(String title, String description, String confirmText) {}

  Widget _buildLiveEventBanner() => const SizedBox();

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String badgeText,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderGrey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 26),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.oswald(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: const Color(0xFFA3A3A3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveTicker() => const SizedBox();

  // ==========================================
  // HILFSMETHODEN FÜR "SELBST RAUBEN"
  // ==========================================
  Widget _buildActionOption({
    required String title,
    required String subtitle,
    required String cost,
    required Color costColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: bloodRed.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderGrey),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.robotoMono(
                        fontSize: 10,
                        color: neonGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: costColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: costColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  cost,
                  style: GoogleFonts.robotoMono(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: costColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _executeCrime(
      DashboardController controller,
      String crimeType,
      int requiredLevel,
      ) async {
    final currentLevel =
        ref.read(dashboardControllerProvider).profile?.level ?? 1;

    if (currentLevel < requiredLevel) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Du brauchst Level $requiredLevel!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: bloodRed,
        ),
      );
      return;
    }

    try {
      final response = await controller.commitCrime(crimeType);
      if (response != null && mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'],
              style: GoogleFonts.rajdhani(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: response['success']
                ? const Color(0xFF065F46)
                : bloodRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e'), backgroundColor: bloodRed),
        );
      }
    }
  }
}