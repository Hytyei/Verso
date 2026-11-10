import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/motion.dart';
import '../theme/palette.dart';

/// Skia-safe Liquid Glass (see docs/glass-spike.md): the backdrop is gently
/// magnified inside and bent harder in three rim bands, under a light tint,
/// a vertical sheen and a specular rim. Not frosted: blur is only 0.6σ to
/// anti-alias the resampling. Use on chrome and controls only.
class GlassSurface extends StatefulWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.radius = 16,
    this.padding = EdgeInsets.zero,
    this.large = false,
    this.refract = true,
    this.interactive = false,
    this.onTap,
    this.tint,
  });

  final Widget child;

  /// Corner radius; clamped to half the height, so a big value is a pill.
  final double radius;
  final EdgeInsetsGeometry padding;

  /// Big panels (toolbar, sidebar) get a calmer, lower tint.
  final bool large;

  /// False skips the backdrop lens (rim + tint only), for glass sitting over
  /// static background where refraction would be invisible anyway.
  final bool refract;

  /// Hover brightening and press squash.
  final bool interactive;
  final VoidCallback? onTap;
  final Color? tint;

  /// Rim bands from the edge inwards: (width px, magnification).
  static const bands = [(3.0, 1.17), (3.0, 1.11), (3.0, 1.06)];
  static const innerScale = 1.03;

  @override
  State<GlassSurface> createState() => _GlassSurfaceState();
}

class _GlassSurfaceState extends State<GlassSurface> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    // Glass never samples glass: inside another glass surface, skip the lens.
    final refract = widget.refract && context.dependOnInheritedWidgetOfExactType<_InsideGlass>() == null;
    Widget glass = Stack(
      children: [
        if (refract) ...[
          Positioned.fill(
            child: _Lens(radius: widget.radius, inset: 0, width: null, scale: GlassSurface.innerScale),
          ),
          for (var i = 0; i < GlassSurface.bands.length; i++)
            Positioned.fill(
              child: _Lens(
                radius: widget.radius,
                inset: GlassSurface.bands.take(i).fold(0.0, (s, b) => s + b.$1),
                width: GlassSurface.bands[i].$1,
                scale: GlassSurface.bands[i].$2,
              ),
            ),
        ],
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _RimPainter(
                radius: widget.radius,
                palette: p,
                tint: widget.tint ?? (widget.large ? p.glassTint.withValues(alpha: p.glassTint.a * .6) : p.glassTint),
                hover: widget.interactive && _hover,
              ),
            ),
          ),
        ),
        Padding(padding: widget.padding, child: widget.child),
      ],
    );
    glass = _InsideGlass(child: glass);
    if (!widget.interactive) return glass;
    glass = AnimatedScale(
      scale: _down ? 0.96 : 1,
      duration: Motion.dur(context),
      curve: Motion.curve(context),
      child: glass,
    );
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap,
        child: glass,
      ),
    );
  }
}

RRect _rrect(Size s, double radius, [double inset = 0]) {
  final r = math.max(0.0, math.min(radius, s.shortestSide / 2) - inset);
  return RRect.fromRectAndRadius(
    Rect.fromLTWH(inset, inset, math.max(0, s.width - 2 * inset), math.max(0, s.height - 2 * inset)),
    Radius.circular(r),
  );
}

/// One magnified backdrop band: the full shape when [width] is null,
/// otherwise a ring [width] px wide starting [inset] px from the edge.
class _Lens extends StatelessWidget {
  const _Lens({required this.radius, required this.inset, required this.width, required this.scale});
  final double radius;
  final double inset;
  final double? width;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth, h = c.maxHeight;
        final m = Matrix4.identity()
          ..translateByDouble(w / 2, h / 2, 0, 1)
          ..scaleByDouble(scale, scale, 1, 1)
          ..translateByDouble(-w / 2, -h / 2, 0, 1);
        return ClipPath(
          clipper: _BandClipper(radius, inset, width),
          child: BackdropFilter(
            filter: ui.ImageFilter.compose(
              outer: ui.ImageFilter.blur(sigmaX: .6, sigmaY: .6),
              inner: ui.ImageFilter.matrix(m.storage, filterQuality: FilterQuality.low),
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _BandClipper extends CustomClipper<Path> {
  _BandClipper(this.radius, this.inset, this.width);
  final double radius;
  final double inset;
  final double? width;

  @override
  Path getClip(Size s) {
    final outer = Path()..addRRect(_rrect(s, radius, inset));
    if (width == null) return outer;
    final inner = Path()..addRRect(_rrect(s, radius, inset + width!));
    return Path.combine(PathOperation.difference, outer, inner);
  }

  @override
  bool shouldReclip(_BandClipper o) => o.radius != radius || o.inset != inset || o.width != width;
}

class _RimPainter extends CustomPainter {
  _RimPainter({required this.radius, required this.palette, required this.tint, required this.hover});
  final double radius;
  final VersoPalette palette;
  final Color tint;
  final bool hover;

  @override
  void paint(Canvas canvas, Size s) {
    final r = _rrect(s, radius);
    final dark = palette.isDark;
    canvas.drawRRect(r, Paint()..color = hover ? Color.alphaBlend(const Color(0x0FFFFFFF), tint) : tint);
    // Vertical sheen: light from above, a touch of depth below.
    canvas.drawRRect(
      r,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, s.height),
          [Color(dark ? 0x14FFFFFF : 0x30FFFFFF), const Color(0x00FFFFFF), Color(dark ? 0x22000000 : 0x0C1E2A3B)],
          const [0, .55, 1],
        ),
    );
    // Specular rim: bright top-left, faint sides, a returning glint bottom-right.
    canvas.drawRRect(
      r.deflate(.6),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(s.width, s.height),
          [
            Color(dark ? 0x8CFFF3E2 : 0xF2FFFFFF),
            Color(dark ? 0x1FFFFFFF : 0x40FFFFFF),
            Color(dark ? 0x0AFFFFFF : 0x14FFFFFF),
            Color(dark ? 0x52FFE7C7 : 0xB3FFFFFF),
          ],
          const [0, .35, .65, 1],
        ),
    );
    // Hairline outer edge so glass reads on light backgrounds.
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .6
        ..color = Color(dark ? 0x33000000 : 0x1A1E2A3B),
    );
  }

  @override
  bool shouldRepaint(_RimPainter o) => o.radius != radius || o.palette != palette || o.tint != tint || o.hover != hover;
}

/// Marks a subtree as sitting on glass (see [GlassSurface]).
class _InsideGlass extends InheritedWidget {
  const _InsideGlass({required super.child});
  @override
  bool updateShouldNotify(_InsideGlass old) => false;
}
