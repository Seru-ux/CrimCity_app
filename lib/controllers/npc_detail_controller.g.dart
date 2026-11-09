// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'npc_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NpcDetail)
final npcDetailProvider = NpcDetailFamily._();

final class NpcDetailProvider
    extends $AsyncNotifierProvider<NpcDetail, NpcDetailData> {
  NpcDetailProvider._({
    required NpcDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'npcDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$npcDetailHash();

  @override
  String toString() {
    return r'npcDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  NpcDetail create() => NpcDetail();

  @override
  bool operator ==(Object other) {
    return other is NpcDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$npcDetailHash() => r'2ffea951363c9da8750f84ed4dbb19e6f6c1a3c9';

final class NpcDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          NpcDetail,
          AsyncValue<NpcDetailData>,
          NpcDetailData,
          FutureOr<NpcDetailData>,
          String
        > {
  NpcDetailFamily._()
    : super(
        retry: null,
        name: r'npcDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NpcDetailProvider call(String playerNpcId) =>
      NpcDetailProvider._(argument: playerNpcId, from: this);

  @override
  String toString() => r'npcDetailProvider';
}

abstract class _$NpcDetail extends $AsyncNotifier<NpcDetailData> {
  late final _$args = ref.$arg as String;
  String get playerNpcId => _$args;

  FutureOr<NpcDetailData> build(String playerNpcId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<NpcDetailData>, NpcDetailData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<NpcDetailData>, NpcDetailData>,
              AsyncValue<NpcDetailData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
