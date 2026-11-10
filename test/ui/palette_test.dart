import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/models.dart';
import 'package:verso/ui/glass/glass_surface.dart';
import 'package:verso/ui/theme/palette.dart';
import 'package:verso/ui/theme/verso_theme.dart';

void main() {
  test('light/dark slot mapping', () {
    expect(VersoPalette.light.resolve(const VColor.slot(0)), const Color(0xFF3B82D6));
    expect(VersoPalette.dark.resolve(const VColor.slot(0)), const Color(0xFFF5A524));
    expect(VersoPalette.light.resolve(const VColor.slot(3)), const Color(0xFF3E4C68));
    expect(VersoPalette.dark.resolve(const VColor.slot(3)), const Color(0xFFE2C08D));
    expect(VersoPalette.dark.resolveTint(const VColor.slot(1)), const Color(0xFF3D1C14));
  });

  test('custom color passes through', () {
    const c = VColor(0xFF12AB34, custom: true);
    expect(VersoPalette.light.resolve(c), const Color(0xFF12AB34));
    expect(VersoPalette.dark.resolve(c), const Color(0xFF12AB34));
  });

  test('dark background is pure black', () {
    expect(VersoPalette.dark.bgTop, const Color(0xFF000000));
    expect(versoTheme(Brightness.dark).extension<VersoPalette>(), VersoPalette.dark);
  });

  testWidgets('GlassSurface renders child over 4 lens layers', (t) async {
    await t.pumpWidget(
      MaterialApp(
        theme: versoTheme(Brightness.light),
        home: const Center(
          child: GlassSurface(child: SizedBox(width: 120, height: 40, child: Text('Board'))),
        ),
      ),
    );
    expect(find.text('Board'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNWidgets(4));
  });

  testWidgets('GlassSurface refract:false has no BackdropFilter', (t) async {
    await t.pumpWidget(
      MaterialApp(
        theme: versoTheme(Brightness.dark),
        home: const Center(child: GlassSurface(refract: false, child: SizedBox(width: 120, height: 40))),
      ),
    );
    expect(find.byType(BackdropFilter), findsNothing);
  });
}
