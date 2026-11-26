import 'package:flutter/widgets.dart';

enum AnimationSetting { full, reduced, off }

class AppMotion {
  static Duration duration(AnimationSetting setting, {Duration full = const Duration(milliseconds: 220), Duration reduced = const Duration(milliseconds: 120)}) {
    switch (setting) {
      case AnimationSetting.full:
        return full;
      case AnimationSetting.reduced:
        return reduced;
      case AnimationSetting.off:
        return Duration.zero;
    }
  }

  static Curve curve(AnimationSetting setting) {
    return setting == AnimationSetting.off ? Curves.linear : Curves.easeOutCubic;
  }

  static bool shouldReduce(BuildContext context, AnimationSetting setting) {
    final mediaReduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return mediaReduce || setting != AnimationSetting.full;
  }
}
