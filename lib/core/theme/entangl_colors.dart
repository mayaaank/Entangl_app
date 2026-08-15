import 'package:flutter/material.dart';

/// Monochromatic Organic Tactile palette — light paper / dark charcoal.
/// One green ink accent. Everything else is a warm gray family.
@immutable
class EntanglColors extends ThemeExtension<EntanglColors> {
  const EntanglColors({
    required this.surface,
    required this.surfaceLowest,
    required this.surfaceLow,
    required this.surfaceHigh,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.outline,
    required this.outlineVariant,
    required this.error,
    required this.navDock,
    required this.navActive,
    required this.navInactive,
    required this.quoteWash,
    required this.toolFill,
    required this.shadow,
  });

  final Color surface;
  final Color surfaceLowest;
  final Color surfaceLow;
  final Color surfaceHigh;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color outline;
  final Color outlineVariant;
  final Color error;
  final Color navDock;
  final Color navActive;
  final Color navInactive;
  final Color quoteWash;
  final Color toolFill;
  final Color shadow;

  static const light = EntanglColors(
    surface: Color(0xFFF4F2EE),
    surfaceLowest: Color(0xFFFFFFFF),
    surfaceLow: Color(0xFFECEAE5),
    surfaceHigh: Color(0xFFE4E2DC),
    onSurface: Color(0xFF1A1A18),
    onSurfaceVariant: Color(0xFF4A4A46),
    primary: Color(0xFF2F2F2C),
    onPrimary: Color(0xFFF4F2EE),
    primaryContainer: Color(0xFF3D4A43),
    outline: Color(0xFF6E6E68),
    outlineVariant: Color(0xFFC8C6BF),
    error: Color(0xFF8F2F2F),
    navDock: Color(0xFF1F1F1D),
    navActive: Color(0xFFE8E6E0),
    navInactive: Color(0xFFE8E6E0),
    quoteWash: Color(0xFFE8E6E0),
    toolFill: Color(0xFFE8E6E0),
    shadow: Color(0x33000000),
  );

  static const dark = EntanglColors(
    surface: Color(0xFF141412),
    surfaceLowest: Color(0xFF1E1E1B),
    surfaceLow: Color(0xFF242421),
    surfaceHigh: Color(0xFF2C2C28),
    onSurface: Color(0xFFECEAE4),
    onSurfaceVariant: Color(0xFFB4B2AA),
    primary: Color(0xFFD8D6D0),
    onPrimary: Color(0xFF161614),
    primaryContainer: Color(0xFF3A3A36),
    outline: Color(0xFF8A8882),
    outlineVariant: Color(0xFF3A3A36),
    error: Color(0xFFE08A8A),
    navDock: Color(0xFF0E0E0C),
    navActive: Color(0xFF2C2C28),
    navInactive: Color(0xFFD8D6D0),
    quoteWash: Color(0xFF2A2A26),
    toolFill: Color(0xFF2C2C28),
    shadow: Color(0x66000000),
  );

  List<BoxShadow> get shadowCard => [
        BoxShadow(color: shadow, offset: const Offset(3, 3), blurRadius: 0),
      ];

  List<BoxShadow> get shadowFloat => [
        BoxShadow(color: shadow, offset: const Offset(4, 4), blurRadius: 0),
      ];

  static EntanglColors of(BuildContext context) =>
      Theme.of(context).extension<EntanglColors>() ?? EntanglColors.light;

  @override
  EntanglColors copyWith({
    Color? surface,
    Color? surfaceLowest,
    Color? surfaceLow,
    Color? surfaceHigh,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? outline,
    Color? outlineVariant,
    Color? error,
    Color? navDock,
    Color? navActive,
    Color? navInactive,
    Color? quoteWash,
    Color? toolFill,
    Color? shadow,
  }) =>
      EntanglColors(
        surface: surface ?? this.surface,
        surfaceLowest: surfaceLowest ?? this.surfaceLowest,
        surfaceLow: surfaceLow ?? this.surfaceLow,
        surfaceHigh: surfaceHigh ?? this.surfaceHigh,
        onSurface: onSurface ?? this.onSurface,
        onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
        primary: primary ?? this.primary,
        onPrimary: onPrimary ?? this.onPrimary,
        primaryContainer: primaryContainer ?? this.primaryContainer,
        outline: outline ?? this.outline,
        outlineVariant: outlineVariant ?? this.outlineVariant,
        error: error ?? this.error,
        navDock: navDock ?? this.navDock,
        navActive: navActive ?? this.navActive,
        navInactive: navInactive ?? this.navInactive,
        quoteWash: quoteWash ?? this.quoteWash,
        toolFill: toolFill ?? this.toolFill,
        shadow: shadow ?? this.shadow,
      );

  @override
  EntanglColors lerp(ThemeExtension<EntanglColors>? other, double t) {
    if (other is! EntanglColors) return this;
    return EntanglColors(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceLowest: Color.lerp(surfaceLowest, other.surfaceLowest, t)!,
      surfaceLow: Color.lerp(surfaceLow, other.surfaceLow, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant:
          Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryContainer:
          Color.lerp(primaryContainer, other.primaryContainer, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      error: Color.lerp(error, other.error, t)!,
      navDock: Color.lerp(navDock, other.navDock, t)!,
      navActive: Color.lerp(navActive, other.navActive, t)!,
      navInactive: Color.lerp(navInactive, other.navInactive, t)!,
      quoteWash: Color.lerp(quoteWash, other.quoteWash, t)!,
      toolFill: Color.lerp(toolFill, other.toolFill, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension EntanglPaletteX on BuildContext {
  EntanglColors get palette => EntanglColors.of(this);
}
