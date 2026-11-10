import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../glass/glass_surface.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';

/// One row of a glass context menu. [children] makes it a submenu.
class MenuItemSpec {
  const MenuItemSpec(
    this.label, {
    this.icon,
    this.onTap,
    this.danger = false,
    this.enabled = true,
    this.children,
    this.shortcut,
  });
  const MenuItemSpec.divider()
    : label = '',
      icon = null,
      onTap = null,
      danger = false,
      enabled = false,
      children = null,
      shortcut = null;
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool danger;
  final bool enabled;
  final List<MenuItemSpec>? children;
  final String? shortcut;
  bool get isDivider => label.isEmpty;
}

/// Shows a glass menu at [position] (global). Resolves when it closes.
Future<void> showGlassMenu(BuildContext context, Offset position, List<MenuItemSpec> items) {
  return showGlassPopover(
    context,
    anchor: Rect.fromLTWH(position.dx, position.dy, 0, 0),
    builder: (ctx, close) => _MenuList(items: items, close: close),
  );
}

/// Glass popover positioned next to [anchor] (global rect), kept on-screen.
/// [builder] receives a close callback.
Future<void> showGlassPopover(
  BuildContext context, {
  required Rect anchor,
  required Widget Function(BuildContext context, VoidCallback close) builder,
  double width = 230,
}) {
  final nav = Navigator.of(context, rootNavigator: true);
  return nav.push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: Motion.reduced(context) ? Motion.fade : const Duration(milliseconds: 220),
      reverseTransitionDuration: Motion.fade,
      pageBuilder: (ctx, a, b) =>
          _PopoverLayout(anchor: anchor, width: width, child: builder(ctx, () => nav.maybePop())),
      transitionsBuilder: (ctx, a, b, child) {
        final curved = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: .94, end: 1.0).animate(curved),
            alignment: Alignment.topLeft,
            child: child,
          ),
        );
      },
    ),
  );
}

class _PopoverLayout extends StatelessWidget {
  const _PopoverLayout({required this.anchor, required this.width, required this.child});
  final Rect anchor;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            onSecondaryTap: () => Navigator.of(context).maybePop(),
          ),
        ),
        CustomSingleChildLayout(
          delegate: _PopoverDelegate(anchor, size),
          child: SizedBox(
            width: math.min(width, size.width - 16),
            child: Material(type: MaterialType.transparency, child: child),
          ),
        ),
      ],
    );
  }
}

class _PopoverDelegate extends SingleChildLayoutDelegate {
  _PopoverDelegate(this.anchor, this.screen);
  final Rect anchor;
  final Size screen;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints c) => BoxConstraints.loose(Size(c.maxWidth, c.maxHeight - 16));

  @override
  Offset getPositionForChild(Size size, Size child) {
    var x = anchor.left;
    var y = anchor.bottom + 4;
    if (x + child.width > size.width - 8) x = size.width - child.width - 8;
    if (y + child.height > size.height - 8) y = math.max(8, anchor.top - child.height - 4);
    return Offset(math.max(8, x), math.max(8, y));
  }

  @override
  bool shouldRelayout(_PopoverDelegate o) => o.anchor != anchor || o.screen != screen;
}

class _MenuList extends StatelessWidget {
  const _MenuList({required this.items, required this.close});
  final List<MenuItemSpec> items;
  final VoidCallback close;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    return GlassSurface(
      radius: 14,
      tint: p.isDark ? const Color(0xF21E1A16) : const Color(0xF2FFFFFF),
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final it in items)
            if (it.isDivider)
              Container(height: 1, margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8), color: p.separator)
            else
              _MenuRow(item: it, close: close),
        ],
      ),
    );
  }
}

class _MenuRow extends StatefulWidget {
  const _MenuRow({required this.item, required this.close});
  final MenuItemSpec item;
  final VoidCallback close;

  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    final it = widget.item;
    final color = !it.enabled ? p.textSecondary.withValues(alpha: .5) : (it.danger ? p.coral : p.text);
    return MouseRegion(
      cursor: it.enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: !it.enabled
            ? null
            : (d) {
                if (it.children != null) {
                  final box = context.findRenderObject() as RenderBox;
                  final r = box.localToGlobal(Offset.zero) & box.size;
                  showGlassPopover(
                    context,
                    anchor: Rect.fromLTWH(r.right, r.top - 4, 0, 0),
                    builder: (ctx, close) => _MenuList(
                      items: it.children!,
                      close: () {
                        close();
                        widget.close();
                      },
                    ),
                  );
                } else {
                  widget.close();
                  it.onTap?.call();
                }
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: _hover && it.enabled ? p.primary.withValues(alpha: p.isDark ? .18 : .12) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              if (it.icon != null) ...[Icon(it.icon, size: 16, color: color), const SizedBox(width: 9)],
              Expanded(
                child: Text(
                  it.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, color: color),
                ),
              ),
              if (it.shortcut != null)
                Text(
                  it.shortcut!,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: p.textSecondary),
                ),
              if (it.children != null) Icon(Icons.chevron_right_rounded, size: 16, color: p.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
