import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../state/providers.dart';
import 'sync_api.dart';
import 'sync_engine.dart';

enum SyncPhase { off, idle, syncing, failed }

class SyncStatus {
  const SyncStatus(this.phase, {this.lastSynced, this.error, this.pending = false});
  const SyncStatus.off() : this(SyncPhase.off);
  final SyncPhase phase;
  final DateTime? lastSynced;
  final String? error;

  /// Local changes made since the last successful sync (not on the server yet).
  final bool pending;

  /// Fully synced: signed in, the last run succeeded and nothing new since.
  bool get upToDate => phase == SyncPhase.idle && !pending && lastSynced != null;

  SyncStatus copyWith({SyncPhase? phase, bool? pending}) =>
      SyncStatus(phase ?? this.phase, lastSynced: lastSynced, error: error, pending: pending ?? this.pending);
}

/// Overridden in main() with the file store in the data folder.
final syncStateStoreProvider = Provider<SyncStateStore>((ref) => MemorySyncStateStore());

/// Whether sync starts on its own (sign-in, launch, timer, local edits).
/// Widget tests turn it off so they never touch the network.
final syncAutoProvider = Provider<bool>((ref) => true);

/// Runs [SyncEngine] when signed in: after sign-in and launch, 3 s after
/// local changes, every 2 minutes, and on demand.
class SyncController extends Notifier<SyncStatus> {
  Timer? _debounce;
  Timer? _periodic;
  StreamSubscription<Object?>? _changes;
  bool _running = false;
  bool _again = false;

  @override
  SyncStatus build() {
    ref.onDispose(_stop);
    final auth = ref.watch(authProvider);
    final url = ref.watch(settingsProvider.select((s) => s.syncUrl)).trim();
    _stop();
    if (auth.status != AuthStatus.signedIn || url.isEmpty) return const SyncStatus.off();
    if (ref.read(syncAutoProvider)) {
      _periodic = Timer.periodic(const Duration(minutes: 2), (_) => syncNow());
      _changes = ref.read(dbProvider).tableUpdates().listen((_) {
        if (_running) return; // our own pulled rows
        if (!state.pending) state = state.copyWith(pending: true);
        _debounce?.cancel();
        _debounce = Timer(const Duration(seconds: 3), syncNow);
      });
      Future.microtask(syncNow);
    }
    return const SyncStatus(SyncPhase.idle);
  }

  void _stop() {
    _debounce?.cancel();
    _periodic?.cancel();
    _changes?.cancel();
    _debounce = null;
    _periodic = null;
    _changes = null;
  }

  Future<void> syncNow() async {
    if (state.phase == SyncPhase.off) return;
    if (_running) {
      _again = true;
      return;
    }
    _running = true;
    final last = state.lastSynced;
    final pending = state.pending;
    state = SyncStatus(SyncPhase.syncing, lastSynced: last, pending: pending);
    try {
      final engine = SyncEngine(
        db: ref.read(dbProvider),
        api: SyncApi(ref.read(settingsProvider).syncUrl.trim(), ref.read(authProvider.notifier).idToken),
        state: ref.read(syncStateStoreProvider),
        attachments: ref.read(attachmentStoreProvider),
      );
      await engine.run();
      state = SyncStatus(SyncPhase.idle, lastSynced: DateTime.now());
    } on SyncApiException catch (e) {
      state = SyncStatus(SyncPhase.failed, lastSynced: last, error: e.message, pending: pending);
    } catch (e) {
      state = SyncStatus(SyncPhase.failed, lastSynced: last, error: '$e', pending: pending);
    } finally {
      // Let the table-update events from our own writes pass before listening again.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      _running = false;
      if (_again) {
        _again = false;
        unawaited(syncNow());
      }
    }
  }
}

final syncProvider = NotifierProvider<SyncController, SyncStatus>(SyncController.new);
