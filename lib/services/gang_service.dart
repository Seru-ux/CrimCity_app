// lib/services/gang_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/district.dart';
import '../models/gang.dart';
import '../models/gang_application.dart';
import '../models/gang_invite.dart';
import '../models/gang_member.dart';
import '../models/gang_mission.dart';

class GangException implements Exception {
  final String code;

  GangException(this.code);

  String get message => switch (code) {
    'already_in_gang' => 'Du bist bereits in einer Gang.',
    'not_in_gang' => 'Du bist in keiner Gang.',
    'level_too_low' => 'Dein Level ist zu niedrig (min. 5).',
    'not_enough_money' => 'Du hast nicht genug Geld (50.000 \$).',
    'name_taken' => 'Dieser Gangname ist bereits vergeben.',
    'tag_taken' => 'Dieser TAG ist bereits vergeben.',
    'invalid_name' => 'Name muss 3-20 Zeichen haben.',
    'invalid_tag' => 'TAG muss 2-4 Großbuchstaben/Zahlen sein.',
    'gang_full' => 'Die Gang ist voll.',
    'not_authorized' => 'Keine Berechtigung.',
    'cannot_kick_leader' => 'Der Leader kann nicht gekickt werden.',
    'cannot_change_leader_role' =>
      'Die Rolle des Leaders kann nicht geändert werden.',
    'leader_must_transfer' => 'Du musst zuerst die Führung übergeben.',
    'mission_not_found' => 'Mission nicht gefunden.',
    'mission_not_active' => 'Diese Mission ist nicht mehr aktiv.',
    'mission_expired' => 'Diese Mission ist abgelaufen.',
    'target_not_in_gang' => 'Der Spieler ist nicht in deiner Gang.',
    'invalid_role' => 'Ungültige Rolle.',
    'district_already_claimed' => 'Dieser Distrikt gehört bereits einer Gang.',
    'not_enough_influence' => 'Du hast nicht genug Einfluss.',
    'district_not_yours' => 'Dieser Distrikt gehört nicht deiner Gang.',
    'too_early' =>
      'Du kannst noch nicht einsammeln (warte mindestens 1 Stunde).',
    _ => 'Unbekannter Fehler: $code',
  };
}

class GangService {
  final SupabaseClient _supabase;

  GangService(this._supabase);

  String get _myId => _supabase.auth.currentUser!.id;

  // === Lesen ===
  Future<Gang?> fetchMyGang() async {
    final res = await _supabase
        .from('gangs')
        .select('*, gang_members!inner(count)')
        .eq('gang_members.player_id', _myId)
        .maybeSingle();
    return res != null ? Gang.fromJson(res) : null;
  }

  Future<Gang?> fetchGangById(String gangId) async {
    final res = await _supabase
        .from('gangs')
        .select('*, gang_members(count)')
        .eq('id', gangId)
        .maybeSingle();
    return res != null ? Gang.fromJson(res) : null;
  }

  Future<List<GangMember>> fetchMembers(String gangId) async {
    final res = await _supabase
        .from('gang_members')
        .select('*, profiles(*)')
        .eq('gang_id', gangId)
        .order('joined_at', ascending: true);
    return (res as List).map((e) => GangMember.fromJson(e)).toList();
  }

  Future<List<Gang>> searchGangs({
    String? query,
    bool onlyRecruiting = true,
  }) async {
    var q = _supabase.from('gangs').select('*, gang_members(count)');
    if (onlyRecruiting) q = q.eq('is_recruiting', true);
    if (query != null && query.isNotEmpty) {
      q = q.or('name.ilike.%$query%,tag.ilike.%$query%');
    }
    final res = await q.order('level', ascending: false).limit(50);
    return (res as List).map((e) => Gang.fromJson(e)).toList();
  }

  // === Missionen ===
  Future<List<GangMission>> fetchGangMissions(String gangId) async {
    final res = await _supabase
        .from('gang_missions')
        .select()
        .eq('gang_id', gangId)
        .order('created_at', ascending: false);
    return (res as List).map((e) => GangMission.fromJson(e)).toList();
  }

  Future<void> startMission({
    required String missionCode,
    required String name,
    required String description,
    required int requiredContributions,
    required int expReward,
  }) async {
    final res = await _supabase.rpc(
      'start_gang_mission',
      params: {
        'p_mission_code': missionCode,
        'p_name': name,
        'p_description': description,
        'p_required_contributions': requiredContributions,
        'p_exp_reward': expReward,
      },
    );
    final map = res as Map<String, dynamic>;
    if (map['error'] != null) throw GangException(map['error'] as String);
  }

