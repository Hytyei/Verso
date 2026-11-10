import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/models.dart';
import 'package:verso/data/repos/project_repo.dart';
import 'package:verso/state/providers.dart';

import 'harness.dart';

void main() {
  testWidgets('sidebar lists projects and selecting one updates selectedProjectIdProvider', (t) async {
    late String kobel;
    final h = await Harness.pump(
      t,
      seed: (db) async {
        await ProjectRepo(db).create('Tandem', const VColor.slot(0));
        kobel = await ProjectRepo(db).create('Kobel', const VColor.slot(1));
      },
    );
    expect(find.text('Tandem'), findsWidgets);
    expect(find.text('Kobel'), findsOneWidget);
    await t.tap(find.text('Kobel'));
    await Harness.settle(t);
    expect(h.container.read(selectedProjectIdProvider), kobel);
    await h.dispose(t);
  });

  testWidgets('segmented switches viewModeProvider', (t) async {
    final h = await Harness.pump(t, seed: (db) => ProjectRepo(db).create('Tandem', const VColor.slot(0)));
    expect(h.container.read(viewModeProvider), ViewMode.board);
    await t.tap(find.text('Timeline'));
    await Harness.settle(t);
    expect(h.container.read(viewModeProvider), ViewMode.timeline);
    await h.dispose(t);
  });

  testWidgets('new project button creates project and selects it', (t) async {
    final h = await Harness.pump(t);
    expect(h.container.read(selectedProjectIdProvider), isNull);
    await t.tap(find.byKey(const Key('new-project')));
    await Harness.settle(t);
    final id = h.container.read(selectedProjectIdProvider);
    expect(id, isNotNull);
    expect(find.text('New project'), findsWidgets);
    await h.dispose(t);
  });
}
