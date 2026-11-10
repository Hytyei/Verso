import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import '../data/undo.dart';
import '../state/providers.dart';
import 'board/feature_actions.dart';
import 'board/segment_stub.dart';
import 'common/toast.dart';
import 'shell/filter.dart';

/// App-wide keyboard shortcuts (spec §9). Handled globally so they work
/// wherever focus is, except while typing in a text field.
class ShortcutsHost extends ConsumerStatefulWidget {
  const ShortcutsHost({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<ShortcutsHost> createState() => _ShortcutsHostState();
}

class _ShortcutsHostState extends ConsumerState<ShortcutsHost> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool get _typing {
    final ctx = FocusManager.instance.primaryFocus?.context;
    if (ctx == null) return false;
    return ctx.widget is EditableText || ctx.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  /// A popover, menu or dialog is open above the window.
  bool get _overlayOpen {
    final nav = Navigator.maybeOf(context, rootNavigator: true);
    return nav != null && nav.canPop();
  }

  Version? _versionOf(String featureId) {
    final projectId = ref.read(selectedProjectIdProvider);
    if (projectId == null) return null;
    final versions = ref.read(versionsProvider(projectId)).value ?? const <Version>[];
    for (final v in versions) {
      final views = ref.read(featureViewsProvider(v.id)).value ?? const [];
      if (views.any((x) => x.id == featureId)) return v;
    }
    return null;
  }

  bool _onKey(KeyEvent e) {
    if (e is! KeyDownEvent || !mounted || _typing || _overlayOpen) return false;
    final k = HardwareKeyboard.instance;
    final ctrl = k.isControlPressed || k.isMetaPressed;
    final shift = k.isShiftPressed;
    final key = e.logicalKey;
    final undo = ref.read(undoProvider);
    final focused = ref.read(focusedFeatureProvider);
    final actions = FeatureActions(ref);

    if (ctrl && key == LogicalKeyboardKey.keyZ) {
      hideToast();
      shift ? undo.redo() : undo.undo();
      return true;
    }
    if (ctrl && key == LogicalKeyboardKey.keyY) {
      undo.redo();
      return true;
    }
    if (ctrl && key == LogicalKeyboardKey.digit1) {
      ref.read(viewModeProvider.notifier).set(ViewMode.board);
      return true;
    }
    if (ctrl && key == LogicalKeyboardKey.digit2) {
      ref.read(viewModeProvider.notifier).set(ViewMode.timeline);
      return true;
    }
    if (ctrl && key == LogicalKeyboardKey.keyF) {
      ref.read(searchFocusProvider).requestFocus();
      return true;
    }
    if (ctrl && key == LogicalKeyboardKey.keyN) {
      final projectId = ref.read(selectedProjectIdProvider);
      if (projectId == null) return false;
      if (shift) {
        undo.run(
          createVersionAction(
            ref.read(versionRepoProvider),
            projectId,
            environmentId: ref.read(selectedEnvironmentIdProvider),
          ),
        );
        return true;
      }
      final versions = segmentOf(
        ref.read(versionsProvider(projectId)).value ?? const <Version>[],
        ref.read(selectedEnvironmentIdProvider),
      );
      final target =
          (focused == null ? null : _versionOf(focused)) ??
          versions.where((v) => v.kind == 'release').firstOrNull ??
          versions.firstOrNull;
      if (target == null) return false;
      ref.read(viewModeProvider.notifier).set(ViewMode.board);
      ref.read(addFeatureRequestProvider.notifier).set(target.id);
      return true;
    }
    if (key == LogicalKeyboardKey.escape) {
      if (ref.read(expandedFeatureProvider) != null || focused != null) {
        ref.read(expandedFeatureProvider.notifier).set(null);
        ref.read(focusedFeatureProvider.notifier).set(null);
        return true;
      }
      return false;
    }
    if (focused == null) return false;
    if (ctrl && key == LogicalKeyboardKey.keyD) {
      actions.delay(focused).catchError((Object _) {
        if (mounted) showToast(context, 'No later version yet — use Delay to › New version');
      });
      return true;
    }
    if (!ctrl && key == LogicalKeyboardKey.space) {
      final v = _versionOf(focused);
      final view = v == null
          ? null
          : ref.read(featureViewsProvider(v.id)).value?.where((x) => x.id == focused).firstOrNull;
      if (view == null) return false;
      actions.setDone(focused, !view.f.done);
      return true;
    }
    if (!ctrl && key == LogicalKeyboardKey.f2) {
      ref.read(renameRequestProvider.notifier).set(focused);
      return true;
    }
    if (!ctrl && (key == LogicalKeyboardKey.delete || key == LogicalKeyboardKey.backspace)) {
      ref.read(focusedFeatureProvider.notifier).set(null);
      actions.delete(context, focused);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
