import '../ui/common/format.dart';
import 'db/database.dart';
import 'repos/feature_repo.dart';
import 'repos/version_repo.dart';

/// A version's features as a Markdown checklist (open first, then done),
/// with steps indented under their feature. Multi-line titles keep their
/// lines, indented to stay inside the list item.
Future<String> versionAsText(VersoDb db, String versionId, {DateTime? now}) async {
  final v = await VersionRepo(db).get(versionId);
  final repo = FeatureRepo(db);
  final features = await repo.watchForVersion(versionId).first;
  final done = features.where((f) => f.done).length;
  final dates = dateRange(v.startDate, v.targetDate, now: now);
  final b = StringBuffer('${v.name}${dates.isEmpty ? '' : ' ($dates)'} — $done/${features.length} done\n');
  for (final f in features) {
    final lines = f.title.trim().split('\n');
    b.writeln('- [${f.done ? 'x' : ' '}] ${lines.first}');
    for (final l in lines.skip(1)) {
      b.writeln('  $l');
    }
    for (final s in await repo.watchSubitems(f.id).first) {
      b.writeln('  - [${s.done ? 'x' : ' '}] ${s.title}');
    }
  }
  return b.toString();
}
