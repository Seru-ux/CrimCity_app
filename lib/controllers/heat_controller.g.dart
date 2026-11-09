// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heat_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HeatManager)
final heatManagerProvider = HeatManagerProvider._();

final class HeatManagerProvider
    extends $AsyncNotifierProvider<HeatManager, HeatData> {
  HeatManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'heatManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$heatManagerHash();

  @$internal
  @override
  HeatManager create() => HeatManager();
}

String _$heatManagerHash() => r'e02d1c6e07f767a2652bb06fcd8b294bbfb95a60';

abstract class _$HeatManager extends $AsyncNotifier<HeatData> {
  FutureOr<HeatData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<HeatData>, HeatData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<HeatData>, HeatData>,
              AsyncValue<HeatData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
