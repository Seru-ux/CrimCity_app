import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/crime_service.dart';

part 'crime_controller.g.dart';

@riverpod
class CrimeManager extends _$CrimeManager {
  @override
  FutureOr<void> build() async {}

  Future<void> commitCrime(String crimeType) async {
    final service = CrimeService(Supabase.instance.client);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await service.commitCrime(crimeType);
    });
  }
}
