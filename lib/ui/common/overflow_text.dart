import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';

/// Text cut to [maxLines] with "…" that shows its full content on hover, but only
/// when it was actually cut. A [detail] (an app's or environment's description)
/// is shown under the name on hover whether or not the name fits.
///
/// Phones have no hover: there the tooltip opens on long-press, unless
/// [longPressOnTouch] is false (where long-press already opens a menu).
class OverflowText extends ConsumerWidget {
  const OverflowText(
    this.text, {
    super.key,
    this.style,
    this.detail,
    this.maxLines = 1,
    this.longPressOnTouch = true,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final String? detail;
  final int maxLines;
  final bool longPressOnTouch;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final touch = ref.watch(touchModeProvider);
    final hasDetail = (detail ?? '').trim().isNotEmpty;
    final label = Text(text, maxLines: maxLines, overflow: TextOverflow.ellipsis, style: style, textAlign: textAlign);
    return LayoutBuilder(
      builder: (context, c) {
        var cut = false;
        if (c.maxWidth.isFinite) {
          final tp = TextPainter(
            text: TextSpan(text: text, style: DefaultTextStyle.of(context).style.merge(style)),
            maxLines: maxLines,
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout(maxWidth: c.maxWidth);
          cut = tp.didExceedMaxLines;
          tp.dispose();
        }
        if (!cut && !hasDetail) return label;
        final message = hasDetail ? '$text\n${detail!.trim()}' : text;
        return Tooltip(
          message: message,
          waitDuration: const Duration(milliseconds: 450),
          preferBelow: true,
          constraints: const BoxConstraints(maxWidth: 360),
          triggerMode: touch && !longPressOnTouch ? TooltipTriggerMode.manual : null,
          child: label,
        );
      },
    );
  }
}
