import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/sync/sync_provider.dart';

/// Tracks the in-flight state of a manual sync. Initial value is `void` —
/// `isLoading` becomes true while a sync is running, and `hasError` flips
/// true after a failed run (with the exception in `error`).
class SyncNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Idle state — no work in flight at startup.
    return;
  }

  /// Kicks off a full bidirectional sync. UI bindings should call this and
  /// observe `state.isLoading` / `state.hasError` rather than awaiting the
  /// future, so multiple consumers can react without races.
  Future<void> sync() async {
    final companyId = ref.read(selectedCompanyProvider)?.id;
    if (companyId == null) {
      // No company selected — surface as an error so the snackbar fires.
      state = AsyncError(
        StateError('No company selected.'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(syncManagerProvider).sync(companyId),
    );
  }
}

final syncStateProvider = AsyncNotifierProvider<SyncNotifier, void>(
  SyncNotifier.new,
);
