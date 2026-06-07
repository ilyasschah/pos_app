import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:pos_app/navigation/nav_widgets.dart';
import 'package:pos_app/sync/pending_count_provider.dart';
import 'package:pos_app/sync/sync_notifier.dart';
import 'package:pos_app/utils/error_handler.dart';
import 'package:pos_app/utils/snackbar_helper.dart';

/// Sidebar / AppBar action that triggers a full bidirectional sync
/// (push pending offline orders, then pull master data deltas).
///
/// While [syncStateProvider] is loading, the icon is replaced by a small
/// spinner and the button is disabled. Toast appears on every transition
/// out of the loading state — success or failure.
class SyncButton extends ConsumerWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Toast on every transition out of loading. Stays attached for the life
    // of this widget; ref.listen registers a one-shot callback per change.
    ref.listen<AsyncValue<void>>(syncStateProvider, (prev, next) {
      if (prev is! AsyncLoading || next is AsyncLoading) return;
      if (next is AsyncError) {
        showAppSnackbar(
          context,
          ref,
          friendlyErrorMessage(next.error),
          isError: true,
        );
      } else {
        showAppSnackbar(context, ref, 'Sync complete');
      }
    });

    final state = ref.watch(syncStateProvider);
    final isLoading = state.isLoading;
    final pendingCount = ref.watch(pendingOrdersCountProvider).value ?? 0;
    final muted = context.navMuted;

    final tooltip = isLoading
        ? 'Syncing…'
        : pendingCount > 0
            ? '$pendingCount pending — tap to sync'
            : 'Sync now';

    // The badge only sits on the idle icon. While syncing we swap the icon
    // for a spinner — wrapping that in a badge would look noisy (spinner +
    // count animating together).
    final iconOrSpinner = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(muted),
                ),
              ),
            ),
          )
        : Badge.count(
            count: pendingCount,
            isLabelVisible: pendingCount > 0,
            child: Icon(
              PhosphorIcons.arrowsClockwise(),
              size: 20,
              color: muted,
            ),
          );

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: isLoading
            ? null
            : () => ref.read(syncStateProvider.notifier).sync(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: iconOrSpinner,
        ),
      ),
    );
  }
}
