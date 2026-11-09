// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talent_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(talentService)
final talentServiceProvider = TalentServiceProvider._();

final class TalentServiceProvider
    extends $FunctionalProvider<TalentService, TalentService, TalentService>
    with $Provider<TalentService> {
  TalentServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'talentServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$talentServiceHash();

  @$internal
  @override
  $ProviderElement<TalentService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TalentService create(Ref ref) {
    return talentService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TalentService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TalentService>(value),
    );
  }
}

String _$talentServiceHash() => r'e38ad6d981f48e5b9e44c502a60d4253cb639060';

@ProviderFor(TalentManager)
final talentManagerProvider = TalentManagerProvider._();

final class TalentManagerProvider
    extends $AsyncNotifierProvider<TalentManager, TalentState> {
  TalentManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'talentManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$talentManagerHash();

  @$internal
  @override
  TalentManager create() => TalentManager();
}

String _$talentManagerHash() => r'0391a2a8465a295ac8e81d615fe62ae53dff692e';

abstract class _$TalentManager extends $AsyncNotifier<TalentState> {
  FutureOr<TalentState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TalentState>, TalentState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TalentState>, TalentState>,
              AsyncValue<TalentState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
