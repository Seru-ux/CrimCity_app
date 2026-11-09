import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/player_npc.dart';
import '../models/npc_gear.dart';
import '../models/npc_talent.dart';
import '../services/npc_service.dart';
import '../services/gear_service.dart';
import '../services/npc_talent_service.dart';
import '../services/npc_progression_service.dart';

part 'npc_detail_controller.g.dart';

@riverpod
class NpcDetail extends _$NpcDetail {
  @override
  Future<NpcDetailData> build(String playerNpcId) async {
    final npcService = NpcService(Supabase.instance.client);
    final gearService = GearService(Supabase.instance.client);
    final talentService = NpcTalentService(Supabase.instance.client);
    
    final results = await Future.wait([
      npcService.fetchPlayerNpc(playerNpcId),
      gearService.fetchAllGear(),
      talentService.fetchAllTalents(),
    ]);
    
    return NpcDetailData(
      npc: results[0] as PlayerNpc?,
      availableGear: results[1] as List<NpcGear>,
      availableTalents: results[2] as List<NpcTalent>,
    );
  }

  Future<void> trainNpc() async {
    final progressionService = NpcProgressionService(Supabase.instance.client);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await progressionService.trainNpc(arg);
      return build(arg);
    });
  }
}

class NpcDetailData {
  final PlayerNpc? npc;
  final List<NpcGear> availableGear;
  final List<NpcTalent> availableTalents;
  NpcDetailData({required this.npc, required this.availableGear, required this.availableTalents});
}