  Future<void> contributeToMission(String missionId, int amount) async {
    final res = await _supabase.rpc(
      'contribute_to_mission',
      params: {'p_mission_id': missionId, 'p_amount': amount},
    );
    final map = res as Map<String, dynamic>;
    if (map['error'] != null) throw GangException(map['error'] as String);
  }

  // === RPCs ===
  Future<String> createGang({
    required String name,
    required String tag,
    String description = '',
  }) async {
    final res = await _supabase.rpc(
      'create_gang',
      params: {'p_name': name, 'p_tag': tag, 'p_description': description},
    );
    final map = res as Map<String, dynamic>;
    if (map['error'] != null) throw GangException(map['error'] as String);
    return map['gang_id'] as String;
  }

  Future<void> leaveGang() async {
    final res = await _supabase.rpc('leave_gang');
    final map = res as Map<String, dynamic>;
    if (map['error'] != null) throw GangException(map['error'] as String);
  }

  Future<void> kickMember(String playerId) async {
    final res = await _supabase.rpc(
      'kick_member',
      params: {'p_player_id': playerId},
    );
    final map = res as Map<String, dynamic>;
    if (map['error'] != null) throw GangException(map['error'] as String);
  }

  // === Invites ===
  Future<void> sendInvite(String gangId, String inviteeId) async {
    final res = await _supabase.rpc(
      'send_gang_invite',
      params: {'p_gang_id': gangId, 'p_invitee_id': inviteeId},
    );
    final map = res as Map<String, dynamic>;
    if (map['error'] != null) throw GangException(map['error'] as String);
  }

  Future<void> respondToInvite(String inviteId, bool accept) async {
    final res = await _supabase.rpc(
      'respond_gang_invite',
      params: {'p_invite_id': inviteId, 'p_accept': accept},
    );
    final map = res as Map<String, dynamic>;
    if (map['error'] != null) throw GangException(map['error'] as String);
  }

  Future<List<GangInvite>> fetchMyInvites() async {
    final res = await _supabase
        .from('gang_invites')
        .select('*, gangs(name, tag)')
        .eq('invitee_id', _myId)
        .eq('status', 'pending');
    return (res as List).map((e) => GangInvite.fromJson(e)).toList();
  }

  // === Applications ===
  Future<void> applyToGang(String gangId, {String message = ''}) async {
    final res = await _supabase.rpc(
      'apply_to_gang',
      params: {'p_gang_id': gangId, 'p_message': message},
    );
    final map = res as Map<String, dynamic>;
    if (map['error'] != null) throw GangException(map['error'] as String);
  }

  Future<void> respondToApplication(String appId, bool accept) async {
    final res = await _supabase.rpc(
      'respond_gang_application',
      params: {'p_application_id': appId, 'p_accept': accept},
    );
    final map = res as Map<String, dynamic>;
    if (map['error'] != null) throw GangException(map['error'] as String);
  }

  Future<List<GangApplication>> fetchGangApplications(String gangId) async {
    final res = await _supabase
        .from('gang_applications')
        .select('*, profiles(username)')
        .eq('gang_id', gangId)
        .eq('status', 'pending');
    return (res as List).map((e) => GangApplication.fromJson(e)).toList();
  }

  // === Rollen & Einstellungen ===
  Future<void> changeMemberRole(String playerId, GangRole newRole) async {
    final res = await _supabase.rpc(
      'change_gang_member_role',
      params: {
        'p_target_player_id': playerId,
        'p_new_role': gangRoleToString(newRole),
      },
    );
    final map = res as Map<String, dynamic>;
    if (map['error'] != null) throw GangException(map['error'] as String);
  }

  Future<void> updateGangSettings({
    String? description,
    bool? isRecruiting,
  }) async {
    final res = await _supabase.rpc(
      'update_gang_settings',
      params: {'p_description': description, 'p_is_recruiting': isRecruiting},
    );
    final map = res as Map<String, dynamic>;
    if (map['error'] != null) throw GangException(map['error'] as String);
  }

  // === Distrikte ===
  Future<List<District>> fetchDistricts() async {
    final res = await _supabase.from('districts').select().order('name');
    return (res as List).map((e) => District.fromJson(e)).toList();
  }

  Future<void> claimDistrict(String districtId) async {
    final res = await _supabase.rpc(
      'claim_district',
      params: {'p_district_id': districtId},
    );
    final map = res as Map<String, dynamic>;
    if (map['error'] != null) throw GangException(map['error'] as String);
  }

  Future<Map<String, dynamic>> collectDistrictIncome(String districtId) async {
    final res = await _supabase.rpc(
      'collect_district_income',
      params: {'p_district_id': districtId},
    );
    final map = res as Map<String, dynamic>;
    if (map['error'] != null) throw GangException(map['error'] as String);
    return map;
  }
}
