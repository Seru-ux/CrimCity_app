import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/npc_assignment.dart';
import '../services/assignment_service.dart';

part 'assignment_controller.g.dart';

@riverpod
AssignmentService assignmentService(AssignmentServiceRef ref) => 
    AssignmentService(Supabase.instance.client);

@riverpod
class AssignmentManager extends _$AssignmentManager {
  @override
  FutureOr<List<NpcAssignment>> build() async {
    return ref.watch(assignmentServiceProvider).fetchAssignments();
  }

  Future<void> createAssignment({required String npcId, required String heistId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(assignmentServiceProvider).createAssignment(npcId: npcId, heistId: heistId);
      return ref.read(assignmentServiceProvider).fetchAssignments();
    });
  }
}
