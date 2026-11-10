import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/db/database.dart';
import 'package:verso/data/models.dart';
import 'package:verso/data/repos/feature_repo.dart';
import 'package:verso/state/providers.dart';
import 'package:verso/ui/shell/filter.dart';
import 'package:verso/ui/shell/sidebar.dart';
import 'package:verso/ui/theme/palette.dart';

import 'board_test.dart' show Ids, seedBasic;
import 'harness.dart';

Feature _f(String title, {String? notes, bool done = false, int priority = 0}) => Feature(
  id: title,
  createdAt: 0,
  updatedAt: 0,
  deleted: false,
  versionId: 'v',
  title: title,
  done: done,
  priority: priority,
  colorCustom: false,
  notes: notes,
  sortKey: 'a0',
  delayCount: 0,
);

Tag _tag(String id) => Tag(
  id: id,
  createdAt: 0,
  updatedAt: 0,
  deleted: false,
  projectId: 'p',
  name: id,
  color: 0,
  colorCustom: false,
  sortKey: 'a0',
);

void main() {
  group('matches', () {
    test('matches finds text in notes', () {
      final v = FeatureView(_f('Login', notes: 'Use Google One Tap'), const [], 0, 0, 0);
      expect(featureMatches(v, 'one tap', const FeatureFilter()), isTrue);
      expect(featureMatches(v, 'apple', const FeatureFilter()), isFalse);
    });

    test('matches finds text in sub-items', () {
      final v = FeatureView(_f('Login'), const [], 0, 1, 0, subTitles: const ['Design error state']);
      expect(featureMatches(v, 'ERROR', const FeatureFilter()), isTrue);
    });

    test('tag filter excludes untagged', () {
      final tagged = FeatureView(_f('A'), [_tag('ui')], 0, 0, 0);
      final plain = FeatureView(_f('B'), const [], 0, 0, 0);
      const f = FeatureFilter(tagIds: {'ui'});
      expect(featureMatches(tagged, '', f), isTrue);
      expect(featureMatches(plain, '', f), isFalse);
    });

    test('priority and done filters', () {
      final hi = FeatureView(_f('A', priority: 3), const [], 0, 0, 0);
      final lo = FeatureView(_f('B', priority: 1, done: true), const [], 0, 0, 0);
      expect(featureMatches(hi, '', const FeatureFilter(minPriority: 2)), isTrue);
      expect(featureMatches(lo, '', const FeatureFilter(minPriority: 2)), isFalse);
      expect(featureMatches(lo, '', const FeatureFilter(done: DoneFilter.open)), isFalse);
      expect(featureMatches(lo, '', const FeatureFilter(done: DoneFilter.done)), isTrue);
    });
  });

  testWidgets('search hides non-matching cards', (t) async {
    final h = await Harness.pump(
      t,
      seed: (db) async {
        final ids = await seedBasic(db);
        await FeatureRepo(db).create(ids.v1, 'Sign in');
        await FeatureRepo(db).create(ids.v1, 'Dark mode');
      },
    );
    await t.enterText(find.byKey(const Key('search-field')), 'dark');
    await Harness.settle(t);
    expect(find.text('Sign in'), findsNothing);
    expect(find.text('Dark mode'), findsOneWidget);
    await h.dispose(t);
  });

  testWidgets('Ctrl+2 switches to timeline', (t) async {
    final h = await Harness.pump(t, seed: (db) => seedBasic(db));
    await t.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await t.sendKeyEvent(LogicalKeyboardKey.digit2);
    await t.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await Harness.settle(t);
    expect(h.container.read(viewModeProvider), ViewMode.timeline);
    await h.dispose(t);
  });

  testWidgets('Ctrl+Z after delete restores', (t) async {
    late String a;
    final h = await Harness.pump(
      t,
      seed: (db) async {
        final ids = await seedBasic(db);
        a = await FeatureRepo(db).create(ids.v1, 'Alpha');
      },
    );
    await t.tap(find.text('Alpha'));
    await Harness.settle(t);
    await t.sendKeyEvent(LogicalKeyboardKey.delete);
    await Harness.settle(t);
    expect(find.text('Alpha'), findsNothing);
    await t.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await t.sendKeyEvent(LogicalKeyboardKey.keyZ);
    await t.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await Harness.settle(t);
    expect(find.text('Alpha'), findsOneWidget);
    expect(a, isNotEmpty);
    await h.dispose(t);
  });

  testWidgets('Space toggles focused feature', (t) async {
    late String a;
    final h = await Harness.pump(
      t,
      seed: (db) async {
        final ids = await seedBasic(db);
        a = await FeatureRepo(db).create(ids.v1, 'Alpha');
      },
    );
    await t.tap(find.text('Alpha'));
    await Harness.settle(t);
    await t.sendKeyEvent(LogicalKeyboardKey.space);
    await Harness.settle(t);
    expect((await t.runAsync(() => FeatureRepo(h.db).get(a)))!.done, isTrue);
    await h.dispose(t);
  });

  testWidgets('Ctrl+D delays focused feature', (t) async {
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
    await t.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await t.sendKeyEvent(LogicalKeyboardKey.keyD);
    await t.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await Harness.settle(t);
    expect((await t.runAsync(() => FeatureRepo(h.db).get(a)))!.versionId, ids.v2);
    await h.dispose(t);
  });

  testWidgets('typing space in the add field does not toggle anything', (t) async {
    late Ids ids;
    final h = await Harness.pump(t, seed: (db) async => ids = await seedBasic(db));
    await t.tap(find.byKey(Key('add-feature-${ids.v1}')));
    await Harness.settle(t);
    await t.enterText(find.byKey(Key('add-field-${ids.v1}')), 'a b');
    await t.sendKeyEvent(LogicalKeyboardKey.space);
    await Harness.settle(t);
    expect(find.byKey(Key('add-field-${ids.v1}')), findsOneWidget);
    await h.dispose(t);
  });

  testWidgets('theme setting Dark applies black background', (t) async {
    final h = await Harness.pump(t, seed: (db) => seedBasic(db));
    await t.tap(find.byKey(const Key('open-settings')));
    await Harness.settle(t);
    await t.tap(find.text('Dark'));
    await Harness.settle(t);
    final p = VersoPalette.of(t.element(find.byType(Sidebar)));
    expect(p.isDark, isTrue);
    expect(p.bgTop, const Color(0xFF000000));
    await h.dispose(t);
  });
}
