import 'package:flutter/material.dart';

import '../theme/motion.dart';
import 'flip.dart';

/// A column of keyed rows that animates inserts (grow + fade + 0.96→1),
/// removals (collapse + fade + slide) and moves (FLIP). Rows present on the
/// first build appear without animation.
class AnimatedEntryList<T> extends StatefulWidget {
  const AnimatedEntryList({
    super.key,
    required this.items,
    required this.idOf,
    required this.itemBuilder,
    this.spacing = 8,
  });
  final List<T> items;
  final String Function(T item) idOf;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final double spacing;

  @override
  State<AnimatedEntryList<T>> createState() => _AnimatedEntryListState<T>();
}

class _Entry<T> {
  _Entry(this.id, this.item, this.controller);
  final String id;
  T item;
  final AnimationController controller;
  bool leaving = false;
}

class _AnimatedEntryListState<T> extends State<AnimatedEntryList<T>> with TickerProviderStateMixin {
  List<_Entry<T>> _entries = [];

  @override
  void initState() {
    super.initState();
    _entries = [for (final it in widget.items) _make(it, appear: false)];
  }

  _Entry<T> _make(T item, {required bool appear}) {
    final c = AnimationController(vsync: this, duration: Motion.springDuration, value: appear ? 0 : 1);
    final e = _Entry<T>(widget.idOf(item), item, c);
    if (appear) c.forward();
    return e;
  }

  @override
  void didUpdateWidget(AnimatedEntryList<T> old) {
    super.didUpdateWidget(old);
    final byId = {for (final e in _entries) e.id: e};
    final newIds = {for (final it in widget.items) widget.idOf(it)};
    final leavingAfter = <String?, List<_Entry<T>>>{};
    String? prevKept;
    for (final e in _entries) {
      if (!newIds.contains(e.id)) {
        if (!e.leaving) {
          e.leaving = true;
          e.controller.duration = Motion.reduced(context) ? Motion.fade : const Duration(milliseconds: 260);
          e.controller.reverse().whenComplete(() {
            if (!mounted || !e.leaving) return;
            setState(() => _entries.remove(e));
            e.controller.dispose();
          });
        }
        (leavingAfter[prevKept] ??= []).add(e);
      } else {
        prevKept = e.id;
      }
    }
    final next = <_Entry<T>>[...?leavingAfter[null]];
    for (final it in widget.items) {
      final id = widget.idOf(it);
      var e = byId[id];
      if (e == null) {
        e = _make(it, appear: true);
      } else {
        e.item = it;
        if (e.leaving) {
          e.leaving = false;
          e.controller.duration = Motion.springDuration;
          e.controller.forward();
        }
      }
      next.add(e);
      next.addAll(leavingAfter[id] ?? const []);
    }
    _entries = next;
  }

  @override
  void dispose() {
    for (final e in _entries) {
      e.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final e in _entries)
          _EntryTransition(
            key: ValueKey(e.id),
            animation: e.controller,
            leaving: e.leaving,
            spacing: widget.spacing,
            child: IgnorePointer(ignoring: e.leaving, child: widget.itemBuilder(context, e.item)),
          ),
      ],
    );
  }
}

class _EntryTransition extends StatelessWidget {
  const _EntryTransition({
    super.key,
    required this.animation,
    required this.leaving,
    required this.spacing,
    required this.child,
  });
  final AnimationController animation;
  final bool leaving;
  final double spacing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
    final fade = CurvedAnimation(
      parent: animation,
      curve: const Interval(.15, 1, curve: Curves.easeOut),
    );
    return SizeTransition(
      sizeFactor: size,
      axisAlignment: -1,
      child: Padding(
        padding: EdgeInsets.only(bottom: spacing),
        child: Flip(
          child: FadeTransition(
            opacity: fade,
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final v = animation.value;
                return Transform.translate(
                  offset: Offset(leaving ? (1 - v) * -18 : 0, 0),
                  child: Transform.scale(scale: .96 + .04 * v, child: child),
                );
              },
              child: RepaintBoundary(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
