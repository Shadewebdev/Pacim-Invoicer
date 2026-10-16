import 'package:flutter/material.dart';

import 'app_color_tokens.dart';
import 'app_typography.dart';
import 'document_type_colors.dart';

const double _controlHeight = 32;
const Size _controlMinimumSize = Size(0, _controlHeight);
// Compact density shrinks button minimum sizes by 8 px; controls must stay at
// exactly 32 px, so buttons opt out of the density adjustment and rely on
// _controlMinimumSize instead.
const VisualDensity _controlDensity = VisualDensity.standard;
final _controlShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(4),
);

ThemeData buildAppTheme({
  required Brightness brightness,
  required TargetPlatform platform,
}) {
  final isDark = brightness == Brightness.dark;
  final tokens = isDark ? AppColorTokens.dark : AppColorTokens.light;
  final stageColors = isDark
      ? DocumentTypeColors.dark
      : DocumentTypeColors.light;
  final family = AppTypography.uiFontFamily(platform);

  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: tokens.action,
        brightness: brightness,
      ).copyWith(
        primary: tokens.action,
        onPrimary: isDark ? const Color(0xFF10182B) : Colors.white,
        surface: tokens.surface,
        onSurface: tokens.ink,
        outline: tokens.rule,
        outlineVariant: tokens.rule,
      );

  final baseTextTheme = Typography.material2021(platform: platform).black.apply(
    fontFamily: family,
    bodyColor: tokens.ink,
    displayColor: tokens.ink,
  );
  final textTheme = baseTextTheme.copyWith(
    bodySmall: baseTextTheme.bodySmall?.copyWith(
      fontSize: AppTypography.caption,
    ),
    bodyMedium: baseTextTheme.bodyMedium?.copyWith(
      fontSize: AppTypography.body,
    ),
    bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontSize: AppTypography.field),
    titleMedium: baseTextTheme.titleMedium?.copyWith(
      fontSize: AppTypography.paneTitle,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: baseTextTheme.titleLarge?.copyWith(
      fontSize: AppTypography.pageTitle,
      fontWeight: FontWeight.w600,
    ),
    labelLarge: baseTextTheme.labelLarge?.copyWith(
      fontSize: AppTypography.body,
    ),
  );

  final inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(4),
    borderSide: BorderSide(color: tokens.rule),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    platform: platform,
    visualDensity: VisualDensity.compact,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: tokens.surface,
    canvasColor: tokens.surface,
    dividerColor: tokens.rule,
    fontFamily: family,
    textTheme: textTheme,
    focusColor: tokens.action.withValues(alpha: 0.2),
    extensions: [tokens, stageColors],
    cardTheme: CardThemeData(
      elevation: 0,
      color: tokens.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: tokens.rule),
      ),
    ),
    dividerTheme: DividerThemeData(color: tokens.rule, space: 1, thickness: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: _controlMinimumSize,
        visualDensity: _controlDensity,
        shape: _controlShape,
        textStyle: textTheme.labelLarge,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: _controlMinimumSize,
        visualDensity: _controlDensity,
        elevation: 0,
        shape: _controlShape,
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: _controlMinimumSize,
        visualDensity: _controlDensity,
        shape: _controlShape,
        side: BorderSide(color: tokens.rule),
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: _controlMinimumSize,
        visualDensity: _controlDensity,
        shape: _controlShape,
        textStyle: textTheme.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: tokens.surface,
      constraints: const BoxConstraints(minHeight: _controlHeight),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: tokens.action, width: 2),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      textStyle: textTheme.bodySmall?.copyWith(color: tokens.surface),
    ),
  );
}
