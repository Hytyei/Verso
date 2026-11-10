import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:image_picker/image_picker.dart';
import 'package:pasteboard/pasteboard.dart';

import '../../data/db/database.dart';
import '../../data/undo.dart';
import '../../state/providers.dart';
import '../common/lightbox.dart';
import '../common/toast.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';

/// Reads a provider (WidgetRef.read or ProviderContainer.read).
typedef Reader = T Function<T>(ProviderListenable<T> provider);

/// Stores dropped files as attachments; rejected files show a toast.
Future<void> handleDroppedFiles(BuildContext context, Reader read, String featureId, List<String> paths) async {
  final store = read(attachmentStoreProvider);
  for (final path in paths) {
    try {
      final r = await store.addFile(featureId, File(path));
      if (r.attachment == null && context.mounted) showToast(context, r.reason);
    } catch (_) {
      if (context.mounted) showToast(context, 'The image could not be saved');
    }
  }
}

/// Adds the clipboard image (if any) to the feature. Returns whether one was found.
Future<bool> pasteImage(BuildContext context, Reader read, String featureId) async {
  try {
    final bytes = await Pasteboard.image;
    if (bytes == null) return false;
    final r = await read(attachmentStoreProvider).addBytes(featureId, bytes, 'png');
    if (r.attachment == null && context.mounted) showToast(context, r.reason);
  } catch (_) {
    if (context.mounted) showToast(context, 'The pasted image could not be saved');
  }
  return true;
}

final _attachmentsProvider = StreamProvider.family<List<Attachment>, String>(
  (ref, featureId) => ref.watch(attachmentStoreProvider).watchForFeature(featureId),
);

/// Thumbnails of a feature's images, a drop zone, and the lightbox.
class AttachmentStrip extends ConsumerStatefulWidget {
  const AttachmentStrip({super.key, required this.featureId});
  final String featureId;

  @override
  ConsumerState<AttachmentStrip> createState() => _AttachmentStripState();
}

class _AttachmentStripState extends ConsumerState<AttachmentStrip> {
  bool _over = false;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    final store = ref.watch(attachmentStoreProvider);
    final atts = ref.watch(_attachmentsProvider(widget.featureId)).value ?? const <Attachment>[];
    final touch = ref.watch(touchModeProvider);
    Future<void> remove(Attachment a) async {
      final undo = ref.read(undoProvider);
      final action = removeAttachmentAction(store, a.id);
      await undo.run(action);
      if (context.mounted) showToast(context, 'Image removed', onUndo: () => undo.undoIfTop(action));
    }
    return DropTarget(
      onDragEntered: (_) => setState(() => _over = true),
      onDragExited: (_) => setState(() => _over = false),
      onDragDone: (d) {
        setState(() => _over = false);
        handleDroppedFiles(context, ref.read, widget.featureId, [for (final f in d.files) f.path]);
      },
      child: AnimatedContainer(
        duration: Motion.smoothDur(context),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _over ? p.primary.withValues(alpha: .10) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _over ? p.primary.withValues(alpha: .5) : p.separator.withValues(alpha: .6)),
        ),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final a in atts)
              GestureDetector(
                onTap: () => showLightbox(context, store.original(a)),
                onSecondaryTap: () => remove(a),
                // Touch: long-press removes (undo in the toast).
                onLongPress: touch ? () => remove(a) : null,
                child: MouseRegion(
                  cursor: SystemMouseCursors.zoomIn,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      store.thumb(a),
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      cacheWidth: 128,
                      errorBuilder: (_, _, _) => Container(width: 64, height: 64, color: p.separator),
                    ),
                  ),
                ),
              ),
            if (touch)
              TextButton.icon(
                key: Key('add-photos-${widget.featureId}'),
                onPressed: () async {
                  try {
                    final picked = await ImagePicker().pickMultiImage(requestFullMetadata: false);
                    if (picked.isEmpty || !context.mounted) return;
                    await handleDroppedFiles(context, ref.read, widget.featureId, [for (final x in picked) x.path]);
                  } catch (_) {
                    if (context.mounted) showToast(context, 'Photos could not be opened');
                  }
                },
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                label: Text(atts.isEmpty ? 'Add photos' : 'More'),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  atts.isEmpty ? 'Drop or paste images here' : 'Drop more',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: p.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
