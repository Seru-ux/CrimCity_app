// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_skill_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SubSkillManager)
final subSkillManagerProvider = SubSkillManagerProvider._();

final class SubSkillManagerProvider
    extends $AsyncNotifierProvider<SubSkillManager, List<dynamic>> {
  SubSkillManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subSkillManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subSkillManagerHash();

  @$internal
  @override
  SubSkillManager create() => SubSkillManager();
}

String _$subSkillManagerHash() => r'48cc03f3a5ce5d95f5ed360f1413385d7ee38d12';

abstract class _$SubSkillManager extends $AsyncNotifier<List<dynamic>> {
  FutureOr<List<dynamic>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<dynamic>>, List<dynamic>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<dynamic>>, List<dynamic>>,
              AsyncValue<List<dynamic>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
