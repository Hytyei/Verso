import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/// Motion tokens (spec §6.4): iOS-like spring, response ~0.35 s, damping 0.85.
class Motion {
  Motion._();

  static final SpringDescription spring = SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 322, // (2π / 0.35 s)²
    ratio: 0.85,
  );

  /// A snappier spring for small controls (checkbox pop, pills).
  static final SpringDescription snappy = SpringDescription.withDampingRatio(mass: 1, stiffness: 520, ratio: 0.6);

  /// Duration that lets [springCurve] settle.
  static const Duration springDuration = Duration(milliseconds: 460);
  static const Duration fade = Duration(milliseconds: 150);

  /// The spring as a Curve for implicit animations.
  static final Curve springCurve = SpringCurve(spring);

  /// User setting; combined with the OS "reduce motion" flag.
  static final ValueNotifier<bool> reduceSetting = ValueNotifier(false);

  static bool reduced(BuildContext context) =>
      reduceSetting.value || (MediaQuery.maybeDisableAnimationsOf(context) ?? false);

  /// Spring timing: use only for transforms, sizes and positions (it overshoots).
  static Duration dur(BuildContext context) => reduced(context) ? fade : springDuration;
  static Curve curve(BuildContext context) => reduced(context) ? Curves.easeOut : springCurve;

  /// Non-overshooting timing for colors, shadows and decorations.
  static const Duration smoothDuration = Duration(milliseconds: 240);
  static Duration smoothDur(BuildContext context) => reduced(context) ? fade : smoothDuration;
  static const Curve smooth = Curves.easeOutCubic;
}

/// Maps t∈[0,1] onto a unit spring simulation over [Motion.springDuration].
class SpringCurve extends Curve {
  SpringCurve(this.spring);
  final SpringDescription spring;

  @override
  double transformInternal(double t) {
    final sim = SpringSimulation(spring, 0, 1, 0);
    final secs = Motion.springDuration.inMicroseconds / 1e6;
    return sim.x(t * secs);
  }
}
