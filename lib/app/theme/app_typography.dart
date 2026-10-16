import 'package:flutter/foundation.dart';

/// Font families and the type scale (spec section 7.1).
abstract final class AppTypography {
  static String uiFontFamily(TargetPlatform platform) =>
      platform == TargetPlatform.windows
      ? 'Segoe UI Variable Text'
      : 'NotoSans';

  static const documentFontFamily = 'IBMPlexSans';

  static const double caption = 12;
  static const double body = 13;
  static const double field = 14;
  static const double paneTitle = 16;
  static const double pageTitle = 20;
}
