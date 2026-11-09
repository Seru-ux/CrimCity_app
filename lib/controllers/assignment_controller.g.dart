// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(assignmentService)
final assignmentServiceProvider = AssignmentServiceProvider._();

final class AssignmentServiceProvider
    extends
        $FunctionalProvider<
          AssignmentService,
          AssignmentService,
          AssignmentService
        >
    with $Provider<AssignmentService> {
  AssignmentServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assignmentServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assignmentServiceHash();

  @$internal
  @override
  $ProviderElement<AssignmentService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AssignmentService create(Ref ref) {
    return assignmentService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssignmentService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssignmentService>(value),
    );
  }
}

String _$assignmentServiceHash() => r'387c7e16275cc9bd855a615e6ebd9c4299a2b0d9';

@ProviderFor(AssignmentManager)
final assignmentManagerProvider = AssignmentManagerProvider._();

final class AssignmentManagerProvider
    extends $AsyncNotifierProvider<AssignmentManager, List<NpcAssignment>> {
  AssignmentManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assignmentManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assignmentManagerHash();

  @$internal
  @override
  AssignmentManager create() => AssignmentManager();
}

String _$assignmentManagerHash() => r'3b37db4419a04a7a874549f3ba67d67db452a883';

abstract class _$AssignmentManager extends $AsyncNotifier<List<NpcAssignment>> {
  FutureOr<List<NpcAssignment>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<NpcAssignment>>, List<NpcAssignment>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<NpcAssignment>>, List<NpcAssignment>>,
              AsyncValue<List<NpcAssignment>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
