import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/repos/feature_repo.dart';
import 'package:verso/data/repos/version_repo.dart';
import 'package:verso/ui/board/attachment_strip.dart';

import 'board_test.dart' show Ids, seedBasic;
import 'harness.dart';

void main() {
  Future<void> mouseDrag(WidgetTester t, Offset from, Offset to) async {
    final g = await t.startGesture(from, kind: PointerDeviceKind.mouse);
    await t.pump();
    for (var i = 1; i <= 8; i++) {
      await g.moveTo(Offset.lerp(from, to, i / 8)!);
      await t.pump(const Duration(milliseconds: 16));
    }
    await g.up();
    await Harness.settle(t);
  }

  testWidgets('drag card to second column moves it there at drop index', (t) async {
    late Ids ids;
    late String a;
    final h = await Harness.pump(
      t,
      seed: (db) async {
        ids = await seedBasic(db);
        a = await FeatureRepo(db).create(ids.v1, 'Alpha');
        await FeatureRepo(db).create(ids.v2, 'One');
        await FeatureRepo(db).create(ids.v2, 'Two');
      },
    );
    final one = t.getRect(find.text('One'));
    final two = t.getRect(find.text('Two'));
    // Drop between One and Two.
    await mouseDrag(t, t.getCenter(find.text('Alpha')), Offset(one.center.dx, (one.bottom + two.top) / 2 + 4));
    final list = await t.runAsync(() => FeatureRepo(h.db).watchForVersion(ids.v2).first);
    expect(list!.map((f) => f.title), ['One', 'Alpha', 'Two']);
    expect(list[1].id, a);
    await h.dispose(t);
  });

  testWidgets('drag to empty column works', (t) async {
    late Ids ids;
    final h = await Harness.pump(
      t,
      seed: (db) async {
        ids = await seedBasic(db);
        await FeatureRepo(db).create(ids.v1, 'Alpha');
      },
    );
    final target = t.getCenter(find.byKey(Key('add-feature-${ids.v2}')));
    await mouseDrag(t, t.getCenter(find.text('Alpha')), target);
    final list = await t.runAsync(() => FeatureRepo(h.db).watchForVersion(ids.v2).first);
    expect(list!.single.title, 'Alpha');
    await h.dispose(t);
  });

  testWidgets('expanded card adds subitem and counter shows 0/1', (t) async {
    late Ids ids;
    late String a;
    final h = await Harness.pump(
      t,
      seed: (db) async {
        ids = await seedBasic(db);
        a = await FeatureRepo(db).create(ids.v1, 'Alpha');
      },
    );
    await t.tap(find.text('Alpha'));
    await Harness.settle(t);
    await t.tap(find.byKey(Key('add-step-$a')));
    await Harness.settle(t);
    await t.enterText(find.byKey(Key('step-field-$a')), 'Design screen');
    await t.testTextInput.receiveAction(TextInputAction.done);
    await Harness.settle(t);
    expect(find.text('Design screen'), findsOneWidget);
    expect(find.descendant(of: find.byKey(Key('card-$a')), matching: find.text('0/1')), findsOneWidget);
    await h.dispose(t);
  });

  testWidgets('color picker custom color updates feature accent bar', (t) async {
    late String a;
    final h = await Harness.pump(
      t,
      seed: (db) async {
        final ids = await seedBasic(db);
        a = await FeatureRepo(db).create(ids.v1, 'Alpha');
      },
    );
    await t.tap(find.byKey(Key('card-$a')), buttons: kSecondaryButton);
    await Harness.settle(t);
    await t.tap(find.text('Color…'));
    await Harness.settle(t);
    await t.tap(find.text('Custom'));
    await Harness.settle(t);
    await t.enterText(find.byKey(const Key('hex-field')), '12AB34');
    await t.testTextInput.receiveAction(TextInputAction.done);
    await Harness.settle(t);
    final bar = t.widget<AnimatedContainer>(find.byKey(Key('accent-$a')));
    expect((bar.decoration as BoxDecoration?)?.color, const Color(0xFF12AB34));
    await h.dispose(t);
  });

  testWidgets('version editor sets dates and status pill updates', (t) async {
    late Ids ids;
    final h = await Harness.pump(t, seed: (db) async => ids = await seedBasic(db));
    await t.tap(find.byKey(Key('version-menu-${ids.v1}')));
    await Harness.settle(t);
    await t.tap(find.text('Released').last);
    await Harness.settle(t);
    await t.tap(find.byKey(const Key('start-date')));
    await Harness.settle(t);
    await t.tap(find.text('OK'));
    await Harness.settle(t);
    final v = await t.runAsync(() => VersionRepo(h.db).get(ids.v1));
    expect(v!.status, 'released');
    expect(v.startDate, isNotNull);
    await t.tapAt(const Offset(5, 400));
    await Harness.settle(t);
    expect(find.textContaining('From '), findsWidgets);
    expect(find.text('Released'), findsOneWidget);
    await h.dispose(t);
  });

  testWidgets('dropping .txt shows rejection toast', (t) async {
    late String a;
    final h = await Harness.pump(
      t,
      seed: (db) async {
        final ids = await seedBasic(db);
        a = await FeatureRepo(db).create(ids.v1, 'Alpha');
      },
    );
    final ctx = t.element(find.text('Alpha'));
    await t.runAsync(() => handleDroppedFiles(ctx, h.container.read, a, ['C:/nowhere/notes.txt']));
    await Harness.settle(t);
    expect(find.text('Not an image file'), findsOneWidget);
    await h.dispose(t);
  });

  testWidgets('delay via menu moves card to next column with chip', (t) async {
    late Ids ids;
    late String a;
    final h = await Harness.pump(
      t,
      seed: (db) async {
        ids = await seedBasic(db);
        a = await FeatureRepo(db).create(ids.v1, 'Late one');
      },
    );
    final before = t.getTopLeft(find.text('Late one')).dx;
    await t.tap(find.byKey(Key('card-$a')), buttons: kSecondaryButton);
    await Harness.settle(t);
    await t.tap(find.text('Delay to'));
    await Harness.settle(t);
    await t.tap(find.text('Next: v1.1'));
    await Harness.settle(t);
    expect(find.text('Delayed from v1.0'), findsOneWidget);
    expect(t.getTopLeft(find.text('Late one')).dx, greaterThan(before));
    expect((await t.runAsync(() => FeatureRepo(h.db).get(a)))!.versionId, ids.v2);
    await h.dispose(t);
  });

  testWidgets('drag version header before another reorders columns', (t) async {
    late Ids ids;
    final h = await Harness.pump(t, seed: (db) async => ids = await seedBasic(db));
    final v1Left = t.getRect(find.byKey(ValueKey('col-${ids.v1}'))).left;
    await mouseDrag(t, t.getCenter(find.text('v1.1')), Offset(v1Left + 20, t.getCenter(find.text('v1.0')).dy + 40));
    final names = (await t.runAsync(() => VersionRepo(h.db).listForProject(ids.project)))!.map((v) => v.name);
    expect(names, ['Concept', 'v1.1', 'v1.0']);
    await h.dispose(t);
  });

  testWidgets('a sub-step can be added under a step, indented', (t) async {
    late String a, stepA;
    final h = await Harness.pump(
      t,
      seed: (db) async {
        final ids = await seedBasic(db);
        a = await FeatureRepo(db).create(ids.v1, 'Alpha');
        stepA = await FeatureRepo(db).addSubitem(a, 'Design');
      },
    );
    await t.tap(find.text('Alpha'));
    await Harness.settle(t);
    await t.tap(find.byKey(Key('add-substep-$stepA')));
    await Harness.settle(t);
    await t.enterText(find.byKey(Key('step-field-$stepA')), 'Wireframe');
    await t.testTextInput.receiveAction(TextInputAction.done);
    await Harness.settle(t);
    expect(find.text('Wireframe'), findsOneWidget);
    expect(t.getTopLeft(find.text('Wireframe')).dx, greaterThan(t.getTopLeft(find.text('Design')).dx + 10));
    final rows = await t.runAsync(() => FeatureRepo(h.db).watchSubitems(a).first);
    expect(rows!.firstWhere((x) => x.title == 'Wireframe').parentId, stepA);
    await h.dispose(t);
  });

  testWidgets('steps reorder by dragging their handle', (t) async {
    late String a, s2;
    final h = await Harness.pump(
      t,
      seed: (db) async {
        final ids = await seedBasic(db);
        a = await FeatureRepo(db).create(ids.v1, 'Alpha');
        await FeatureRepo(db).addSubitem(a, 'First');
        s2 = await FeatureRepo(db).addSubitem(a, 'Second');
      },
    );
    await t.tap(find.text('Alpha'));
    await Harness.settle(t);
    final handle = find.byKey(Key('step-handle-$s2'));
    final g = await t.startGesture(t.getCenter(handle));
    await t.pump(const Duration(milliseconds: 100));
    for (var i = 0; i < 6; i++) {
      await g.moveBy(const Offset(0, -8));
      await t.pump(const Duration(milliseconds: 16));
    }
    await g.up();
    await Harness.settle(t);
    final rows = (await t.runAsync(() => FeatureRepo(h.db).watchSubitems(a).first))!
      ..sort((x, y) => x.sortKey.compareTo(y.sortKey));
    expect(rows.map((x) => x.title), ['Second', 'First']);
    await h.dispose(t);
  });
}
