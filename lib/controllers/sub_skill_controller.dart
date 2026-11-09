import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/sub_skill_service.dart';
import '../models/player_sub_skill.dart';

part 'sub_skill_controller.g.dart';

@riverpod
class SubSkillManager extends _$SubSkillManager {
  @override
  Future<List<dynamic>> build() async {
    // Da PlayerSubSkill leer zu sein scheint, nutzen wir dynamic für den Build-Schritt
    final service = SubSkillService(Supabase.instance.client);
    return service.fetchPlayerSubSkills();
  }
}
