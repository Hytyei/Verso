import 'package:flutter/material.dart';

import 'palette.dart';

ThemeData versoTheme(Brightness b) {
  final p = b == Brightness.dark ? VersoPalette.dark : VersoPalette.light;
  final base = ThemeData(
    useMaterial3: true,
    brightness: b,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: p.primary,
      brightness: b,
      primary: p.primary,
      surface: p.surfaceRaised,
      onSurface: p.text,
    ),
  );
  final tt = base.textTheme.apply(bodyColor: p.text, displayColor: p.text, fontFamily: 'Inter');
  return base.copyWith(
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: p.text.withValues(alpha: .04),
    dividerColor: p.separator,
    textTheme: tt.copyWith(
      // iOS large title
      headlineMedium: tt.headlineMedium?.copyWith(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6),
      titleMedium: tt.titleMedium?.copyWith(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2),
      bodyMedium: tt.bodyMedium?.copyWith(fontSize: 14, height: 1.38, letterSpacing: -0.1),
      bodySmall: tt.bodySmall?.copyWith(fontSize: 12, color: p.textSecondary),
      labelSmall: tt.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: p.primary,
      selectionColor: p.primary.withValues(alpha: .25),
      selectionHandleColor: p.primary,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thickness: const WidgetStatePropertyAll(6),
      radius: const Radius.circular(3),
      thumbColor: WidgetStatePropertyAll(p.text.withValues(alpha: .18)),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: p.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: p.shadow, blurRadius: 12)],
      ),
      textStyle: TextStyle(color: p.text, fontSize: 12, fontFamily: 'Inter'),
    ),
    extensions: [p],
  );
}
