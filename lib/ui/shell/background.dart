import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Window background: soft blue-lavender gradient (light) or pure black
/// with a faint warm vignette (dark).
class VersoBackground extends StatelessWidget {
  const VersoBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [p.bgTop, p.bgBottom]),
      ),
      child: p.isDark
          ? DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.25,
                  colors: [const Color(0x00000000), p.vignette],
                  stops: const [.55, 1],
                ),
              ),
              child: child,
            )
          : child,
    );
  }
}
