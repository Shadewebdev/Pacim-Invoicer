import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/app/theme/app_color_tokens.dart';
import 'package:pacim_invoicer/app/theme/app_theme.dart';
import 'package:pacim_invoicer/app/theme/keyboard_focus_ring_theme.dart';
import 'package:pacim_invoicer/app/theme/document_type_colors.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';

void main() {
  test('light tokens match spec hex values', () {
    const tokens = AppColorTokens.light;
    expect(tokens.chrome, const Color(0xFFECEEF1));
    expect(tokens.surface, const Color(0xFFF7F8FA));
    expect(tokens.paper, const Color(0xFFFFFFFF));
    expect(tokens.ink, const Color(0xFF1E2633));
    expect(tokens.rule, const Color(0xFFD5D9E0));
    expect(tokens.action, const Color(0xFF2A5BD7));
  });

  test('stage tints match spec', () {
    const colors = DocumentTypeColors.light;
    expect(colors.tintFor(DocumentType.quotation), const Color(0xFFDCE6FA));
    expect(colors.inkFor(DocumentType.salesOrder), const Color(0xFF7C6100));
    expect(colors.tintFor(DocumentType.deliveryOrder), const Color(0xFFF7D9E0));
  });

  test('dark tokens match spec', () {
    expect(AppColorTokens.dark.chrome, const Color(0xFF1D2128));
    expect(AppColorTokens.dark.surface, const Color(0xFF252A32));
    expect(AppColorTokens.dark.ink, const Color(0xFFE6E9EE));
    expect(AppColorTokens.dark.rule, const Color(0xFF3A404A));
    expect(AppColorTokens.dark.action, const Color(0xFF7FA2F5));
    expect(AppColorTokens.dark.paper, const Color(0xFFFFFFFF));
  });

  test('dark stage colours are dimmed tints and lightened inks', () {
    const light = DocumentTypeColors.light;
    final dark = DocumentTypeColors.dark;
    for (final type in DocumentType.values) {
      expect(dark.tintFor(type), light.tintFor(type).withValues(alpha: 0.3));
      expect(
        dark.inkFor(type),
        Color.lerp(light.inkFor(type), Colors.white, 0.45),
      );
    }
    expect(dark.inkFor(DocumentType.quotation).toARGB32(), 0xFF8CA2D8);
  });

  test('extensions copyWith and lerp work', () {
    final changed = AppColorTokens.light.copyWith(
      action: const Color(0xFF000000),
    );
    expect(changed.action, const Color(0xFF000000));
    expect(changed.chrome, AppColorTokens.light.chrome);
    expect(
      AppColorTokens.light.lerp(AppColorTokens.dark, 0).action,
      AppColorTokens.light.action,
    );
    expect(
      AppColorTokens.light.lerp(AppColorTokens.dark, 1).action,
      AppColorTokens.dark.action,
    );
    final stage = DocumentTypeColors.light.lerp(DocumentTypeColors.dark, 1);
    expect(
      stage.tintFor(DocumentType.quotation),
      DocumentTypeColors.dark.tintFor(DocumentType.quotation),
    );
  });

  test('theme exposes extensions and compact density', () {
    final theme = buildAppTheme(
      brightness: Brightness.light,
      platform: TargetPlatform.windows,
    );
    expect(theme.extension<AppColorTokens>(), isNotNull);
    expect(theme.extension<DocumentTypeColors>(), isNotNull);
    expect(theme.visualDensity, VisualDensity.compact);
    expect(theme.textTheme.bodyMedium!.fontFamily, 'Segoe UI Variable Text');
  });

  test('non-windows platforms use Noto Sans', () {
    final theme = buildAppTheme(
      brightness: Brightness.dark,
      platform: TargetPlatform.android,
    );
    expect(theme.textTheme.bodyMedium!.fontFamily, 'NotoSans');
  });

  testWidgets('controls render 32 px tall under compact density', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(
          brightness: Brightness.light,
          platform: TargetPlatform.windows,
        ),
        home: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FilledButton(onPressed: () {}, child: const Text('Save')),
              OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
              TextButton(onPressed: () {}, child: const Text('Close')),
              const SizedBox(width: 200, child: TextField()),
            ],
          ),
        ),
      ),
    );
    for (final type in [FilledButton, OutlinedButton, TextButton, TextField]) {
      expect(tester.getSize(find.byType(type)).height, 32, reason: '$type');
    }
  });

  for (final brightness in Brightness.values) {
    test(
      'every button style shows a 2 px action ring when focused in $brightness',
      () {
        final theme = buildAppTheme(
          brightness: brightness,
          platform: TargetPlatform.windows,
        );
        final action = theme.extension<AppColorTokens>()!.action;
        final styles = {
          'filled': theme.filledButtonTheme.style,
          'elevated': theme.elevatedButtonTheme.style,
          'outlined': theme.outlinedButtonTheme.style,
          'text': theme.textButtonTheme.style,
          'icon': theme.iconButtonTheme.style,
        };
        for (final entry in styles.entries) {
          final side = entry.value!.side!.resolve({WidgetState.focused});
          expect(side?.width, 2, reason: entry.key);
          expect(side?.color, action, reason: entry.key);
        }
        final resting = theme.outlinedButtonTheme.style!.side!.resolve({});
        expect(resting?.color, theme.extension<AppColorTokens>()!.rule);
      },
    );
  }

  testWidgets('the focus ring follows keyboard versus pointer interaction', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(
          brightness: Brightness.light,
          platform: TargetPlatform.windows,
        ),
        home: const KeyboardFocusRingTheme(
          child: Scaffold(body: _FocusRingProbe()),
        ),
      ),
    );
    final probe = find.byType(_FocusRingProbe);
    double? ringWidth() =>
        Theme.of(tester.element(probe)).filledButtonTheme.style!.side!
            .resolve({WidgetState.focused})
            ?.width;

    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    await tester.pump();
    expect(ringWidth(), 2);

    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTouch;
    await tester.pump();
    expect(ringWidth(), isNull);

    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
  });
}

class _FocusRingProbe extends StatelessWidget {
  const _FocusRingProbe();

  @override
  Widget build(BuildContext context) => const SizedBox();
}
