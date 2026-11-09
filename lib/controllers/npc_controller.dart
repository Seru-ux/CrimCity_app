import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/npc.dart';
import '../models/player_npc.dart';
import '../services/npc_service.dart';

part 'npc_controller.g.dart';

@riverpod
NpcService npcService(NpcServiceRef ref) =>
    NpcService(Supabase.instance.client);

@riverpod
class NpcList extends _$NpcList {
  @override
  FutureOr<void> build() async {}

  Future<void> hire(String npcId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(npcServiceProvider).hireNpc(npcId);
      ref.invalidate(myCrewProvider);
    });
  }

  Future<void> buyout(String playerNpcId, {String currency = 'cash'}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(npcServiceProvider)
          .buyoutNpc(playerNpcId, currency: currency);
      ref.invalidate(myCrewProvider);
    });
  }
}

@riverpod
Future<List<Npc>> availableNpcs(AvailableNpcsRef ref) async {
  return ref.watch(npcServiceProvider).fetchAvailableNpcs();
}

@riverpod
Future<List<PlayerNpc>> myCrew(MyCrewRef ref) async {
  return ref.watch(npcServiceProvider).fetchMyCrew();
}

@riverpod
Future<int> crewSlots(CrewSlotsRef ref) async {
  return ref.watch(npcServiceProvider).fetchCrewSlots();
}
