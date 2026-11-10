import 'dart:io';
import 'dart:ui';

import 'package:flutter/scheduler.dart';

/// Dev-only (VERSO_PERF=1): records frame timings for [seconds] and writes
/// p50/p90/max build and raster times to `<dir>\perf.txt`.
void startPerfProbe(Directory dir, {int seconds = 14}) {
  final frames = <FrameTiming>[];
  SchedulerBinding.instance.addTimingsCallback(frames.addAll);
  Future.delayed(Duration(seconds: seconds), () {
    int pct(List<int> xs, double p) => xs.isEmpty ? 0 : xs[((xs.length - 1) * p).round()];
    final raster = frames.map((f) => f.rasterDuration.inMicroseconds).toList()..sort();
    final build = frames.map((f) => f.buildDuration.inMicroseconds).toList()..sort();
    final over = raster.where((r) => r > 8333).length;
    File('${dir.path}${Platform.pathSeparator}perf.txt').writeAsStringSync(
      'frames=${frames.length}\n'
      'raster_us p50=${pct(raster, .5)} p90=${pct(raster, .9)} p99=${pct(raster, .99)} max=${raster.isEmpty ? 0 : raster.last}\n'
      'build_us p50=${pct(build, .5)} p90=${pct(build, .9)} p99=${pct(build, .99)} max=${build.isEmpty ? 0 : build.last}\n'
      'raster_over_8.3ms=$over\n',
    );
  });
}

/// True when the app was started with VERSO_PERF=1 (views then drive
/// their own scrolling / zooming so frame timings can be measured
/// without sending OS input).
bool get perfMode => Platform.environment['VERSO_PERF'] == '1';
