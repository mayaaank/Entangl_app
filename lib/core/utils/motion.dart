import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Central motion / accessibility helpers.
class Motion {
  Motion._();

  static bool reduce(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  static Duration duration(
    BuildContext context, {
    int ms = 250,
    int reducedMs = 0,
  }) {
    if (reduce(context)) return Duration(milliseconds: reducedMs);
    return Duration(milliseconds: ms);
  }

  static void hapticLight(BuildContext context) {
    if (!reduce(context)) HapticFeedback.lightImpact();
  }

  static void hapticMedium(BuildContext context) {
    if (!reduce(context)) HapticFeedback.mediumImpact();
  }
}
