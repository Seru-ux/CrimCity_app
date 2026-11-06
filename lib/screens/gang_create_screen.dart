// lib/screens/gang_create_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/gang_controller.dart';

class GangCreateScreen extends ConsumerStatefulWidget {
  const GangCreateScreen({super.key});

  @override
  ConsumerState<GangCreateScreen> createState() => _GangCreateScreenState();
}

class _GangCreateScreenState extends ConsumerState<GangCreateScreen> {
  final _nameCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tagCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gangControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text('GANG GRÜNDEN', style: GoogleFonts.oswald()),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            TextField(
              controller: _nameCtrl,
              maxLength: 20,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Gangname (3-20 Zeichen)',
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tagCtrl,
              maxLength: 4,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'TAG (2-4 Zeichen, Großbuchstaben)',
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLength: 200,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Beschreibung (optional)',
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Kosten: 50.000 \$',
              style: GoogleFonts.oswald(fontSize: 20, color: Colors.amber),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 12),
              Text(
                state.error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size.fromHeight(56),
              ),
              onPressed: state.isSubmitting
                  ? null
                  : () async {
                      final ok = await ref
                          .read(gangControllerProvider.notifier)
                          .createGang(
                            name: _nameCtrl.text.trim(),
                            tag: _tagCtrl.text.trim().toUpperCase(),
                            description: _descCtrl.text.trim(),
                          );
                      if (ok && context.mounted) Navigator.pop(context);
                    },
              child: state.isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'GANG GRÜNDEN',
                      style: GoogleFonts.oswald(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
