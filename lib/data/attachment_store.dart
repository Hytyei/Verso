import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import 'db/database.dart';
import 'repos/ordering.dart';

/// Result of adding an image: either the stored row or a rejection reason.
class AttachmentResult {
  const AttachmentResult.ok(Attachment this.attachment) : reason = '';
  const AttachmentResult.rejected(this.reason) : attachment = null;
  final Attachment? attachment;
  final String reason;
}

/// Copies images into `<root>\<uuid>.<ext>` with a 512 px PNG thumbnail.
/// Decoding and resizing run in a background isolate.
class AttachmentStore {
  AttachmentStore(this.db, this.root, {this.maxBytes = 40 * 1024 * 1024, this.maxPixels = 60000000});
  final VersoDb db;
  final Directory root;

  /// Larger files are refused before reading them in full.
  final int maxBytes;

  /// Larger images are refused from their header, before decoding
  /// (a 20k×20k PNG would need over a gigabyte).
  final int maxPixels;

  static const accepted = {'png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp'};
  static const thumbMax = 512;

  File original(Attachment a) => File(p.join(root.path, a.fileName));
  File thumb(Attachment a) => File(p.join(root.path, '${p.basenameWithoutExtension(a.fileName)}.thumb.png'));

  Future<AttachmentResult> addFile(String featureId, File f) async {
    final ext = p.extension(f.path).replaceFirst('.', '').toLowerCase();
    if (!accepted.contains(ext)) return const AttachmentResult.rejected('Not an image file');
    final Uint8List bytes;
    try {
      if (await f.length() > maxBytes) {
        return AttachmentResult.rejected('Images over ${maxBytes ~/ (1024 * 1024)} MB are not supported');
      }
      bytes = await f.readAsBytes();
    } on FileSystemException {
      return const AttachmentResult.rejected('Could not read the file');
    }
    return _store(featureId, bytes, ext, p.basename(f.path));
  }

  Future<AttachmentResult> addBytes(String featureId, Uint8List bytes, String ext) =>
      _store(featureId, bytes, ext.toLowerCase(), 'Pasted image.$ext');

  Future<AttachmentResult> _store(String featureId, Uint8List bytes, String ext, String originalName) async {
    if (bytes.length > maxBytes) {
      return AttachmentResult.rejected('Images over ${maxBytes ~/ (1024 * 1024)} MB are not supported');
    }
    final limit = maxPixels;
    final _Decoded? decoded;
    try {
      decoded = await Isolate.run(() => _thumbnail(bytes, limit));
    } catch (_) {
      return const AttachmentResult.rejected('The image could not be read');
    }
    if (decoded == null) return const AttachmentResult.rejected('The image could not be read');
    if (decoded.png.isEmpty) return const AttachmentResult.rejected('The image is too large (over 60 megapixels)');
    final id = db.newId();
    final fileName = '$id.$ext';
    await root.create(recursive: true);
    final orig = File(p.join(root.path, fileName));
    final th = File(p.join(root.path, '$id.thumb.png'));
    try {
      await orig.writeAsBytes(bytes, flush: true);
      await th.writeAsBytes(decoded.png, flush: true);
      final existing =
          await (db.select(db.attachments)
                ..where((t) => t.featureId.equals(featureId) & t.deleted.equals(false))
                ..orderBy([(t) => OrderingTerm(expression: t.sortKey)]))
              .get();
      final now = db.now();
      await db
          .into(db.attachments)
          .insert(
            AttachmentsCompanion.insert(
              id: id,
              createdAt: now,
              updatedAt: now,
              featureId: featureId,
              fileName: fileName,
              originalName: originalName,
              width: decoded.width,
              height: decoded.height,
              sortKey: placeKey([for (final e in existing) (e.id, e.sortKey)]),
            ),
          );
    } catch (_) {
      if (orig.existsSync()) orig.deleteSync();
      if (th.existsSync()) th.deleteSync();
      rethrow;
    }
    final row = await (db.select(db.attachments)..where((t) => t.id.equals(id))).getSingle();
    return AttachmentResult.ok(row);
  }

  Future<void> setDeleted(String id, bool deleted) => (db.update(
    db.attachments,
  )..where((t) => t.id.equals(id))).write(AttachmentsCompanion(deleted: Value(deleted), updatedAt: Value(db.now())));

  /// Writes a synced image's bytes for an existing row, plus its thumbnail.
  Future<void> restoreFile(Attachment a, Uint8List bytes) async {
    await root.create(recursive: true);
    await original(a).writeAsBytes(bytes, flush: true);
    final limit = maxPixels;
    try {
      final d = await Isolate.run(() => _thumbnail(bytes, limit));
      if (d != null && d.png.isNotEmpty) await thumb(a).writeAsBytes(d.png, flush: true);
    } catch (_) {
      // The original is saved; the strip shows a placeholder without a thumb.
    }
  }

  Stream<List<Attachment>> watchForFeature(String featureId) =>
      (db.select(db.attachments)
            ..where((t) => t.featureId.equals(featureId) & t.deleted.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.sortKey)]))
          .watch();
}

class _Decoded {
  _Decoded(this.width, this.height, this.png);
  final int width;
  final int height;
  final Uint8List png;
}

/// Null when undecodable; an empty png marks "too large" (checked from the
/// header before the pixels are decoded).
_Decoded? _thumbnail(Uint8List bytes, int maxPixels) {
  final info = img.findDecoderForData(bytes)?.startDecode(bytes);
  if (info != null && info.width * info.height > maxPixels) return _Decoded(info.width, info.height, Uint8List(0));
  final image = img.decodeImage(bytes);
  if (image == null) return null;
  final w = image.width, h = image.height;
  final scale = (AttachmentStore.thumbMax / (w > h ? w : h)).clamp(0.0, 1.0);
  final t = scale < 1
      ? img.copyResize(
          image,
          width: (w * scale).round().clamp(1, AttachmentStore.thumbMax),
          height: (h * scale).round().clamp(1, AttachmentStore.thumbMax),
          interpolation: img.Interpolation.average,
        )
      : image;
  return _Decoded(w, h, img.encodePng(t));
}
