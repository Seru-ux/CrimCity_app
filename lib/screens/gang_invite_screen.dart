// lib/screens/gang_invite_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../controllers/gang_controller.dart';

class GangInviteScreen extends ConsumerStatefulWidget {
  const GangInviteScreen({super.key});

  @override
  ConsumerState<GangInviteScreen> createState() => _GangInviteScreenState();
}

class _GangInviteScreenState extends ConsumerState<GangInviteScreen> {
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  String? _error;

  Future<void> _search() async {
    final query = _searchCtrl.text.trim();
    if (query.length < 3) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Fix: .is_() gibt es nicht. Wir filtern mit .filter('gang_id', 'is', null)
      final res = await Supabase.instance.client
          .from('profiles')
          .select('id, username, level')
          .ilike('username', '%$query%')
          .filter('gang_id', 'is', null) // <-- HIER IST DER FIX
          .limit(20);

      setState(() {
        _results = List<Map<String, dynamic>>.from(res);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gangControllerProvider);

    if (state.status == GangStatus.noGang) {
      return _buildMyInvites(state);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text('SPIELER EINLADEN', style: GoogleFonts.oswald()),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (_) => _search(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Username suchen (mind. 3 Zeichen)...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: Color(0xFFB00020),
                  ),
                  onPressed: _search,
                ),
              ),
            ),
          ),
          if (_loading) const LinearProgressIndicator(color: Color(0xFFB00020)),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: _results.isEmpty && !_loading
                ? const Center(
                    child: Text(
                      'Keine Spieler gefunden.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (_, i) {
                      final p = _results[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF1A1A1A),
                          child: Text(
                            p['username'][0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          p['username'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Level ${p['level']}',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB00020),
                          ),
                          onPressed: () async {
                            // Fix: mounted check nach dem await
                            await ref
                                .read(gangControllerProvider.notifier)
                                .sendInvite(p['id']);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Einladung an ${p['username']} gesendet.',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text('EINLADEN'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Das ist der Screen für Spieler OHNE Gang (sieht Einladungen)
  Widget _buildMyInvites(GangState state) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text('MEINE EINLADUNGEN', style: GoogleFonts.oswald()),
        backgroundColor: Colors.black,
      ),
      body: state.myInvites.isEmpty
          ? const Center(
              child: Text(
                'Keine offenen Einladungen.',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView.builder(
              itemCount: state.myInvites.length,
              itemBuilder: (_, i) {
                final inv = state.myInvites[i];
                return ListTile(
                  title: Text(
                    '[${inv.gangTag}] ${inv.gangName}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Lädt dich ein',
                    style: TextStyle(color: Colors.white54),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          await ref
                              .read(gangControllerProvider.notifier)
                              .respondToInvite(inv.id, true);
                          if (mounted)
                            Navigator.pop(context); // Zurück zum Hauptscreen
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => ref
                            .read(gangControllerProvider.notifier)
                            .respondToInvite(inv.id, false),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
