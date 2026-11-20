import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/models.dart';
import 'package:verso/data/repos/feature_repo.dart';
import 'package:verso/data/repos/project_repo.dart';
import 'package:verso/data/repos/version_repo.dart';
import 'package:verso/state/providers.dart';

import 'harness.dart';

void main() {
  testWidgets('collapsed cards list their steps, nested, and tick them in place', (t) async {
    late String feature, step, child;
    final h = await Harness.pump(
      t,
      seed: (db) async {
        final p = await ProjectRepo(db).create('App', const VColor.slot(0));
        final v = await VersionRepo(db).create(p, 'v1.0');
        final f = FeatureRepo(db);
        feature = await f.create(v, 'Audio drills');
        step = await f.addSubitem(feature, 'Record words');
        child = await f.addSubitem(feature, 'Persian voice', parentId: step);
      },
    );
    expect(find.byKey(Key('card-steps-$feature')), findsOneWidget);
    expect(find.text('Record words'), findsOneWidget);
    expect(find.text('Persian voice'), findsOneWidget);
    // The child is indented under its parent.
    expect(t.getTopLeft(find.text('Persian voice')).dx, greaterThan(t.getTopLeft(find.text('Record words')).dx));

    await t.tap(find.byKey(Key('card-step-$child')));
    await Harness.settle(t);
    final steps = await t.runAsync(() => FeatureRepo(h.db).watchSubitems(feature).first);
    expect(steps!.firstWhere((s) => s.id == child).done, isTrue);

    // Settings can turn the list off.
    h.container.read(settingsProvider.notifier).update((s) => s.copyWith(stepsOnCards: false));
    await Harness.settle(t);
    expect(find.byKey(Key('card-steps-$feature')), findsNothing);
    await h.dispose(t);
  });

  testWidgets('the timeline switches to all projects and filters them', (t) async {
    late String kobel;
    final h = await Harness.pump(
      t,
      seed: (db) async {
        final projects = ProjectRepo(db), versions = VersionRepo(db);
        final tandem = await projects.create('Tandem', const VColor.slot(0));
        kobel = await projects.create('Kobel', const VColor.slot(1));
        for (final (p, name) in [(tandem, 'v1.2'), (kobel, 'v4.0')]) {
          final v = await versions.create(p, name);
          await versions.update(v, startDate: Value(DateTime.utc(2026, 11, 1)), targetDate: Value(DateTime.utc(2026, 12, 1)));
        }
      },
    );
    h.container.read(viewModeProvider.notifier).set(ViewMode.timeline);
    await Harness.settle(t);
    await t.tap(find.text('All projects'));
    await Harness.settle(t);
    expect(h.container.read(settingsProvider).timelineAll, isTrue);

    await t.tap(find.byKey(const Key('timeline-filter')));
    await Harness.settle(t);
    expect(find.byKey(const Key('overview-filter')), findsOneWidget);
    await t.tap(find.byKey(Key('overview-project-$kobel')));
    await Harness.settle(t);
    expect(h.container.read(settingsProvider).overview.hiddenProjects, {kobel});
    await h.dispose(t);
  });
}
