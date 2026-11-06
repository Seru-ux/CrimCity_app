// lib/services/crew_orchestrator.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'npc_service.dart';
import 'assignment_service.dart';
import 'heat_service.dart';
import 'heist_service.dart';

class CrewOrchestrator {
  final NpcService npc;
  final AssignmentService assignment;
  final HeatService heat;
  final HeistService heist;

  CrewOrchestrator(SupabaseClient client)
      : npc = NpcService(client),
        assignment = AssignmentService(client),
        heat = HeatService(client),
        heist = HeistService(client);

  /// Beim App-Start / Foreground aufrufen:
  /// Löst fällige Aufträge auf (falls pg_cron nicht läuft).
  Future<void> tick() async {
    await assignment.resolveDueAssignments();
  }
}