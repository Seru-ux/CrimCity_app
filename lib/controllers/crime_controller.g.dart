// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crime_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CrimeManager)
final crimeManagerProvider = CrimeManagerProvider._();

final class CrimeManagerProvider
    extends $AsyncNotifierProvider<CrimeManager, void> {
  CrimeManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crimeManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crimeManagerHash();

  @$internal
  @override
  CrimeManager create() => CrimeManager();
}

String _$crimeManagerHash() => r'89f56a7ea76956cb05be0aeeb8338b272cf2f3e6';

abstract class _$CrimeManager extends $AsyncNotifier<void> {
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
