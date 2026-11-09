import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/talent_tree.dart';
import '../services/talent_service.dart';

part 'talent_controller.g.dart';

@riverpod
TalentService talentService(TalentServiceRef ref) =>
    TalentService(Supabase.instance.client);

@riverpod
class TalentManager extends _ {
  @override
  FutureOr<TalentState> build() async {
    return ref.watch(talentServiceProvider).getTalentState();
  }

  Future<void> unlockOrUpgrade(String talentId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(talentServiceProvider)
          .unlockOrUpgrade(talentId);
      if (result['success'] != true) {
        throw Exception(result['message'] ?? 'Fehler beim Talent-Kauf');
      }
      return ref.read(talentServiceProvider).getTalentState();
    });
  }

  Future<void> respec({String payment = 'coins'}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(talentServiceProvider)
          .respec(payment: payment);
      if (result['success'] != true) {
        throw Exception(result['message'] ?? 'Fehler beim Respec');
      }
      return ref.read(talentServiceProvider).getTalentState();
    });
  }
}
