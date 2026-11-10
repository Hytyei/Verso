import 'dart:convert';
import 'dart:io';

import '../data/attachment_store.dart';
import '../data/db/database.dart';
import 'sync_api.dart';
import 'sync_codec.dart';

/// Where the next sync starts: the server cursor and the push watermark.
class SyncState {
  const SyncState({this.cursor = 0, this.lastPushedAt = 0, this.lastSyncedAt});
  final int cursor;
  final int lastPushedAt;
  final DateTime? lastSyncedAt;

  Map<String, Object?> toJson() => {
    'cursor': cursor,
    'lastPushedAt': lastPushedAt,
    'lastSyncedAt': lastSyncedAt?.toIso8601String(),
  };
  factory SyncState.fromJson(Map<String, Object?> j) => SyncState(
    cursor: (j['cursor'] as num?)?.toInt() ?? 0,
    lastPushedAt: (j['lastPushedAt'] as num?)?.toInt() ?? 0,
    lastSyncedAt: DateTime.tryParse(j['lastSyncedAt'] as String? ?? ''),
  );
}

abstract class SyncStateStore {
  Future<SyncState> read();
  Future<void> write(SyncState s);
}

class MemorySyncStateStore implements SyncStateStore {
  SyncState s = const SyncState();
  @override
  Future<SyncState> read() async => s;
  @override
  Future<void> write(SyncState v) async => s = v;
}

/// `sync_state.json` in the data folder.
class FileSyncStateStore implements SyncStateStore {
  FileSyncStateStore(this.file);
  final File file;
  @override
  Future<SyncState> read() async {
    try {
      return SyncState.fromJson(jsonDecode(await file.readAsString()) as Map<String, Object?>);
    } catch (_) {
      return const SyncState();
    }
  }

  @override
  Future<void> write(SyncState s) async {
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(s.toJson()), flush: true);
    await tmp.rename(file.path);
  }
}

typedef SyncResult = ({int pushed, int pulled, int imagesUp, int imagesDown});

/// One full sync: push local changes (with their images), then pull
/// everything newer than the cursor (and fetch missing images).
class SyncEngine {
  SyncEngine({required this.db, required this.api, required this.state, required this.attachments});
  final VersoDb db;
  final SyncApi api;
  final SyncStateStore state;
  final AttachmentStore attachments;

  Future<SyncResult> run() async {
    final codec = SyncCodec(db);
    var s = await state.read();
    final startedAt = db.now();
    final local = await codec.changedSince(s.lastPushedAt);
    var cursor = s.cursor;
    var pulled = 0, imagesUp = 0, imagesDown = 0;
    final pulledAttachments = <String>{};

    Future<void> applyPage(SyncPage page) async {
      for (final r in page.rows) {
        if (await codec.apply(r)) {
          pulled++;
          if (r.t == 'attachments' && !r.d) pulledAttachments.add(r.id);
        }
      }
      cursor = page.cursor;
    }

    // Images first, so a row never arrives on another device before its file.
    for (final r in local.where((r) => r.t == 'attachments' && !r.d)) {
      final name = r.data['fileName'] as String;
      final f = File('${attachments.root.path}${Platform.pathSeparator}$name');
      if (!f.existsSync()) continue;
      if (!await api.hasBlob(name)) {
        await api.putBlob(name, await f.readAsBytes());
        imagesUp++;
      }
    }

    // Push in batches; each response also carries a page of changes.
    for (var i = 0; i < local.length; i += SyncApi.maxPush) {
      final batch = local.sublist(i, (i + SyncApi.maxPush).clamp(0, local.length));
      await applyPage(await api.sync(cursor, batch));
    }
    // Pull the rest.
    var more = true;
    while (more) {
      final page = await api.sync(cursor, const []);
      await applyPage(page);
      more = page.more;
    }

    // Download images that arrived as rows.
    for (final id in pulledAttachments) {
      final a = await (db.select(db.attachments)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (a == null || a.deleted || attachments.original(a).existsSync()) continue;
      final bytes = await api.getBlob(a.fileName);
      if (bytes == null) continue;
      await attachments.restoreFile(a, bytes);
      imagesDown++;
    }

    await state.write(SyncState(cursor: cursor, lastPushedAt: startedAt, lastSyncedAt: DateTime.now()));
    return (pushed: local.length, pulled: pulled, imagesUp: imagesUp, imagesDown: imagesDown);
  }
}
