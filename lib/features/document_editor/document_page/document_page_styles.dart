import 'package:flutter/material.dart';

import '../../../app/theme/app_color_tokens.dart';
import '../../../app/theme/app_typography.dart';

/// Text styles for the printed page. The page is always white, so it reads
/// the light tokens whatever the app theme is.
abstract final class DocumentPageStyles {
  static const tokens = AppColorTokens.light;

  static Color get mutedInk => tokens.ink.withValues(alpha: 0.62);

  static TextStyle get body => TextStyle(
    fontFamily: AppTypography.documentFontFamily,
    fontSize: AppTypography.body,
    height: 1.4,
    color: tokens.ink,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle get caption =>
      body.copyWith(fontSize: AppTypography.caption, color: mutedInk);

  static TextStyle get companyName => body.copyWith(
    fontSize: AppTypography.paneTitle,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get pageTitle => body.copyWith(
    fontSize: AppTypography.pageTitle + 8,
    fontWeight: FontWeight.w600,
    height: 1.15,
  );

  static TextStyle get documentNumber =>
      body.copyWith(fontSize: AppTypography.field, fontWeight: FontWeight.w500);

  static TextStyle get emphasis => body.copyWith(fontWeight: FontWeight.w600);
}
