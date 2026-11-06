// lib/services/player_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/attribute_type.dart';
import '../models/character_class.dart';
import '../models/player_profile.dart';

class PlayerException implements Exception {
  final String message;

  PlayerException(this.message);

  @override
  String toString() => message;
}

class PlayerService {
  final SupabaseClient _client;

  // Optionaler Client → Fallback auf die globale Supabase-Instanz.
  // Dadurch funktionieren BEIDE Aufrufe:
  //   PlayerService()          (dein bestehender Code)
  //   PlayerService(client)    (neue Aufrufe)
  PlayerService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  // ============================================================
  // BESTEHENDE METHODEN (werden von dashboard_controller etc. gebraucht)
  // ============================================================

  Future<PlayerProfile> getProfile(String userId) async {
    final res = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return PlayerProfile.fromJson(res);
  }

  Future<Map<String, dynamic>> commitCrime(String crimeType) async {
    try {
      final res = await _client.rpc(
        'commit_crime',
        params: {'p_crime_type': crimeType},
      );
      return res as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw PlayerException(e.message);
    }
  }

  // ============================================================
  // NEU: Charakter-System
  // ============================================================

  Future<PlayerProfile> getMyCharacter() async {
    final res = await _client.rpc('get_my_character');
    return PlayerProfile.fromJson(res as Map<String, dynamic>);
  }

  Future<PlayerProfile> chooseClass(CharacterClass c) async {
    try {
      final res = await _client.rpc(
        'choose_class',
        params: {'p_class': c.dbValue},
      );
      return PlayerProfile.fromJson(res as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw PlayerException(e.message);
    }
  }

  Future<PlayerProfile> spendSkillPoint(AttributeType attr) async {
    try {
      final res = await _client.rpc(
        'spend_skill_point',
        params: {'p_attribute': attr.dbValue},
      );
      return PlayerProfile.fromJson(res as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw PlayerException(e.message);
    }
  }

  // ============================================================
  // NEU: Sync-Methoden für Energie & HP (Talent-System)
  // ============================================================

  /// Regeneriert Energie basierend auf der Zeit (nutzt Pimp-Klasse + Zäh-Talent)
  Future<void> syncEnergy(String playerId) async {
    try {
      await _client.rpc('sync_player_energy', params: {
        'p_player_id': playerId,
      });
    } catch (e) {
      // Fehler loggen, aber den Profil-Load nicht abbrechen
      print('syncEnergy failed: $e');
    }
  }

  /// Erzwingt die Neuberechnung von HP und max_health 
  /// (nutzt Hitman/Burglar-Klasse + Eisern/Unverwüstlich-Talent)
  Future<void> refreshStats(String playerId) async {
    try {
      await _client.rpc('refresh_player_stats', params: {
        'p_player_id': playerId,
      });
    } catch (e) {
      print('refreshStats failed: $e');
    }
  }
}