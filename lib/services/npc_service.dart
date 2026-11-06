// lib/services/npc_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/npc.dart';
import '../models/player_npc.dart';

class NpcService {
  final SupabaseClient _client;

  NpcService(this._client);

  /// Alle verfügbaren NPCs (Markt)
  Future<List<Npc>> fetchAvailableNpcs() async {
    final response = await _client
        .from('npcs')
        .select()
        .eq('is_active', true)
        .order('rarity', ascending: true)
        .order('hire_cost', ascending: true);

    return (response as List)
        .map((e) => Npc.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Eigene Crew (mit NPC-Definition gejoint)
  Future<List<PlayerNpc>> fetchMyCrew() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Nicht eingeloggt');

    final response = await _client
        .from('player_npcs')
        .select('*, npcs(*), player_npc_gear(*, npc_gear(*)), player_npc_talents(*, npc_talents(*))')
        .eq('player_id', userId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((e) => PlayerNpc.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Einzelnen NPC laden
  Future<PlayerNpc?> fetchPlayerNpc(String playerNpcId) async {
    final response = await _client
        .from('player_npcs')
        .select('*, npcs(*), player_npc_gear(*, npc_gear(*)), player_npc_talents(*, npc_talents(*))')
        .eq('id', playerNpcId)
        .maybeSingle();

    if (response == null) return null;
    return PlayerNpc.fromJson(response as Map<String, dynamic>);
  }

  /// NPC anheuern (RPC)
  Future<Map<String, dynamic>> hireNpc(String npcId) async {
    final response = await _client.rpc(
      'hire_npc',
      params: {'p_npc_id': npcId},
    );
    return response as Map<String, dynamic>;
  }

  /// NPC freikaufen (RPC)
  Future<Map<String, dynamic>> buyoutNpc(
      String playerNpcId, {
        String currency = 'cash',
      }) async {
    final response = await _client.rpc(
      'buyout_npc',
      params: {
        'p_player_npc_id': playerNpcId,
        'p_currency': currency,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// Crew-Slots (max. Anzahl)
  Future<int> fetchCrewSlots() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Nicht eingeloggt');

    final response = await _client.rpc(
      'get_crew_slots',
      params: {'p_player_id': userId},
    );
    return (response as num).toInt();
  }

  /// Stamina-Regeneration (Server-Trigger, idempotent).
  /// Ohne ID = alle NPCs des eingeloggten Spielers.
  /// Rückgabe: id -> { stamina, max_stamina, last_stamina_regen }
  Future<Map<String, StaminaSnapshot>> regenStamina({String? playerNpcId}) async {
    final response = await _client.rpc(
      'regen_npc_stamina',
      params: {'p_player_npc_id': playerNpcId},
    );

    final rows = (response as List?) ?? const [];
    final result = <String, StaminaSnapshot>{};
    for (final row in rows) {
      final map = row as Map<String, dynamic>;
      result[map['id'] as String] = StaminaSnapshot(
        stamina: (map['stamina'] as num).toInt(),
        maxStamina: (map['max_stamina'] as num).toInt(),
        lastStaminaRegen: map['last_stamina_regen'] != null
            ? DateTime.parse(map['last_stamina_regen'] as String)
            : null,
      );
    }
    return result;
  }
}

class StaminaSnapshot {
  final int stamina;
  final int maxStamina;
  final DateTime? lastStaminaRegen;

  const StaminaSnapshot({
    required this.stamina,
    required this.maxStamina,
    this.lastStaminaRegen,
  });
}