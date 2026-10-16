import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/app/theme/app_theme.dart';
import 'package:pacim_invoicer/features/document_editor/document_page/inline_text_field.dart';

Future<List<String>> _pump(
  WidgetTester tester, {
  bool readOnly = false,
  int? maxLines = 1,
  bool showField = true,
  ValueNotifier<bool>? visibility,
}) async {
  final commits = <String>[];
  final isVisible = visibility ?? ValueNotifier(showField);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: buildAppTheme(
          brightness: Brightness.light,
          platform: TargetPlatform.windows,
        ),
        home: Scaffold(
          body: Column(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: isVisible,
                builder: (context, visible, _) => visible
                    ? InlineTextField(
                        value: 'start',
                        placeholder: 'Type here',
                        readOnly: readOnly,
                        maxLines: maxLines,
                        onCommitted: commits.add,
                      )
                    : const SizedBox.shrink(),
              ),
              const TextField(key: ValueKey('other')),
            ],
          ),
        ),
      ),
    ),
  );
  return commits;
}

void main() {
  testWidgets('typing alone does not commit', (tester) async {
    final commits = await _pump(tester);
    await tester.enterText(find.byType(InlineTextField), 'changed');
    await tester.pump();
    expect(commits, isEmpty);
  });

  testWidgets('blur commits once', (tester) async {
    final commits = await _pump(tester);
    await tester.enterText(find.byType(InlineTextField), 'changed');
    await tester.tap(find.byKey(const ValueKey('other')));
    await tester.pump();
    expect(commits, ['changed']);
  });

  testWidgets('Enter on a single-line field commits exactly once', (
    tester,
  ) async {
    final commits = await _pump(tester);
    await tester.enterText(find.byType(InlineTextField), 'changed');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('other')));
    await tester.pump();
    expect(commits, ['changed']);
  });

  testWidgets(
    'Enter in a multi-line field adds a newline and does not commit',
    (tester) async {
      final commits = await _pump(tester, maxLines: null);
      await tester.enterText(find.byType(InlineTextField), 'one\ntwo');
      await tester.pump();
      expect(commits, isEmpty);
      expect(find.text('one\ntwo'), findsOneWidget);
    },
  );

  testWidgets('disposing while edited commits the typed text', (tester) async {
    final visibility = ValueNotifier(true);
    final commits = await _pump(tester, visibility: visibility);
    await tester.enterText(find.byType(InlineTextField), 'changed');
    visibility.value = false;
    await tester.pump();
    expect(commits, ['changed']);
  });

  testWidgets('a field removed while edited commits without a provider error', (
    tester,
  ) async {
    final committedProvider = NotifierProvider<_TextHolder, String>(
      _TextHolder.new,
    );
    final isShownProvider = NotifierProvider<_FlagHolder, bool>(
      _FlagHolder.new,
    );
    late WidgetRef capturedRef;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                capturedRef = ref;
                return ref.watch(isShownProvider)
                    ? InlineTextField(
                        value: 'start',
                        onCommitted: (text) => ref
                            .read(committedProvider.notifier)
                            .replaceWith(text),
                      )
                    : const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(InlineTextField), 'typed');
    capturedRef.read(isShownProvider.notifier).hide();
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(capturedRef.read(committedProvider), 'typed');
  });

  testWidgets('a read-only field cannot be edited and shows no placeholder', (
    tester,
  ) async {
    final commits = await _pump(tester, readOnly: true);
    final field = tester.widget<TextField>(find.byType(TextField).first);
    expect(field.readOnly, isTrue);
    expect(field.decoration!.hintText, isNull);
    await tester.tap(find.byType(InlineTextField));
    await tester.tap(find.byKey(const ValueKey('other')));
    await tester.pump();
    expect(commits, isEmpty);
  });
}

class _TextHolder extends Notifier<String> {
  @override
  String build() => '';

  void replaceWith(String text) => state = text;
}

class _FlagHolder extends Notifier<bool> {
  @override
  bool build() => true;

  void hide() => state = false;
}
