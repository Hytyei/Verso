import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';
import '../theme/palette.dart';

/// Frameless window's drag strip with minimize / maximize / close.
class TitleBar extends ConsumerWidget {
  const TitleBar({super.key});
  static const height = 36.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final win = ref.watch(windowApiProvider);
    final p = VersoPalette.of(context);
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (_) => win.startDrag(),
              onDoubleTap: win.toggleMaximize,
              child: Padding(
                padding: const EdgeInsets.only(left: 18),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.5),
                        gradient: LinearGradient(colors: [p.accents[0], p.accents[2]]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Verso',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: p.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _WinButton(icon: Icons.remove_rounded, onTap: win.minimize, tooltip: 'Minimize'),
          _WinButton(icon: Icons.crop_square_rounded, onTap: win.toggleMaximize, tooltip: 'Maximize', size: 13),
          _WinButton(icon: Icons.close_rounded, onTap: win.close, tooltip: 'Close', danger: true),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _WinButton extends StatefulWidget {
  const _WinButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.danger = false,
    this.size = 16,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool danger;
  final double size;

  @override
  State<_WinButton> createState() => _WinButtonState();
}

class _WinButtonState extends State<_WinButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    final bg = !_hover
        ? Colors.transparent
        : widget.danger
        ? const Color(0xFFE5484D)
        : p.text.withValues(alpha: .08);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 40,
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
          child: Icon(widget.icon, size: widget.size, color: _hover && widget.danger ? Colors.white : p.textSecondary),
        ),
      ),
    );
  }
}
