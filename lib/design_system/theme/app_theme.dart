import 'package:flutter/material.dart';
import 'package:kmail_desktop/app/state/settings_controller.dart';
import 'package:kmail_desktop/design_system/tokens/app_colors.dart';
import 'package:kmail_desktop/design_system/tokens/app_radii.dart';
import 'package:kmail_desktop/design_system/tokens/app_typography.dart';

class AppTheme {
  const AppTheme({required this.settings});
  final AppSettings settings;

  ThemeData light() => _build(Brightness.light, AppColorTokens.light);
  ThemeData dark() => _build(Brightness.dark, AppColorTokens.dark);

  ThemeData _build(Brightness brightness, AppColorTokens tokens) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: tokens.primary,
      onPrimary: tokens.onPrimary,
      secondary: tokens.secondary,
      onSecondary: isDark ? Colors.black : Colors.white,
      error: tokens.error,
      onError: Colors.white,
      surface: tokens.surface,
      onSurface: tokens.textPrimary,
      tertiary: tokens.accent,
      onTertiary: isDark ? Colors.black : Colors.white,
      outline: tokens.border,
      outlineVariant: tokens.divider,
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: tokens.textPrimary,
      onInverseSurface: tokens.surface,
      inversePrimary: tokens.accent,
      surfaceTint: tokens.primary,
    );

    final textTheme =
        AppTypography.textTheme(tokens.textPrimary, tokens.textSecondary);
    final controlRadius = BorderRadius.circular(AppRadii.sm);
    final surfaceRadius = BorderRadius.circular(AppRadii.lg);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: tokens.background,
      canvasColor: tokens.surface,
      dividerColor: tokens.divider,
      textTheme: textTheme,
      fontFamily: 'Segoe UI',
      visualDensity: VisualDensity.standard,
      extensions: [AppColors(tokens: tokens)],
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.surface,
        foregroundColor: tokens.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: tokens.surface,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: surfaceRadius,
          side: BorderSide(color: tokens.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          side: BorderSide(color: tokens.border),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: tokens.surfaceElevated,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(color: tokens.border),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(tokens.surfaceElevated),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              side: BorderSide(color: tokens.border),
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surfaceMuted,
        border: OutlineInputBorder(
          borderRadius: controlRadius,
          borderSide: BorderSide(color: tokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: controlRadius,
          borderSide: BorderSide(color: tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: controlRadius,
          borderSide: BorderSide(color: tokens.primary, width: 1.4),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
        labelStyle: textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: controlRadius),
        selectedTileColor: tokens.selection,
        iconColor: tokens.textSecondary,
        textColor: tokens.textPrimary,
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2B3645) : const Color(0xFF243041),
          borderRadius: BorderRadius.circular(AppRadii.xs),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: Colors.white),
      ),
      dividerTheme:
          DividerThemeData(color: tokens.divider, thickness: 1, space: 1),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: tokens.border),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: tokens.textSecondary,
          shape: RoundedRectangleBorder(borderRadius: controlRadius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: tokens.primary,
          shape: RoundedRectangleBorder(borderRadius: controlRadius),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: tokens.primary,
          foregroundColor: tokens.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: controlRadius),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.textPrimary,
          side: BorderSide(color: tokens.border),
          shape: RoundedRectangleBorder(borderRadius: controlRadius),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          side: BorderSide(color: tokens.border),
        ),
        side: BorderSide(color: tokens.border),
        backgroundColor: tokens.surfaceMuted,
        selectedColor: tokens.selection,
        labelStyle: textTheme.labelMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            isDark ? const Color(0xFF243041) : const Color(0xFF182230),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: controlRadius),
      ),
    );
  }
}
