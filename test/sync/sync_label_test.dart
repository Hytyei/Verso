import 'package:flutter_test/flutter_test.dart';
import 'package:verso/sync/sync_controller.dart';
import 'package:verso/ui/shell/sync_indicator.dart';

void main() {
  test('the indicator says whether data is on the server', () {
    expect(syncLabel(const SyncStatus.off()), 'Not syncing (signed out)');
    expect(syncLabel(const SyncStatus(SyncPhase.syncing)), 'Syncing…');
    expect(syncLabel(SyncStatus(SyncPhase.idle, lastSynced: DateTime.now())), startsWith('Synced with the server'));
    expect(syncLabel(SyncStatus(SyncPhase.idle, lastSynced: DateTime.now(), pending: true)), 'Changes waiting to upload');
    expect(syncLabel(const SyncStatus(SyncPhase.failed, error: 'offline')), 'Sync failed: offline');
    expect(SyncStatus(SyncPhase.idle, lastSynced: DateTime.now()).upToDate, isTrue);
    expect(SyncStatus(SyncPhase.idle, lastSynced: DateTime.now(), pending: true).upToDate, isFalse);
  });
}
