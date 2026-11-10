import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/db/database.dart';
import 'package:verso/data/models.dart';
import 'package:verso/data/repos/feature_repo.dart';
import 'package:verso/data/repos/project_repo.dart';
import 'package:verso/data/repos/version_repo.dart';

import 'harness.dart';

class Ids {
  late String project, concept, v1, v2;
}

Future<Ids> seedBasic(VersoDb db) async {
  final ids = Ids();
  ids.project = await ProjectRepo(db).create('Tandem', const VColor.slot(0));
  ids.v1 = await VersionRepo(db).create(ids.project, 'v1.0');
  ids.v2 = await VersionRepo(db).create(ids.project, 'v1.1');
  ids.concept = (await VersionRepo(db).listForProject(ids.project)).first.id;
  return ids;
}

void main() {
  testWidgets('adding feature via add row shows card', (t) async {
    final ids = Ids();
    final h = await Harness.pump(t, seed: (db) async => ids..project = (await seedBasic(db)).project);
    final v1 = (await t.runAsync(() => VersionRepo(h.db).listForProject(ids.project)))![1].id;
    await t.tap(find.byKey(Key('add-feature-$v1')));
    await Harness.settle(t);
    await t.enterText(find.byKey(Key('add-field-$v1')), 'Sign in with Apple');
    await t.testTextInput.receiveAction(TextInputAction.done);
    await Harness.settle(t);
    expect(find.text('Sign in with Apple'), findsOneWidget);
    // The add row stays open and empty for the next item.
    expect(find.byKey(Key('add-field-$v1')), findsOneWidget);
    expect(t.widget<TextField>(find.byKey(Key('add-field-$v1'))).controller!.text, isEmpty);
    await h.dispose(t);
  });

  testWidgets('Esc in add row cancels', (t) async {
    late Ids ids;
    final h = await Harness.pump(t, seed: (db) async => ids = await seedBasic(db));
    await t.tap(find.byKey(Key('add-feature-${ids.v1}')));
    await Harness.settle(t);
    await t.enterText(find.byKey(Key('add-field-${ids.v1}')), 'Draft');
    await t.sendKeyEvent(LogicalKeyboardKey.escape);
    await Harness.settle(t);
    expect(find.byKey(Key('add-field-${ids.v1}')), findsNothing);
    expect(find.text('Draft'), findsNothing);
    expect(await t.runAsync(() => FeatureRepo(h.db).watchForVersion(ids.v1).first), isEmpty);
    await h.dispose(t);
  });

  testWidgets('checking moves card into Done group and count updates', (t) async {
    late Ids ids;
    late String a;
    final h = await Harness.pump(
      t,
      seed: (db) async {
        ids = await seedBasic(db);
        a = await FeatureRepo(db).create(ids.v1, 'Alpha');
        await FeatureRepo(db).create(ids.v1, 'Beta');
      },
    );
    expect(find.text('Done · 1'), findsNothing);
    await t.tap(find.byKey(Key('check-$a')));
    await Harness.settle(t);
    expect(find.text('Done · 1'), findsOneWidget);
    final alphaY = t.getTopLeft(find.text('Alpha')).dy;
    final betaY = t.getTopLeft(find.text('Beta')).dy;
    expect(alphaY, greaterThan(betaY));
    await h.dispose(t);
  });

  testWidgets('delete shows toast and Undo restores card', (t) async {
    late Ids ids;
    late String a;
    final h = await Harness.pump(
      t,
      seed: (db) async {
        ids = await seedBasic(db);
        a = await FeatureRepo(db).create(ids.v1, 'Alpha');
      },
    );
    await t.tap(find.byKey(Key('card-$a')), buttons: kSecondaryButton);
    await Harness.settle(t);
    await t.tap(find.text('Delete'));
    await Harness.settle(t);
    expect(find.text('Alpha'), findsNothing);
    expect(find.text('Feature deleted'), findsOneWidget);
    await t.tap(find.text('Undo'));
    await Harness.settle(t);
    expect(find.text('Alpha'), findsOneWidget);
    await h.dispose(t);
  });

  testWidgets('2000-char unbroken title renders without overflow', (t) async {
    final h = await Harness.pump(
      t,
      size: const Size(1280, 800),
      seed: (db) async {
        final ids = await seedBasic(db);
        await FeatureRepo(db).create(ids.v1, 'W' * 2000);
        await FeatureRepo(db).create(ids.v1, List.filled(60, 'line').join('\n'));
      },
    );
    expect(t.takeException(), isNull);
    await h.dispose(t);
  });

  testWidgets('column header shows progress 1/3', (t) async {
    final h = await Harness.pump(
      t,
      seed: (db) async {
        final ids = await seedBasic(db);
        final a = await FeatureRepo(db).create(ids.v1, 'A');
        await FeatureRepo(db).create(ids.v1, 'B');
        await FeatureRepo(db).create(ids.v1, 'C');
        await FeatureRepo(db).setDone(a, true);
      },
    );
    expect(find.text('1/3'), findsOneWidget);
    await h.dispose(t);
  });

  testWidgets('concept column renders first with idea count', (t) async {
    final h = await Harness.pump(
      t,
      seed: (db) async {
        final ids = await seedBasic(db);
        await FeatureRepo(db).create(ids.concept, 'Widgets on lock screen');
        await FeatureRepo(db).create(ids.concept, 'Wear OS app');
      },
    );
    expect(find.text('2 ideas'), findsOneWidget);
    final conceptX = t.getTopLeft(find.text('Concept')).dx;
    final v1X = t.getTopLeft(find.text('v1.0')).dx;
    expect(conceptX, lessThan(v1X));
    await h.dispose(t);
  });

  testWidgets('delayed chip shows from-version name', (t) async {
    final h = await Harness.pump(
      t,
      seed: (db) async {
        final ids = await seedBasic(db);
        final a = await FeatureRepo(db).create(ids.v1, 'Late feature');
        await FeatureRepo(db).delay(a);
      },
    );
    expect(find.text('Delayed from v1.0'), findsOneWidget);
    expect(find.text('1 delayed in'), findsOneWidget);
    await h.dispose(t);
  });

  testWidgets('copy button puts the version checklist on the clipboard', (t) async {
    String? copied;
    t.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
      return null;
    });
    addTearDown(() => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    late Ids ids;
    final h = await Harness.pump(
      t,
      seed: (db) async {
        ids = await seedBasic(db);
        await FeatureRepo(db).create(ids.v1, 'Alpha');
        await FeatureRepo(db).create(ids.v1, 'Beta');
      },
    );
    await t.tap(find.byKey(Key('copy-version-${ids.v1}')));
    await Harness.settle(t);
    expect(copied, 'v1.0 — 0/2 done\n- [ ] Alpha\n- [ ] Beta\n');
    expect(find.text('Copied 2 features from v1.0'), findsOneWidget);
    await h.dispose(t);
  });

  testWidgets('a project with few columns starts at the left edge, not centred', (t) async {
    final h = await Harness.pump(t, seed: (db) => ProjectRepo(db).create('Solo', const VColor.slot(0)));
    final left = t.getTopLeft(find.text('Concept')).dx;
    expect(left, lessThan(10 + 236 + 10 + 60));
    await h.dispose(t);
  });
}
