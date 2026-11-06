// lib/services/assignment_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/npc_assignment.dart';

class AssignmentService {
  final SupabaseClient _client;

  AssignmentService(this._client);

  /// Einzelnen NPC auf Heist schicken (Alte Methode, bleibt zur Sicherheit drin)
  Future<Map<String, dynamic>> assignNpcToHeist({
    required String playerNpcId,
    required String heistId,
    required int riskLevel,
  }) async {
    final response = await _client.rpc(
      'assign_npc_to_heist',
      params: {
        'p_player_npc_id': playerNpcId,
        'p_heist_id': heistId,
        'p_risk_level': riskLevel,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// NEU: Ganze Gruppe von NPCs auf Heist schicken
  Future<Map<String, dynamic>> assignHeistGroup({
    required String heistId,
    required List<String> playerNpcIds,
    required int riskLevel,
  }) async {
    final response = await _client.rpc(
      'assign_heist_group',
      params: {
        'p_heist_id': heistId,
        'p_player_npc_ids': playerNpcIds,
        'p_risk_level': riskLevel,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// Alle laufenden Aufträge des Spielers
  Future<List<NpcAssignment>> fetchRunningAssignments() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Nicht eingeloggt');

    final response = await _client
        .from('npc_assignments')
        .select()
        .eq('player_id', userId)
        .eq('status', 'running')
        .order('finish_at', ascending: true);

    return (response as List)
        .map((e) => NpcAssignment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Alle abgeschlossenen Aufträge (Erfolg/Fail/Jail)
  Future<List<NpcAssignment>> fetchResolvedAssignments({int limit = 50}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Nicht eingeloggt');

    final response = await _client
        .from('npc_assignments')
        .select()
        .eq('player_id', userId)
        .inFilter('status', ['success', 'failed', 'jailed'])
        .order('resolved_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((e) => NpcAssignment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fällige Aufträge auflösen (RPC, idempotent)
  /// Wird beim App-Start / Foreground aufgerufen, falls pg_cron nicht läuft.
  Future<Map<String, dynamic>> resolveDueAssignments() async {
    final response = await _client.rpc('resolve_due_assignments');
    return response as Map<String, dynamic>;
  }
}