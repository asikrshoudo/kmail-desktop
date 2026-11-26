import 'package:flutter/material.dart';

class AppColorTokens {
  const AppColorTokens({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceMuted,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.selection,
    required this.hover,
    required this.focusRing,
  });

  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceMuted;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color selection;
  final Color hover;
  final Color focusRing;

  static const light = AppColorTokens(
    primary: Color(0xFF1F4B99),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF4A607A),
    accent: Color(0xFF0F766E),
    background: Color(0xFFF5F7FA),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFFDFEFE),
    surfaceMuted: Color(0xFFF0F4F8),
    border: Color(0xFFD9E2EC),
    divider: Color(0xFFE6EDF3),
    textPrimary: Color(0xFF182230),
    textSecondary: Color(0xFF526071),
    textDisabled: Color(0xFF98A6B3),
    success: Color(0xFF1F8B4C),
    warning: Color(0xFFB7791F),
    error: Color(0xFFC2413B),
    info: Color(0xFF2563EB),
    selection: Color(0x1A1F4B99),
    hover: Color(0x0F182230),
    focusRing: Color(0x661F4B99),
  );

  static const dark = AppColorTokens(
    primary: Color(0xFF8CB4FF),
    onPrimary: Color(0xFF0B1A33),
    secondary: Color(0xFFA9BDD6),
    accent: Color(0xFF5EEAD4),
    background: Color(0xFF11161D),
    surface: Color(0xFF171D26),
    surfaceElevated: Color(0xFF1D2530),
    surfaceMuted: Color(0xFF202A36),
    border: Color(0xFF314053),
    divider: Color(0xFF273445),
    textPrimary: Color(0xFFF3F7FB),
    textSecondary: Color(0xFFB9C7D6),
    textDisabled: Color(0xFF72839A),
    success: Color(0xFF57C27D),
    warning: Color(0xFFF0B45C),
    error: Color(0xFFF87171),
    info: Color(0xFF7AB0FF),
    selection: Color(0x338CB4FF),
    hover: Color(0x14F3F7FB),
    focusRing: Color(0x668CB4FF),
  );
}

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({required this.tokens});
  final AppColorTokens tokens;

  @override
  AppColors copyWith({AppColorTokens? tokens}) => AppColors(tokens: tokens ?? this.tokens);

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    final a = tokens;
    final b = other.tokens;
    return AppColors(
      tokens: AppColorTokens(
        primary: l(a.primary, b.primary),
        onPrimary: l(a.onPrimary, b.onPrimary),
        secondary: l(a.secondary, b.secondary),
        accent: l(a.accent, b.accent),
        background: l(a.background, b.background),
        surface: l(a.surface, b.surface),
        surfaceElevated: l(a.surfaceElevated, b.surfaceElevated),
        surfaceMuted: l(a.surfaceMuted, b.surfaceMuted),
        border: l(a.border, b.border),
        divider: l(a.divider, b.divider),
        textPrimary: l(a.textPrimary, b.textPrimary),
        textSecondary: l(a.textSecondary, b.textSecondary),
        textDisabled: l(a.textDisabled, b.textDisabled),
        success: l(a.success, b.success),
        warning: l(a.warning, b.warning),
        error: l(a.error, b.error),
        info: l(a.info, b.info),
        selection: l(a.selection, b.selection),
        hover: l(a.hover, b.hover),
        focusRing: l(a.focusRing, b.focusRing),
      ),
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
