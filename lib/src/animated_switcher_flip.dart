import 'dart:math' as math;

import 'package:flutter/widgets.dart';

const _curveIn = Curves.linear;
final _curveOut = Curves.linear.flipped;

class AnimatedSwitcherFlip extends AnimatedSwitcher {
  AnimatedSwitcherFlip.flipX({
    required Duration duration,
    required String keyValue,
    Duration? reverseDuration,
    AnimatedSwitcherLayoutBuilder? layoutBuilder,
    Curve? switchInCurve,
    Curve? switchOutCurve,
    Widget? child,
    Key? key,
  }) : super(
          duration: duration,
          layoutBuilder: (widget, list) => Stack(children: [widget!, ...list]),
          reverseDuration: reverseDuration,
          switchInCurve: switchInCurve ?? _curveIn,
          switchOutCurve: switchOutCurve ?? _curveOut,
          transitionBuilder: _transitionBuilder(false, keyValue),
          child: child,
          key: key,
        );

  /// Animated Switcher with flip transition around y axis
  AnimatedSwitcherFlip.flipY({
    required Duration duration,
    required String keyValue,
    Duration? reverseDuration,
    AnimatedSwitcherLayoutBuilder? layoutBuilder,
    Curve? switchInCurve,
    Curve? switchOutCurve,
    Widget? child,
    Key? key,
  }) : super(
          duration: duration,
          reverseDuration: reverseDuration,
          layoutBuilder: (widget, list) => Stack(children: [widget!, ...list]),
          switchInCurve: switchInCurve ?? _curveIn,
          switchOutCurve: switchOutCurve ?? _curveOut,
          transitionBuilder: _transitionBuilder(true, keyValue),
          child: child,
          key: key,
        );
}

AnimatedSwitcherTransitionBuilder _transitionBuilder(bool isYAxis, keyValue) =>
    (final child, final animation) => _FlipTransition(
          rotate: animation,
          isYAxis: isYAxis,
          keyValue: keyValue,
          child: child,
        );

class _FlipTransition extends AnimatedWidget {
  const _FlipTransition({
    required Animation<double> rotate,
    required this.isYAxis,
    required this.keyValue,
    this.child,
    Key? key,
  }) : super(key: key, listenable: rotate);

  final bool isYAxis;
  final String keyValue;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final rotateAnimation = Tween(begin: math.pi, end: 0.0).animate(rotate);
    return AnimatedBuilder(
      animation: rotateAnimation,
      child: child,
      builder: (context, widget) {
        final isUnder = (ValueKey(keyValue) != widget!.key);
        var tilt = ((rotate.value - 0.5).abs() - 0.5) * 0.001;
        tilt *= isUnder ? -1.0 : 1.0;
        final value = isUnder
            ? math.min(rotateAnimation.value, math.pi / 2)
            : rotateAnimation.value;
        return Transform(
          transform: !isYAxis
              ? (Matrix4.rotationY(value)..setEntry(3, 0, tilt))
              : (Matrix4.rotationX(value)..setEntry(3, 1, tilt)),
          alignment: Alignment.center,
          child: widget,
        );
      },
    );
  }

  Animation<double> get rotate => listenable as Animation<double>;
}
