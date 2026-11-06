// lib/services/talent_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/talent_tree.dart';

class TalentService {
  final SupabaseClient _supabase;

  TalentService(this._supabase);

  SupabaseClient get supabase => _supabase;

  Future<TalentState> getTalentState() async {
    final response = await _supabase.rpc('get_talent_state');
    if (response == null) return TalentState.empty();
    return TalentState.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<Map<String, dynamic>> unlockOrUpgrade(String talentId) async {
    final response = await _supabase.rpc(
      'unlock_or_upgrade_talent',
      params: {'p_talent_id': talentId},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> respec({String payment = 'coins'}) async {
    final response = await _supabase.rpc(
      'respec_talents',
      params: {'p_payment': payment},
    );
    return Map<String, dynamic>.from(response as Map);
  }
}