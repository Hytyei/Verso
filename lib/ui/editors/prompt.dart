import 'package:flutter/material.dart';

import '../glass/glass_surface.dart';
import '../theme/palette.dart';

/// A small glass dialog with one text field. Returns the trimmed text, or null
/// when cancelled or left empty.
Future<String?> promptText(BuildContext context, {required String title, String initial = '', String hint = ''}) {
  final ctrl = TextEditingController(text: initial)..selection = TextSelection(baseOffset: 0, extentOffset: initial.length);
  return showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0x26000000),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (ctx, _, _) {
      final p = VersoPalette.of(ctx);
      void done() {
        final t = ctrl.text.trim();
        Navigator.pop(ctx, t.isEmpty ? null : t);
      }

      return Center(
        child: Material(
          type: MaterialType.transparency,
          child: SizedBox(
            width: (MediaQuery.sizeOf(ctx).width - 40).clamp(260, 380).toDouble(),
            child: GlassSurface(
              radius: 22,
              tint: p.isDark ? const Color(0xF51E1A16) : const Color(0xF5FFFFFF),
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: p.text)),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextField(
                      key: const Key('prompt-field'),
                      controller: ctrl,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => done(),
                      style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: p.text),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: hint,
                        filled: true,
                        fillColor: p.text.withValues(alpha: .05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(key: const Key('prompt-ok'), onPressed: done, child: const Text('Save')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
