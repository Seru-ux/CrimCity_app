// lib/screens/gang_browser_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/gang_controller.dart';
import '../models/gang.dart';
import '../services/gang_service.dart';

class GangBrowserScreen extends ConsumerStatefulWidget {
  const GangBrowserScreen({super.key});

  @override
  ConsumerState<GangBrowserScreen> createState() => _GangBrowserScreenState();
}

class _GangBrowserScreenState extends ConsumerState<GangBrowserScreen> {
  final _searchCtrl = TextEditingController();
  List<Gang> _gangs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _search();
  }

  Future<void> _search() async {
    setState(() => _loading = true);
    final service = ref.read(gangServiceProvider);
    final result = await service.searchGangs(query: _searchCtrl.text.trim());
    if (mounted)
      setState(() {
        _gangs = result;
        _loading = false;
      });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text('GANGS', style: GoogleFonts.oswald()),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (_) => _search(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Name oder TAG suchen...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white54),
                  onPressed: _search,
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _gangs.isEmpty
                ? const Center(
                    child: Text(
                      'Keine Gangs gefunden.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    itemCount: _gangs.length,
                    itemBuilder: (_, i) {
                      final g = _gangs[i];
                      return ListTile(
                        title: Text(
                          '[${g.tag}] ${g.name}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Lvl ${g.level} · ${g.memberCount}/${g.memberSlots}',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          onPressed: g.isFull
                              ? null
                              : () async {
                                  try {
                                    await ref
                                        .read(gangControllerProvider.notifier)
                                        .applyToGang(g.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Bewerbung gesendet.'),
                                        ),
                                      );
                                    }
                                  } on GangException catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            SnackBar(content: Text(e.message)),
                                          );
                                    }
                                  }
                                },
                          child: const Text('BEWERBEN'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
