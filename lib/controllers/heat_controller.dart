import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/heat_action.dart';
import '../services/heat_service.dart';

part 'heat_controller.g.dart';

@riverpod
class HeatManager extends _$HeatManager {
  @override
  Future<HeatData> build() async {
    final service = HeatService(Supabase.instance.client);
    final results = await Future.wait([
      service.fetchMyHeat(),
      service.fetchHeatActions(),
      service.fetchHeatModifiers(),
    ]);
    return HeatData(
      heat: results[0] as int,
      actions: results[1] as List<HeatAction>,
      modifiers: results[2] as Map<String, dynamic>,
    );
  }

  Future<void> reduceHeat(String actionKey) async {
    final service = HeatService(Supabase.instance.client);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await service.reduceHeat(actionKey);
      return build();
    });
  }
}

class HeatData {
  final int heat;
  final List<HeatAction> actions;
  final Map<String, dynamic> modifiers;
  HeatData({required this.heat, required this.actions, required this.modifiers});
}
