// lib/controllers/crew_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'npc_controller.dart';
import 'assignment_controller.dart';
import 'heat_controller.dart';
import 'heist_browser_controller.dart';

/// Lädt alle Crew-Daten parallel (für App-Start / Dashboard).
class CrewBootstrap {
  final Ref ref;

  CrewBootstrap(this.ref);

  Future<void> loadAll({required int playerLevel}) async {
    await Future.wait([
      ref.read(npcControllerProvider.notifier).loadAll(),
      ref.read(assignmentControllerProvider.notifier).tick(),
      ref.read(heatControllerProvider.notifier).load(),
      ref.read(heistBrowserControllerProvider.notifier).load(
        playerLevel: playerLevel,
      ),
    ]);
  }
}

final crewBootstrapProvider = Provider<CrewBootstrap>((ref) {
  return CrewBootstrap(ref);
});