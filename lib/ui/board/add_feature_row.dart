import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';
import 'feature_actions.dart';

/// "+ Add feature" at the bottom of a column. Enter adds and keeps the
/// field open for the next item; Shift+Enter is a newline; Esc closes.
class AddFeatureRow extends ConsumerStatefulWidget {
  const AddFeatureRow({super.key, required this.versionId, this.label = 'Add feature'});
  final String versionId;
  final String label;

  @override
  ConsumerState<AddFeatureRow> createState() => AddFeatureRowState();
}

class AddFeatureRowState extends ConsumerState<AddFeatureRow> {
  bool _open = false;
  bool _hover = false;
  final _ctrl = TextEditingController();
  late final _focus = FocusNode(onKeyEvent: _onKey);

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void open() {
    setState(() => _open = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _close() {
    _ctrl.clear();
    setState(() => _open = false);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    if (e.logicalKey == LogicalKeyboardKey.escape) {
      _close();
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.enter && !HardwareKeyboard.instance.isShiftPressed) {
      _submit();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      _close();
      return;
    }
    _ctrl.clear();
    await FeatureActions(ref).create(widget.versionId, text);
    if (mounted) _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    ref.listen(addFeatureRequestProvider, (_, id) {
      if (id == widget.versionId) {
        open();
        ref.read(addFeatureRequestProvider.notifier).set(null);
      }
    });
    return AnimatedSwitcher(
      duration: Motion.smoothDur(context),
      child: _open
          ? Container(
              key: const ValueKey('field'),
              padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
              decoration: BoxDecoration(
                color: p.surfaceRaised,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: p.primary.withValues(alpha: .5), width: 1.4),
              ),
              child: TextField(
                key: Key('add-field-${widget.versionId}'),
                controller: _ctrl,
                focusNode: _focus,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                onTapOutside: (_) {
                  if (_ctrl.text.trim().isEmpty) _close();
                },
                style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 1.38, color: p.text),
                decoration: InputDecoration.collapsed(
                  hintText: 'Describe the feature…',
                  hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 14, color: p.textSecondary),
                ),
              ),
            )
          : MouseRegion(
              key: const ValueKey('button'),
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _hover = true),
              onExit: (_) => setState(() => _hover = false),
              child: GestureDetector(
                key: Key('add-feature-${widget.versionId}'),
                behavior: HitTestBehavior.opaque,
                onTap: open,
                child: AnimatedContainer(
                  duration: Motion.smoothDur(context),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: _hover ? p.text.withValues(alpha: .05) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_rounded, size: 18, color: p.textSecondary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: p.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
