import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/database/database_provider.dart';
import 'package:pos_app/sync/sync_notifier.dart';

/// Global "any local write → sync" trigger. Subscribes to Drift's table-change
/// stream and, a short debounce after the last write, kicks a bidirectional
/// `sync()` (push pending → pull fresh). This realises the offline-first rule:
/// every operation is saved locally first, then the change propagates.
///
/// Loop safety (critical): a sync's own pull writes to many tables. We IGNORE
/// every change that arrives while [syncStateProvider] is loading, so the sync
/// can never re-arm itself. Writes are only ever debounced when no sync is in
/// flight — meaning the pull-writes during a sync set no timer, and nothing
/// fires after the sync completes. A user operation performed mid-sync isn't
/// given its own follow-up, but its row is already saved `pending` locally and
/// ships on the next trigger (any later write, reconnect, or the sync button).
///
/// Kept alive by reading [autoSyncWatcherProvider] from MainLayout, alongside
/// the connectivity watcher.
class AutoSyncWatcher extends Notifier<void> {
  StreamSubscription<void>? _sub;
  Timer? _debounce;

  /// Batches a burst of writes (a checkout writes order + items + payments +
  /// document) into a single sync.
  static const _debounceDelay = Duration(seconds: 3);

  @override
  void build() {
    final db = ref.watch(appDatabaseProvider);
    // `tableUpdates()` (no query) emits on any table write.
    _sub = db.tableUpdates().listen((_) => _onTablesChanged());
    ref.onDispose(() {
      _sub?.cancel();
      _sub = null;
      _debounce?.cancel();
      _debounce = null;
    });
  }

  void _onTablesChanged() {
    // Ignore writes made by a sync that's already running (its own pulls) —
    // this is what prevents an infinite sync loop.
    if (ref.read(syncStateProvider).isLoading) return;
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, _maybeSync);
  }

  Future<void> _maybeSync() async {
    if (ref.read(syncStateProvider).isLoading) return;
    if (ref.read(selectedCompanyProvider)?.id == null) return;

    // Only attempt when online — otherwise every offline write would queue a
    // failing sync and spam the sync-error snackbar. Offline data stays
    // `pending` and ships when the connectivity watcher fires on reconnect.
    final conn = await Connectivity().checkConnectivity();
    final online = conn.any((r) => r != ConnectivityResult.none);
    if (!online) return;

    // Re-check after the async gap — a manual/button sync may have started.
    if (ref.read(syncStateProvider).isLoading) return;

    // Fire-and-forget; the notifier owns state transitions (isLoading is the
    // mutex that keeps this and the button/connectivity syncs from overlapping).
    unawaited(ref.read(syncStateProvider.notifier).sync());
  }
}

/// Read this from a long-lived widget (MainLayout) to keep the watcher alive
/// for the whole post-login session.
final autoSyncWatcherProvider =
    NotifierProvider<AutoSyncWatcher, void>(AutoSyncWatcher.new);
