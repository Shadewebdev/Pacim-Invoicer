import 'package:flutter/material.dart';

/// Neutral chrome colours shared by every screen (spec section 7.1).
@immutable
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  const AppColorTokens({
    required this.chrome,
    required this.surface,
    required this.paper,
    required this.ink,
    required this.rule,
    required this.action,
  });

  final Color chrome;
  final Color surface;
  final Color paper;
  final Color ink;
  final Color rule;
  final Color action;

  static const light = AppColorTokens(
    chrome: Color(0xFFECEEF1),
    surface: Color(0xFFF7F8FA),
    paper: Color(0xFFFFFFFF),
    ink: Color(0xFF1E2633),
    rule: Color(0xFFD5D9E0),
    action: Color(0xFF2A5BD7),
  );

  /// The page stays white in the dark theme.
  static const dark = AppColorTokens(
    chrome: Color(0xFF1D2128),
    surface: Color(0xFF252A32),
    paper: Color(0xFFFFFFFF),
    ink: Color(0xFFE6E9EE),
    rule: Color(0xFF3A404A),
    action: Color(0xFF7FA2F5),
  );

  @override
  AppColorTokens copyWith({
    Color? chrome,
    Color? surface,
    Color? paper,
    Color? ink,
    Color? rule,
    Color? action,
  }) {
    return AppColorTokens(
      chrome: chrome ?? this.chrome,
      surface: surface ?? this.surface,
      paper: paper ?? this.paper,
      ink: ink ?? this.ink,
      rule: rule ?? this.rule,
      action: action ?? this.action,
    );
  }

  @override
  AppColorTokens lerp(ThemeExtension<AppColorTokens>? other, double t) {
    if (other is! AppColorTokens) return this;
    return AppColorTokens(
      chrome: Color.lerp(chrome, other.chrome, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      paper: Color.lerp(paper, other.paper, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      rule: Color.lerp(rule, other.rule, t)!,
      action: Color.lerp(action, other.action, t)!,
    );
  }
}
