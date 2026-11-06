import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/attribute_type.dart';
import '../models/player_profile.dart';
import '../services/auth_service.dart';
import '../services/player_service.dart';
import 'character_hub_screen.dart';
import 'class_select_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _playerService = PlayerService();
  PlayerProfile? _profile;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      final profile = await _playerService.getProfile(user.id);
      if (mounted) setState(() => _profile = profile);
    }
  }

  Future<void> _spendPoint(AttributeType attr) async {
    if (_profile == null || _profile!.availablePoints <= 0 || _busy) return;
    setState(() => _busy = true);
    try {
      final updated = await _playerService.spendSkillPoint(attr);
      if (mounted) {
        setState(() => _profile = updated);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${attr.label} +1')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openClassSelect() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ClassSelectScreen()),
    );
    if (result == true) {
      await _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFB00020)),
        ),
      );
    }

    final p = _profile!;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'PROFIL',
          style: GoogleFonts.oswald(
            fontSize: 24,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // NEU: Button zum Charakter-Hub (Talente & Unter-Skills)
          IconButton(
            icon: const Icon(Icons.account_tree, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CharacterHubScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar und Name
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFFB00020),
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    p.username.toUpperCase(),
                    style: GoogleFonts.oswald(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Level ${p.level}',
                    style: GoogleFonts.oswald(
                      fontSize: 18,
                      color: const Color(0xFFFFC107),
                    ),
                  ),
                  // NEU: Klassen-Badge
                  if (p.characterClass != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB00020).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFB00020)),
                      ),
                      child: Text(
                        p.characterClass!.label,
                        style: GoogleFonts.oswald(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // XP Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ERFAHRUNG',
                        style: GoogleFonts.oswald(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        '${p.currentXp} / 100 XP',
                        style: GoogleFonts.oswald(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: p.currentXp / 100,
                      backgroundColor: Colors.grey[800],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFB00020),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stats Liste
            _StatRow(label: 'Geld', value: '\$${p.money}'),
            _StatRow(label: 'Energie', value: '${p.energy} / 100'),
            _StatRow(label: 'Level', value: '${p.level}'),
            _StatRow(
              label: 'Items im Inventar',
              value: '${p.inventory.length}',
            ),

            const SizedBox(height: 24),

            // NEU: Charakter-System
            if (p.characterClass == null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFB00020)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Noch keine Klasse gewählt',
                      style: GoogleFonts.oswald(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Wähle deine Klasse, um Attribute und Talente zu skillen.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB00020),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: _openClassSelect,
                      child: Text(
                        'KLASSE WÄHLEN',
                        style: GoogleFonts.oswald(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CHARAKTER',
                    style: GoogleFonts.oswald(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: p.availablePoints > 0
                          ? const Color(0xFF00FF88).withOpacity(0.2)
                          : Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${p.availablePoints} Punkte',
                      style: GoogleFonts.robotoMono(
                        fontSize: 12,
                        color: p.availablePoints > 0
                            ? const Color(0xFF00FF88)
                            : Colors.grey[400],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...AttributeType.values.map(
                (a) => _AttributeRow(
                  type: a,
                  value: p.attributeValue(a),
                  canSpend: p.availablePoints > 0 && !_busy,
                  onSpend: () => _spendPoint(a),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Bestehende StatRow
class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.oswald(fontSize: 16, color: Colors.grey[400]),
          ),
          Text(
            value,
            style: GoogleFonts.oswald(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// NEU: Zeile für die Attribute (STR, DEX, END, CHA)
class _AttributeRow extends StatelessWidget {
  final AttributeType type;
  final int value;
  final bool canSpend;
  final VoidCallback onSpend;

  const _AttributeRow({
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(_icon, color: const Color(0xFFB00020), size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.label,
                  style: GoogleFonts.oswald(fontSize: 15, color: Colors.white),
                ),
                Text(
                  type.shortLabel,
                  style: GoogleFonts.robotoMono(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$value',
            style: GoogleFonts.robotoMono(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: canSpend ? onSpend : null,
            icon: Icon(
              Icons.add_circle,
              color: canSpend ? const Color(0xFF00FF88) : Colors.grey[800],
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
