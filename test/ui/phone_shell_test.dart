import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/models.dart';
import 'package:verso/data/repos/feature_repo.dart';
import 'package:verso/data/repos/project_repo.dart';
import 'package:verso/data/repos/version_repo.dart';
import 'package:verso/state/providers.dart';

import 'harness.dart';

const phone = Size(412, 900);

void main() {
  late String baladsho, kobel, v1, v2;

  Future<void> seed(db) async {
    baladsho = await ProjectRepo(db).create('Baladsho', const VColor.slot(0));
    kobel = await ProjectRepo(db).create('Kobel', const VColor.slot(1));
    final vs = VersionRepo(db);
    v1 = await vs.create(baladsho, 'v1.0.0');
    v2 = await vs.create(baladsho, 'v1.1.0');
    await vs.update(v2, status: VersionStatus.active);
    await FeatureRepo(db).create(v1, 'Keyboard');
    await FeatureRepo(db).create(v2, 'Audio drills');
  }

  Future<Harness> open(WidgetTester t) => Harness.pump(
    t,
    size: phone,
    seed: seed,
    overrides: [touchModeProvider.overrideWithValue(true)],
  );

  testWidgets('opens on the active version; pills and swipes move between versions', (t) async {
    final h = await open(t);
    h.container.read(selectedProjectIdProvider.notifier).select(baladsho);
    await Harness.settle(t);
    expect(find.byKey(const Key('phone-header')), findsOneWidget);
    // The active version (v1.1.0) is the page on screen.
    expect(find.text('Audio drills'), findsOneWidget);
    expect(find.text('Keyboard'), findsNothing);

    await t.tap(find.byKey(const Key('pill-v1.0.0')));
    await Harness.settle(t);
    expect(find.text('Keyboard'), findsOneWidget);

    await t.fling(find.byKey(const Key('version-pager')), const Offset(-300, 0), 1500);
    await Harness.settle(t);
    expect(find.text('Audio drills'), findsOneWidget);
    await h.dispose(t);
  });

  testWidgets('the add bar adds to the version on screen', (t) async {
    final h = await open(t);
    h.container.read(selectedProjectIdProvider.notifier).select(baladsho);
    await Harness.settle(t);
    await t.tap(find.byKey(const Key('phone-add')));
    await Harness.settle(t);
    await t.enterText(find.byKey(Key('add-field-$v2')), 'Offline packs');
    await t.testTextInput.receiveAction(TextInputAction.done);
    await Harness.settle(t);
    final titles = (await t.runAsync(() => FeatureRepo(h.db).watchForVersion(v2).first))!.map((f) => f.title);
    expect(titles, contains('Offline packs'));
    await h.dispose(t);
  });

  testWidgets('the folders sheet opens another project and closes', (t) async {
    final h = await open(t);
    h.container.read(selectedProjectIdProvider.notifier).select(baladsho);
    await Harness.settle(t);
    await t.tap(find.byKey(const Key('phone-folders')));
    await Harness.settle(t);
    expect(find.byKey(const Key('folders-sheet')), findsOneWidget);
    await t.tap(find.descendant(of: find.byKey(const Key('folders-sheet')), matching: find.text('Kobel')));
    await Harness.settle(t);
    expect(h.container.read(selectedProjectIdProvider), kobel);
    expect(find.byKey(const Key('folders-sheet')), findsNothing);
    await h.dispose(t);
  });

  testWidgets('long-press on a task opens its menu (no drag when held still)', (t) async {
    final h = await open(t);
    h.container.read(selectedProjectIdProvider.notifier).select(baladsho);
    await Harness.settle(t);
    await t.longPress(find.text('Audio drills'));
    await Harness.settle(t);
    expect(find.text('Delay to'), findsOneWidget);
    await h.dispose(t);
  });

  testWidgets('a new version from the + pill becomes the page on screen', (t) async {
    final h = await open(t);
    h.container.read(selectedProjectIdProvider.notifier).select(baladsho);
    await Harness.settle(t);
    await t.tap(find.byKey(const Key('pill-add')));
    await Harness.settle(t);
    await Harness.settle(t);
    expect(find.byKey(const Key('pill-v1.2.0')), findsOneWidget);
    expect(find.text('Audio drills'), findsNothing);
    await h.dispose(t);
  });
}
