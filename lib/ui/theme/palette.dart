import 'package:flutter/material.dart';

import '../../data/models.dart';

/// Verso colors (spec §6.1 light, §6.2 dark). Palette slots 0-3 map to
/// each theme's four accents; custom colors pass through unchanged.
@immutable
class VersoPalette extends ThemeExtension<VersoPalette> {
  const VersoPalette({
    required this.brightness,
    required this.bgTop,
    required this.bgBottom,
    required this.vignette,
    required this.surface,
    required this.surfaceRaised,
    required this.rim,
    required this.text,
    required this.textSecondary,
    required this.separator,
    required this.accents,
    required this.accentTints,
    required this.primary,
    required this.coral,
    required this.coralTint,
    required this.glassTint,
    required this.shadow,
  });

  final Brightness brightness;
  final Color bgTop;
  final Color bgBottom;
  final Color vignette;
  final Color surface;
  final Color surfaceRaised;
  final Color rim;
  final Color text;
  final Color textSecondary;
  final Color separator;
  final List<Color> accents;
  final List<Color> accentTints;
  final Color primary;

  /// Used for "Delayed" chips and destructive hints.
  final Color coral;
  final Color coralTint;
  final Color glassTint;
  final Color shadow;

  bool get isDark => brightness == Brightness.dark;

  static const light = VersoPalette(
    brightness: Brightness.light,
    bgTop: Color(0xFFEEF2F8),
    bgBottom: Color(0xFFE9EBF7),
    vignette: Color(0x00000000),
    surface: Color(0xB8FFFFFF),
    surfaceRaised: Color(0xFFFFFFFF),
    rim: Color(0xFFFFFFFF),
    text: Color(0xFF1E2A3B),
    textSecondary: Color(0xFF6B7A90),
    separator: Color(0xFFC9D3E1),
    accents: [Color(0xFF3B82D6), Color(0xFFE3AE36), Color(0xFFE5675A), Color(0xFF3E4C68)],
    accentTints: [Color(0xFFD7E6F6), Color(0xFFFAEFD0), Color(0xFFF9DCDA), Color(0xFFDDE3EC)],
    primary: Color(0xFF3B82D6),
    coral: Color(0xFFE5675A),
    coralTint: Color(0xFFF9DCDA),
    glassTint: Color(0x24FFFFFF),
    shadow: Color(0x1A3E4C68),
  );

  static const dark = VersoPalette(
    brightness: Brightness.dark,
    bgTop: Color(0xFF000000),
    bgBottom: Color(0xFF000000),
    vignette: Color(0xFF0E0B08),
    surface: Color(0xFF15120F),
    surfaceRaised: Color(0xFF1E1A16),
    rim: Color(0x14FFFFFF),
    text: Color(0xFFF4EEE6),
    textSecondary: Color(0xFFA39886),
    separator: Color(0xFF2A251F),
    accents: [Color(0xFFF5A524), Color(0xFFFF7A59), Color(0xFFF2668B), Color(0xFFE2C08D)],
    accentTints: [Color(0xFF3A2A0E), Color(0xFF3D1C14), Color(0xFF3B1621), Color(0xFF2F271B)],
    primary: Color(0xFFF5A524),
    coral: Color(0xFFFF7A59),
    coralTint: Color(0xFF3D1C14),
    glassTint: Color(0x2E2A241E),
    shadow: Color(0x66000000),
  );

  Color resolve(VColor c) => c.custom ? Color(c.value) : accents[c.value.clamp(0, 3)];

  /// Soft background for a color: the slot's tint, or the custom color
  /// mixed over the card surface.
  Color resolveTint(VColor c) => c.custom
      ? Color.alphaBlend(Color(c.value).withValues(alpha: isDark ? .22 : .16), surfaceRaised)
      : accentTints[c.value.clamp(0, 3)];

  static VersoPalette of(BuildContext context) => Theme.of(context).extension<VersoPalette>()!;

  @override
  VersoPalette copyWith() => this;

  @override
  VersoPalette lerp(covariant VersoPalette? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return VersoPalette(
      brightness: t < .5 ? brightness : other.brightness,
      bgTop: l(bgTop, other.bgTop),
      bgBottom: l(bgBottom, other.bgBottom),
      vignette: l(vignette, other.vignette),
      surface: l(surface, other.surface),
      surfaceRaised: l(surfaceRaised, other.surfaceRaised),
      rim: l(rim, other.rim),
      text: l(text, other.text),
      textSecondary: l(textSecondary, other.textSecondary),
      separator: l(separator, other.separator),
      accents: [for (var i = 0; i < 4; i++) l(accents[i], other.accents[i])],
      accentTints: [for (var i = 0; i < 4; i++) l(accentTints[i], other.accentTints[i])],
      primary: l(primary, other.primary),
      coral: l(coral, other.coral),
      coralTint: l(coralTint, other.coralTint),
      glassTint: l(glassTint, other.glassTint),
      shadow: l(shadow, other.shadow),
    );
  }
}
