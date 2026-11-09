// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'npc_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(npcService)
final npcServiceProvider = NpcServiceProvider._();

final class NpcServiceProvider
    extends $FunctionalProvider<NpcService, NpcService, NpcService>
    with $Provider<NpcService> {
  NpcServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'npcServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$npcServiceHash();

  @$internal
  @override
  $ProviderElement<NpcService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NpcService create(Ref ref) {
    return npcService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NpcService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NpcService>(value),
    );
  }
}

String _$npcServiceHash() => r'49a5072af0a8a3e68a10bb9d06864cfc32a3b752';

@ProviderFor(NpcList)
final npcListProvider = NpcListProvider._();

final class NpcListProvider extends $AsyncNotifierProvider<NpcList, void> {
  NpcListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'npcListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$npcListHash();

  @$internal
  @override
  NpcList create() => NpcList();
}

String _$npcListHash() => r'0be417eee44c700137304fec75d6b5ba5dc099df';

abstract class _$NpcList extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(availableNpcs)
final availableNpcsProvider = AvailableNpcsProvider._();

final class AvailableNpcsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Npc>>,
          List<Npc>,
          FutureOr<List<Npc>>
        >
    with $FutureModifier<List<Npc>>, $FutureProvider<List<Npc>> {
  AvailableNpcsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableNpcsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableNpcsHash();

  @$internal
  @override
  $FutureProviderElement<List<Npc>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Npc>> create(Ref ref) {
    return availableNpcs(ref);
  }
}

String _$availableNpcsHash() => r'0f24872df33c8244c955a488d992774104d22d08';

@ProviderFor(myCrew)
final myCrewProvider = MyCrewProvider._();

final class MyCrewProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PlayerNpc>>,
          List<PlayerNpc>,
          FutureOr<List<PlayerNpc>>
        >
    with $FutureModifier<List<PlayerNpc>>, $FutureProvider<List<PlayerNpc>> {
  MyCrewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myCrewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myCrewHash();

  @$internal
  @override
  $FutureProviderElement<List<PlayerNpc>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PlayerNpc>> create(Ref ref) {
    return myCrew(ref);
  }
}

String _$myCrewHash() => r'a504d18f52cbddf5dc6a7e444e246f82edda10b8';

@ProviderFor(crewSlots)
final crewSlotsProvider = CrewSlotsProvider._();

final class CrewSlotsProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  CrewSlotsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crewSlotsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crewSlotsHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return crewSlots(ref);
  }
}

String _$crewSlotsHash() => r'1297b201aae2d88bf938c1474d429a90c08aa3ea';
