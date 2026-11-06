import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

class SubSkillScreen extends StatefulWidget {
  const SubSkillScreen({super.key});

  @override
  State<SubSkillScreen> createState() => _SubSkillScreenState();
}

class _SubSkillScreenState extends State<SubSkillScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _supabase = Supabase.instance.client;
  TabController? _tabController;
  List<Map<String, dynamic>> _subSkills = [];
  Map<String, int> _playerSkills = {};
  Map<String, int> _attributes = {};
  bool _isLoading = true;

  final _categories = ['combat', 'heist', 'defense', 'social'];
  final _categoryNames = {
    'combat': 'Kampf (STR)',
    'heist': 'Heist (DEX)',
    'defense': 'Defensive (END)',
    'social': 'Sozial (CHA)',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      // 1. Attribute des Spielers laden
      final profile = await _supabase
          .from('profiles')
          .select('strength, dexterity, endurance, charisma')
          .eq('id', user.id)
          .single();
      _attributes = {
        'strength': profile['strength'] ?? 1,
        'dexterity': profile['dexterity'] ?? 1,
        'endurance': profile['endurance'] ?? 1,
        'charisma': profile['charisma'] ?? 1,
      };

      // 2. Unter-Skills laden
      final skillsRes = await _supabase
          .from('sub_skills')
          .select()
          .order('sort_order');
      _subSkills = List<Map<String, dynamic>>.from(skillsRes);

      // 3. Spieler-Fortschritt laden
      final playerSkillsRes = await _supabase
          .from('player_sub_skills')
          .select()
          .eq('player_id', user.id);
      _playerSkills.clear();
      for (var ps in playerSkillsRes) {
        _playerSkills[ps['sub_skill_id']] = ps['level'];
      }

      _tabController = TabController(length: _categories.length, vsync: this);
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Fehler: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFB00020)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: Text(
          'UNTER-SKILLS',
          style: GoogleFonts.oswald(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFB00020),
          isScrollable: true,
          tabs: _categories.map((c) => Tab(text: _categoryNames[c])).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((category) {
          final skills = _subSkills
              .where((s) => s['category'] == category)
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: skills.length,
            itemBuilder: (context, index) {
              final s = skills[index];
              final currentLevel = _playerSkills[s['id']] ?? 0;
              final maxLevel = s['max_level'] as int;
              final linkedAttr = s['linked_attribute'] as String;
              final attrValue = _attributes[linkedAttr] ?? 1;

              // Live-Berechnung des aktuellen Effekts
              final scaling = (s['scaling_factor'] as num).toDouble();
              final baseEffect = (s['effect_per_level'] as num).toDouble();
              final currentEffect =
                  currentLevel * baseEffect * (1 + (attrValue / scaling));

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          s['name'],
                          style: GoogleFonts.oswald(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$currentLevel / $maxLevel',
                          style: GoogleFonts.robotoMono(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s['description'],
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Aktueller Effekt
                    Text(
                      'Aktuell: ${(currentEffect * 100).toStringAsFixed(1)}%',
                      style: GoogleFonts.robotoMono(
                        fontSize: 12,
                        color: const Color(0xFF00FF88),
                      ),
                    ),
                    Text(
                      'Skaliert mit ${linkedAttr.toUpperCase()} ($attrValue)',
                      style: GoogleFonts.robotoMono(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
