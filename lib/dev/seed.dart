import 'dart:math' as math;

import 'package:drift/drift.dart' show Value;

import '../data/db/database.dart';
import '../data/models.dart';
import '../data/repos/environment_repo.dart';
import '../data/repos/feature_repo.dart';
import '../data/repos/milestone_repo.dart';
import '../data/repos/project_repo.dart';
import '../data/repos/tag_repo.dart';
import '../data/repos/version_repo.dart';

/// Dev-only: fills an empty database with three sample projects
/// (~300 features). Runs only when VERSO_SEED=1 and the DB has no projects.
Future<void> seedSampleData(VersoDb db) async {
  if ((await ProjectRepo(db).watchAll().first).isNotEmpty) return;
  final rnd = math.Random(7);
  final projects = ProjectRepo(db), versions = VersionRepo(db), features = FeatureRepo(db);
  final milestones = MilestoneRepo(db), tags = TagRepo(db);

  const ideas = [
    'Widgets on the lock screen',
    'Wear OS companion',
    'Shared calendar view',
    'Voice notes in chat',
    'Offline mode for long flights',
    'Home-screen quick actions',
    'Streak recovery with a grace day',
  ];
  const work = [
    'Sign in with Google',
    'Onboarding carousel with three steps',
    'Push notification permissions flow',
    'Dark theme polish across all screens',
    'Crash on resume when the token expired',
    'Settings: export my data as JSON',
    'Fix: keyboard covers the reply field on small phones',
    'Animated progress ring on the home card',
    'Backend: rate-limit the /sync endpoint',
    'Pagination for the history list',
    'Empty states with friendly copy',
    'In-app updater checks GitHub releases',
    'Accessibility: TalkBack labels on icon buttons',
    'Haptics on check and delete',
    'Search with fuzzy matching',
    'Cache images on disk with an LRU limit',
    'Localise dates for Persian calendar users',
    'Reduce cold start below 600 ms',
    'Tablet two-pane layout',
    'Analytics opt-in screen',
  ];
  const steps = ['Design screen', 'Write the API call', 'Handle errors', 'Test on a small phone', 'Ship behind a flag'];

  final envRepo = EnvironmentRepo(db);
  final chatgpt = await envRepo.defaultId();
  await envRepo.update(chatgpt, name: 'ChatGPT', icon: 'chat', color: const VColor.slot(3));
  final claude = await envRepo.create('Claude Code', 'terminal', const VColor.slot(1));
  final envFor = [chatgpt, claude, claude];
  final start = DateTime.utc(2026, 9, 1);
  for (final (pi, name) in ['Tandem', 'Kobel', 'Leestn'].indexed) {
    final p = await projects.create(name, VColor.slot(pi), environmentId: envFor[pi]);
    final tagRows = await tags.watchForProject(p).first;
    final concept = (await versions.listForProject(p)).first;
    await versions.update(concept.id, startDate: Value(start), targetDate: Value(start.add(const Duration(days: 20))));
    for (final idea in ideas.take(4 + pi)) {
      await features.create(concept.id, idea);
    }
    final names = ['v1.0', 'v1.1', 'v1.2', 'v1.3', 'v2.0'];
    var cursor = start.add(Duration(days: 14 + pi * 6));
    final vIds = <String>[];
    for (final (vi, vn) in names.indexed) {
      final id = await versions.create(p, vn);
      vIds.add(id);
      final len = 18 + rnd.nextInt(20);
      final status = vi < 2 ? VersionStatus.released : (vi == 2 ? VersionStatus.active : VersionStatus.planned);
      await versions.update(
        id,
        status: status,
        startDate: Value(cursor),
        targetDate: Value(cursor.add(Duration(days: len))),
        releasedDate: Value(status == VersionStatus.released ? cursor.add(Duration(days: len)) : null),
      );
      final count = 16 + rnd.nextInt(10);
      for (var i = 0; i < count; i++) {
        final title = work[(i + vi * 3 + pi) % work.length];
        final dated = i % 4 == 0;
        final fs = cursor.add(Duration(days: rnd.nextInt(len)));
        final f = await features.create(
          id,
          title,
          startDate: dated ? fs : null,
          endDate: dated ? fs.add(Duration(days: 2 + rnd.nextInt(8))) : null,
        );
        await features.update(
          f,
          priority: rnd.nextInt(4),
          notes: Value(i % 5 == 0 ? 'Notes for "$title" — keep it simple.' : null),
        );
        await features.setTags(f, [tagRows[rnd.nextInt(tagRows.length)].id]);
        if (i % 3 == 0) {
          for (final s in steps.take(2 + rnd.nextInt(3))) {
            final sid = await features.addSubitem(f, s);
            if (rnd.nextBool()) await features.updateSubitem(sid, done: true);
          }
        }
        if (status == VersionStatus.released || (status == VersionStatus.active && rnd.nextDouble() < .45)) {
          await features.setDone(f, true);
        }
      }
      cursor = cursor.add(Duration(days: len + 4));
    }
    // A few delayed features in the active and planned versions.
    for (final f in (await features.watchForVersion(vIds[2]).first).where((x) => !x.done).take(3)) {
      await features.delay(f.id);
    }
    // Tandem moved from ChatGPT to Claude Code at v1.2.
    if (pi == 0) await versions.setEnvironmentFrom(vIds[2], claude);
    await milestones.create(p, 'Beta on Play', start.add(Duration(days: 40 + pi * 5)), kind: MilestoneKind.launch);
    await milestones.create(p, 'Store launch', start.add(Duration(days: 120 + pi * 9)), kind: MilestoneKind.release);
    await milestones.create(
      p,
      'Budget review',
      start.add(Duration(days: 75)),
      kind: MilestoneKind.deadline,
      color: const VColor.slot(2),
    );
  }
}
