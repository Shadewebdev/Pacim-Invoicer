# Pacim Invoicer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a desktop-first Flutter app that creates Quotations, Sales Orders and Delivery Orders as
self-contained snapshot documents. Documents are edited inline on an A4 page, upgraded along a chain,
listed per type and exported to PDF. Storage is local Drift/SQLite behind repository interfaces, ready
for Firestore later.

**Architecture:** Feature-first layout over a pure Dart domain core (`lib/domain`, no Flutter or IO).
Storage sits behind abstract repositories (`lib/data/repositories`) with Drift implementations
(`lib/data/local`), selected in `lib/data/repository_providers.dart`. Riverpod `Notifier`s own
behaviour, and widgets stay presentational. One immutable `BusinessDocument` drives both the editor
page and the PDF.

**Tech Stack:** Flutter (stable 3.47+), flutter_riverpod, go_router, freezed + json_serializable,
drift + drift_flutter, pdf + printing, file_picker, window_manager, uuid, crypto, image, intl,
path_provider, mocktail, flutter_lints.

**Spec:** `docs/superpowers/specs/2026-10-17-pacim-invoicer-design.md` (executors read both).

## Execution model (from spec section 12)

Each task is tagged **Agent:** with the subagent that implements it:
- `flutter-coder`: Sonnet 5.5, medium effort.
- `flutter-architect`: Opus 5.5, medium effort.

After every implementation step block, the orchestrator dispatches `flutter-tester` (Haiku 5.5, low
effort) for the "Verify" step. Subagents never commit. The orchestrator reviews the diff against the
spec and runs the "Commit" step.

On a verify failure, re-dispatch the same implementer once with the tester's report. If it fails a
second time, dispatch `flutter-architect` with both reports.

Tasks marked **Parallel-safe with** may be dispatched at the same time.

## Global Constraints

- **Project:** name `pacim_invoicer`, display name "Pacim Invoicer", org `com.pacim`, platforms
  `windows`, `android`, `web`.
- **Dependencies:** only the packages in spec section 10. Add them with `flutter pub add` (latest
  stable). Never add any other package; report the need to the orchestrator instead.
- **Domain purity:** `lib/domain/**` imports no `package:flutter`, `dart:io`, `drift` or `printing`.
- **Money and quantities:** amounts are `int` minor units; quantities are `int` ×1000; percentages
  are `int` ×100 (`800` = 8%). Rounding is half-up.
- **Arithmetic:** every multiplication of amounts, quantities or percentages goes through `BigInt`,
  because web ints are 53-bit doubles.
- **IDs and numbers:** IDs are UUID v4 strings. Document numbers never change once allocated and are
  never reused.
- **No master lists:** settings are copied into a document at creation, and existing documents never
  read live settings.
- **Copy:** sentence case everywhere; no all-caps labels. Buttons say what they do ("Export PDF",
  "Upgrade to sales order").
- **Locking:** locked documents are read-only. Writes to a locked document throw
  `DocumentLockedException`.
- **Code quality:** `flutter analyze` must report zero issues, and `dart format .` must leave no diff.
- **Code generation:** after changing freezed, json or drift sources, run
  `dart run build_runner build --delete-conflicting-outputs`. Generated `*.g.dart` and
  `*.freezed.dart` files are committed.
- **Names** say what a thing is or does. No abbreviations except QT/SO/DO in number patterns.
- **Colour tokens, fonts, sizes and copy** are exactly as in spec section 7.

## Review Focus

1. **Very large amounts on web:** quantity 1,000,000 × unit price 999,999,999 minor units must compute
   exactly, with no 53-bit overflow (test in Task 6).
2. **Messy number typing:** input like `1,234.50`, ` 12 `, `1.234,50` (under a comma-decimal currency),
   `abc` or empty. Valid input parses according to the document's `CurrencyFormat` separators. Invalid
   input returns `null`, so the cell keeps its previous value and shows an error outline (tests in
   Tasks 5 and 18).
3. **Rapid double-create:** creating two documents of the same type at once must yield two distinct,
   consecutive numbers (test in Task 11).
4. **Long or multi-line descriptions:** a 2,000-character or multi-line description wraps in the grid
   and in the PDF. In the PDF it continues across pages instead of clipping or throwing (test in
   Task 21).
5. **Closing during a pending autosave:** edits made within the 2 s debounce window are flushed when
   leaving the editor or closing the window, not lost (tests in Tasks 16 and 19).

---

## File structure

```
lib/
  main.dart
  app/pacim_invoicer_app.dart, app_router.dart
  app/theme/app_color_tokens.dart, document_type_colors.dart, app_typography.dart, app_theme.dart
  app/shell/app_shell.dart, window_title_bar.dart, navigation_sidebar.dart, status_bar.dart,
            status_bar_message_provider.dart, app_breakpoints.dart
  domain/models/  document_type.dart, currency_format.dart, company_details.dart,
                  customer_details.dart, document_layout_options.dart, pricing_terms.dart,
                  line_item.dart, signature_block.dart, business_document.dart,
                  document_settings.dart, document_numbering_rule.dart, document_summary.dart,
                  document_chain.dart, document_totals.dart, document_list_query.dart,
                  validation_issue.dart
  domain/services/ id_generator.dart, document_totals_calculator.dart, document_number_formatter.dart,
                   delivery_progress_calculator.dart, document_factory.dart,
                   document_upgrade_service.dart, document_validator.dart
  domain/exceptions/document_exceptions.dart
  data/repositories/ document_repository.dart, settings_repository.dart, asset_repository.dart,
                     number_sequence_repository.dart
  data/local/ pacim_database.dart, database_connection.dart, drift_document_repository.dart,
              drift_settings_repository.dart, drift_asset_repository.dart,
              drift_number_sequence_repository.dart
  data/payload/document_payload_migrator.dart
  data/images/image_import_service.dart
  data/uuid_id_generator.dart
  data/repository_providers.dart
  shared/document_page_metrics.dart
  shared/formatting/ money_formatter.dart, quantity_formatter.dart, number_input_parser.dart,
                     date_formatter.dart
  features/settings/ settings_page.dart, settings_controller.dart, sections/*.dart,
                     header_preview.dart
  features/document_list/ document_list_page.dart, document_list_controller.dart,
                          document_summary_table.dart, document_type_badge.dart
  features/document_editor/ document_editor_page.dart, document_editor_controller.dart,
        document_editor_state.dart, document_commands.dart,
        document_page/ document_page_view.dart, page_header_section.dart,
                       customer_section.dart, totals_section.dart, notes_terms_section.dart,
                       signature_section.dart, page_footer_section.dart, inline_text_field.dart
        line_item_grid/ line_item_grid.dart, line_item_row.dart, grid_cell_address.dart,
                        grid_focus_controller.dart, grid_shortcuts.dart
        properties_pane/ properties_pane.dart, document_properties_section.dart,
                         header_footer_properties_section.dart, pricing_properties_section.dart,
                         signature_properties_section.dart
        chain_breadcrumb/ chain_breadcrumb.dart, document_chain_provider.dart
        locked_document_banner.dart, unsaved_changes_guard.dart
  features/pdf_export/ document_pdf_builder.dart, pdf_export_service.dart, pdf_fonts.dart
assets/fonts/ IBMPlexSans-{Regular,Medium,SemiBold,Bold}.ttf, NotoSans-{Regular,Medium,SemiBold}.ttf
test/ mirrors lib/; test/data/contract/*_contract.dart hold reusable contract suites;
      test/support/ fake_repositories.dart, document_builders.dart
```

---

## Milestone 1: scaffold, theme, shell

### Task 1: Project scaffold, dependencies, fonts, DocumentType
**Agent:** flutter-coder

**Files:**
- Create: Flutter project in repo root, `analysis_options.yaml`, `assets/fonts/*`,
  `lib/domain/models/document_type.dart`, `test/domain/models/document_type_test.dart`
- Modify: `pubspec.yaml`, `.gitignore` (append the Flutter defaults, keep `.claude/settings.local.json`)

**Interfaces:**
- Produces:
  - `enum DocumentType { quotation, salesOrder, deliveryOrder }`, with getters:
    - `String get displayName` ("Quotation", "Sales order", "Delivery order");
    - `String get pluralDisplayName` ("Quotations", "Sales orders", "Delivery orders");
    - `String get routeSegment` ("quotations", "sales-orders", "delivery-orders");
    - `DocumentType? get nextStage` (QT→SO, SO→DO, DO→null);
    - `bool get showsPricing` (false for deliveryOrder).
  - `DocumentType.fromRouteSegment(String)`.

- [ ] **Step 1:** Run `flutter create --project-name pacim_invoicer --org com.pacim --platforms windows,android,web .` from the repo root.
  - Delete the counter demo from `lib/main.dart` and `test/widget_test.dart`.
- [ ] **Step 2:** Add dependencies:
  - `flutter pub add flutter_riverpod go_router freezed_annotation json_annotation drift drift_flutter pdf printing file_picker window_manager uuid crypto image intl path_provider`
  - `flutter pub add --dev build_runner freezed json_serializable drift_dev mocktail flutter_lints`
- [ ] **Step 3:** Download the OFL fonts into `assets/fonts/`:
  - IBM Plex Sans Regular, Medium, SemiBold and Bold, from the IBM/plex GitHub release.
  - Noto Sans Regular, Medium and SemiBold, from notofonts/latin-greek-cyrillic.
  - Register them in `pubspec.yaml` as families `IBMPlexSans` and `NotoSans`.
  - Add `assets/fonts/` to the asset list too, so the PDF builder can load the files.
- [ ] **Step 4:** Write the failing test `test/domain/models/document_type_test.dart`:
```dart
test('next stage follows quotation → sales order → delivery order', () {
  expect(DocumentType.quotation.nextStage, DocumentType.salesOrder);
  expect(DocumentType.salesOrder.nextStage, DocumentType.deliveryOrder);
  expect(DocumentType.deliveryOrder.nextStage, isNull);
});
test('route segments round-trip', () {
  for (final type in DocumentType.values) {
    expect(DocumentType.fromRouteSegment(type.routeSegment), type);
  }
});
test('delivery orders hide pricing', () {
  expect(DocumentType.deliveryOrder.showsPricing, isFalse);
  expect(DocumentType.quotation.showsPricing, isTrue);
});
```
- [ ] **Step 5:** Run `flutter test test/domain/models/document_type_test.dart`. Expected: FAIL (file missing).
- [ ] **Step 6:** Implement `DocumentType` in `lib/domain/models/document_type.dart`. Make `lib/main.dart` a minimal `runApp(const ProviderScope(child: Placeholder()))`.
- [ ] **Step 7 (Verify, flutter-tester):** Run `flutter analyze`, `flutter test`, `flutter build windows --debug` and `flutter build web`. Expected: all pass.
- [ ] **Step 8 (Commit):** `git add -A && git commit -m "chore: scaffold Flutter project with dependencies and fonts"`

### Task 2: Theme tokens and typography
**Agent:** flutter-coder (load the `frontend-design:frontend-design` skill first)

**Files:**
- Create: `lib/app/theme/app_color_tokens.dart`, `document_type_colors.dart`, `app_typography.dart`, `app_theme.dart`
- Test: `test/app/theme/app_theme_test.dart`

**Interfaces:**
- Consumes: `DocumentType`.
- Produces:
  - `AppColorTokens extends ThemeExtension<AppColorTokens>` with fields `chrome`, `surface`, `paper`,
    `ink`, `rule` and `action`, plus `static const light` and `dark`.
  - `DocumentTypeColors extends ThemeExtension<DocumentTypeColors>` with
    `Color tintFor(DocumentType)` and `Color inkFor(DocumentType)`, plus `light` and `dark`.
  - `AppTypography`:
    - `static String uiFontFamily(TargetPlatform)`: `'Segoe UI Variable Text'` on Windows,
      otherwise `'NotoSans'`.
    - `static const documentFontFamily = 'IBMPlexSans'`.
    - Size constants `caption 12`, `body 13`, `field 14`, `paneTitle 16`, `pageTitle 20`.
  - `ThemeData buildAppTheme({required Brightness brightness, required TargetPlatform platform})`.
    - Material 3 with `VisualDensity.compact`.
    - 32 px controls, 4 px radius on buttons and inputs, no elevation on cards.
    - Both extensions attached.

- [ ] **Step 1:** Write failing tests:
```dart
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
  expect(AppColorTokens.dark.action, const Color(0xFF7FA2F5));
  expect(AppColorTokens.dark.paper, const Color(0xFFFFFFFF)); // page stays white
});
test('theme exposes extensions and compact density', () {
  final theme = buildAppTheme(brightness: Brightness.light, platform: TargetPlatform.windows);
  expect(theme.extension<AppColorTokens>(), isNotNull);
  expect(theme.extension<DocumentTypeColors>(), isNotNull);
  expect(theme.visualDensity, VisualDensity.compact);
  expect(theme.textTheme.bodyMedium!.fontFamily, 'Segoe UI Variable Text');
});
```
  Dark stage tints are the light tints at 30% opacity (`withValues(alpha: 0.3)`), and the dark inks
  are the light inks lightened.
- [ ] **Step 2:** Run `flutter test test/app/theme`. Expected: FAIL.
- [ ] **Step 3:** Implement the four files.
- [ ] **Step 4 (Verify, flutter-tester):** Run `flutter analyze` and `flutter test test/app/theme`. Expected: pass.
- [ ] **Step 5 (Commit):** `git commit -m "feat: add theme tokens and typography"`

### Task 3: App shell and routing
**Agent:** flutter-coder · **Parallel-safe with:** Task 4

**Files:**
- Create: `lib/app/pacim_invoicer_app.dart`, `app_router.dart`, `lib/app/shell/*`
- Modify: `lib/main.dart`
- Test: `test/app/shell/app_shell_test.dart`

**Interfaces:**
- Consumes: `buildAppTheme`, `DocumentType`.
- Produces:
  - `AppBreakpoints`: `compactMaxWidth = 600`, `mediumMaxWidth = 900`.
  - Routes, as a `ShellRoute` wrapping `AppShell`:
    - `/` redirects to `/quotations`;
    - `/:typeSegment` → `DocumentListPage(documentType)` (a placeholder `Text` until Task 15);
    - `/documents/:documentId` → `DocumentEditorPage(documentId)` (a placeholder until Task 17);
    - `/settings` → `SettingsPage` (a placeholder until Task 14).
  - `final appRouterProvider = Provider<GoRouter>(...)`.
  - `final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>` (Task 15 persists it).
  - `final statusBarMessageProvider = NotifierProvider<StatusBarMessageController, String?>`.
  - `AppShell({required Widget child})`:
    - shows `WindowTitleBar` only when `!kIsWeb && defaultTargetPlatform == TargetPlatform.windows`;
    - shows `NavigationSidebar`: 220 px; a 56 px rail below 900; a `Drawer` below 600;
    - shows `StatusBar`.
  - `main()` on Windows: `windowManager.ensureInitialized()`, `TitleBarStyle.hidden`, minimum size
    1024×700, title "Pacim Invoicer".

- [ ] **Step 1:** Write failing widget tests:
  - `'sidebar lists the three document types and settings'`: expects texts "Quotations", "Sales orders", "Delivery orders", "Settings".
  - `'tapping Sales orders navigates to /sales-orders'`.
  - `'below 900px the sidebar collapses to a rail without labels'`: set `tester.view.physicalSize` to 800×700 and expect `find.text('Sales orders')` to find nothing.
  - `'below 600px navigation moves into a drawer'`.
- [ ] **Step 2:** Run the tests. Expected: FAIL.
- [ ] **Step 3:** Implement the shell.
  - The title bar uses `DragToMoveArea` plus `WindowCaptionButton.minimize`, `.maximize` and `.close` from window_manager, and shows the app icon and "Pacim Invoicer".
  - The status bar's left side shows `statusBarMessageProvider`.
- [ ] **Step 4 (Verify, flutter-tester):** Run `flutter analyze` and `flutter test test/app`. Then `flutter build windows --debug`. Expected: pass.
- [ ] **Step 5 (Commit):** `git commit -m "feat: add desktop app shell and routing"`

---

## Milestone 2: domain

### Task 4: Domain models
**Agent:** flutter-coder · **Parallel-safe with:** Task 3

**Files:**
- Create: every file in `lib/domain/models/` listed in File structure (except `document_type.dart`), plus `lib/domain/exceptions/document_exceptions.dart`
- Test: `test/domain/models/business_document_json_test.dart`, `test/support/document_builders.dart`

**Interfaces:**
- Produces: `@freezed` classes with exactly the fields of spec section 4. Additions and defaults:
  - **`CurrencyFormat`:**
    - fields `currencyCode`, `symbol`, `decimalPlaces`, `symbolPosition`
      (`enum CurrencySymbolPosition { before, after }`), `thousandsSeparator` (default `','`) and
      `decimalSeparator` (default `'.'`);
    - `static const defaultFormat`: USD, `$`, 2 places, before;
    - `int get minorUnitsPerMajor`, i.e. `10^decimalPlaces`.
  - **`PricingTerms`:** fields `currencyFormat`, `taxLabel` (default `'Tax'`),
    `taxRatePercentScaled` (default 0) and `isTaxEnabled` (default false).
  - **`LineItem`:** fields `lineItemId`, `sourceLineItemId?`, `description`, `unit`,
    `quantityScaled`, `unitPriceMinor` and `discountPercentScaled`. Defaults: `''`, `''`, `1000`,
    `0`, `0`.
  - **`DocumentLayoutOptions`:** every flag defaults to `true`, except `showDiscountColumn = false`.
  - **`SignatureBlock`:** fields `signatoryName`, `signatoryTitle`, `signatureAssetId?` and
    `signatureCaption`.
  - **`DocumentNumberingRule`:** fields `pattern` and `resetsYearly` (default false).
  - **`DocumentSettings`:**
    - `factory DocumentSettings.initial()` uses these defaults:
      - patterns `QT-{yyyy}-{seq:4}`, `SO-{yyyy}-{seq:4}` and `DO-{yyyy}-{seq:4}`;
      - captions "Authorised signature" for QT and SO, and "Received by" for DO;
      - an empty company name;
      - `CurrencyFormat.defaultFormat`;
      - `quotationValidityDays: 30`.
    - The section 4 maps are `Map<DocumentType, …>` with an enum-name JSON key converter.
    - Also add `String appearance` (`'system' | 'light' | 'dark'`, default `'system'`).
  - **`BusinessDocument`:**
    - `static const currentSchemaVersion = 1`;
    - `bool get isLocked => lockedAt != null`.
  - **`DocumentTotals`:** fields `Map<String, int> lineAmountMinorById`,
    `subtotalBeforeDiscountMinor`, `discountTotalMinor`, `subtotalMinor`, `taxMinor` and
    `grandTotalMinor`.
  - **`DocumentListQuery`:**
    - fields `documentType`, `searchText` (default `''`), `issuedFrom?`, `issuedTo?`,
      `sortField` (`enum DocumentSortField { documentNumber, customerName, issueDate, grandTotal,
      updatedAt }`, default `issueDate`), `sortDescending` (default true) and `limit` (default 50);
    - pagination grows `limit` (no cursor needed locally; Firestore uses `limit()` the same way).
  - **`ValidationIssue`:**
    - fields `ValidationIssueKind kind` and `String? lineItemId`;
    - `enum ValidationIssueKind { missingCustomerName, noLineItems, zeroQuantity,
      deliveryExceedsRemaining }`;
    - `String get message` with these exact strings:
      - "Customer name is empty";
      - "This document has no items";
      - "An item has a quantity of zero";
      - "An item delivers more than remains on the sales order".
  - **Exceptions:** `DocumentNotFoundException(documentId)`, `DocumentLockedException(documentId)`,
    `InvalidUpgradeException(String reason)` and `StorageWriteException(Object cause)`. All
    implement `Exception` and have a readable `toString`.
  - **`test/support/document_builders.dart`:**
    - `BusinessDocument buildTestDocument({DocumentType type = DocumentType.quotation,
      List<LineItem>? lineItems, String chainId = 'chain-1', String documentId = 'doc-1',
      String? sourceDocumentId, DateTime? lockedAt})`;
    - `LineItem buildTestLine({String id = 'line-1', int quantityScaled = 1000,
      int unitPriceMinor = 1000, int discountPercentScaled = 0})`.

- [ ] **Step 1:** Write failing tests:
  - `'BusinessDocument survives a JSON round trip'`: build a document with 2 lines, every optional field set, and a locked date; expect `BusinessDocument.fromJson(doc.toJson()) == doc`.
  - `'DocumentSettings.initial uses spec numbering patterns'`: expects `numberingRuleByType[DocumentType.quotation]!.pattern == 'QT-{yyyy}-{seq:4}'`.
  - `'DocumentType map keys serialize as enum names'`: `jsonEncode(settings.toJson())` contains `"salesOrder"`.
- [ ] **Step 2:** Run `flutter test test/domain/models`. Expected: FAIL.
- [ ] **Step 3:** Implement the models. Run `dart run build_runner build --delete-conflicting-outputs`.
- [ ] **Step 4 (Verify, flutter-tester):** Run `flutter analyze` and `flutter test test/domain`. Expected: pass.
- [ ] **Step 5 (Commit):** `git commit -m "feat: add document domain models"`

### Task 5: Money, quantity and date formatting and parsing
**Agent:** flutter-coder · **Parallel-safe with:** Tasks 6, 7, 8

**Files:**
- Create: `lib/shared/formatting/money_formatter.dart`, `quantity_formatter.dart`, `number_input_parser.dart`, `date_formatter.dart`
- Test: `test/shared/formatting/*_test.dart`

**Interfaces:**
- Produces (pure Dart; `intl` only for dates):
  - `String formatMoney(int amountMinor, CurrencyFormat format, {bool includeSymbol = true})`
  - `String formatQuantity(int quantityScaled)`: up to 3 decimals, trailing zeros trimmed.
  - `int? parseMoneyInput(String input, CurrencyFormat format)`: returns minor units or `null`.
  - `int? parseQuantityInput(String input, CurrencyFormat format)`: returns ×1000 or `null`; uses the
    format's separators.
  - `int? parsePercentInput(String input)`: returns ×100 or `null`; accepts `8`, `8.5` and `8.5%`.
  - `String formatDocumentDate(DateTime date)`: `d MMM yyyy`.

- [ ] **Step 1:** Write failing tests with these exact cases:
```dart
const usd = CurrencyFormat.defaultFormat;
final eur = usd.copyWith(currencyCode: 'EUR', symbol: '€', symbolPosition: CurrencySymbolPosition.after,
    thousandsSeparator: '.', decimalSeparator: ',');
final jpy = usd.copyWith(currencyCode: 'JPY', symbol: '¥', decimalPlaces: 0);
expect(formatMoney(123456, usd), r'$1,234.56');
expect(formatMoney(-5, usd), r'-$0.05');
expect(formatMoney(123456, eur), '1.234,56 €');
expect(formatMoney(1234, jpy), '¥1,234');
expect(parseMoneyInput('1,234.50', usd), 123450);
expect(parseMoneyInput(' 12 ', usd), 1200);
expect(parseMoneyInput('1.234,50', eur), 123450);
expect(parseMoneyInput('abc', usd), isNull);
expect(parseMoneyInput('', usd), isNull);
expect(parseMoneyInput('1.005', usd), 101);          // half-up to 2 places
expect(parseQuantityInput('2.5', usd), 2500);
expect(parseQuantityInput('0.0005', usd), 1);        // half-up to 3 places
expect(formatQuantity(2500), '2.5');
expect(formatQuantity(3000), '3');
expect(parsePercentInput('8.5%'), 850);
expect(formatDocumentDate(DateTime(2026, 10, 17)), '17 Oct 2026');
```
- [ ] **Step 2:** Run `flutter test test/shared/formatting`. Expected: FAIL.
- [ ] **Step 3:** Implement. Parse by stripping whitespace, the symbol and thousands separators, mapping the decimal separator to `.`, and rejecting anything else. Round half-up by decimal string arithmetic, not `double`.
- [ ] **Step 4 (Verify, flutter-tester):** Run `flutter test test/shared/formatting` and `flutter analyze`. Expected: pass.
- [ ] **Step 5 (Commit):** `git commit -m "feat: add money and quantity formatting and parsing"`

### Task 6: DocumentTotalsCalculator
**Agent:** flutter-coder · **Parallel-safe with:** Tasks 5, 7, 8

**Files:**
- Create: `lib/domain/services/document_totals_calculator.dart`
- Test: `test/domain/services/document_totals_calculator_test.dart`

**Interfaces:**
- Produces:
  - `class DocumentTotalsCalculator { const DocumentTotalsCalculator(); DocumentTotals calculate(BusinessDocument document); int lineAmountMinor(LineItem line); int lineGrossMinor(LineItem line); }`
  - Shared helper in the same file: `int roundHalfUpDivide(BigInt numerator, BigInt denominator)`.
    It rounds half away from zero, and Task 16 reuses it.
- Formulas, all in `BigInt`:
  - gross = roundHalfUp(qtyScaled × price / 1000);
  - amount = roundHalfUp(qtyScaled × price × (10000 − discountScaled) / (1000 × 10000));
  - discount = gross − amount;
  - subtotal = Σ amount;
  - tax = `isTaxEnabled` ? roundHalfUp(subtotal × taxRateScaled / 10000) : 0;
  - grand total = subtotal + tax.

- [ ] **Step 1:** Write failing tests:
  - `'2.5 × 10.00 at 10% discount = 22.50'`: qty 2500, price 1000, discount 1000. Expect amount 2250, gross 2500, discountTotal 250.
  - `'tax 8% on 22.50 rounds half up to 1.80'`: tax 800 enabled. Expect taxMinor 180, grandTotal 2430.
  - `'tax disabled yields zero tax'`.
  - `'half-up rounding: 0.333 × 0.15 = 0.05'`: qty 333, price 15. 4.995 rounds to 5.
  - `'huge values stay exact on web'`: qty 1,000,000,000 (1,000,000 units), price 999,999,999. Expect amount `999999999000000`.
  - `'empty document totals are zero'`.
  - `'lineAmountMinorById has every line id'`.
- [ ] **Step 2:** Run the tests. Expected: FAIL.
- [ ] **Step 3:** Implement.
- [ ] **Step 4 (Verify, flutter-tester):** Run the test file, then `flutter test --platform chrome test/domain/services/document_totals_calculator_test.dart` to prove web exactness. Expected: pass on both.
- [ ] **Step 5 (Commit):** `git commit -m "feat: add document totals calculator"`

### Task 7: DocumentNumberFormatter
**Agent:** flutter-coder · **Parallel-safe with:** Tasks 5, 6, 8

**Files:**
- Create: `lib/domain/services/document_number_formatter.dart`
- Test: `test/domain/services/document_number_formatter_test.dart`

**Interfaces:**
- Produces:
  - `class DocumentNumberFormatter { const DocumentNumberFormatter(); String format(String pattern, {required int sequence, required DateTime date}); List<String> findPatternProblems(String pattern); }`
  - Tokens: `{yyyy}`, `{yy}`, `{mm}` and `{seq:N}` (N = 1–9, zero-padded; a longer sequence is not
    truncated).
  - `findPatternProblems` returns these user-facing strings:
    - "Add {seq:N} so each number is unique" (no seq token);
    - "Unknown token {x}";
    - "Use {seq:N} only once".

- [ ] **Step 1:** Write failing tests:
```dart
const formatter = DocumentNumberFormatter();
final date = DateTime(2026, 3, 9);
expect(formatter.format('QT-{yyyy}-{seq:4}', sequence: 7, date: date), 'QT-2026-0007');
expect(formatter.format('SO{yy}{mm}/{seq:3}', sequence: 12, date: date), 'SO2603/012');
expect(formatter.format('DO-{seq:2}', sequence: 1234, date: date), 'DO-1234');
expect(formatter.findPatternProblems('QT-{yyyy}'), ['Add {seq:N} so each number is unique']);
expect(formatter.findPatternProblems('QT-{dd}-{seq:4}'), ['Unknown token {dd}']);
expect(formatter.findPatternProblems('QT-{yyyy}-{seq:4}'), isEmpty);
```
- [ ] **Step 2:** Run the tests. Expected: FAIL.
- [ ] **Step 3:** Implement with a single `RegExp(r'\{([^}]*)\}')` pass.
- [ ] **Step 4 (Verify, flutter-tester):** Run the test file. Expected: pass.
- [ ] **Step 5 (Commit):** `git commit -m "feat: add document number formatter"`

### Task 8: DeliveryProgressCalculator
**Agent:** flutter-coder · **Parallel-safe with:** Tasks 5, 6, 7

**Files:**
- Create: `lib/domain/services/delivery_progress_calculator.dart`
- Test: `test/domain/services/delivery_progress_calculator_test.dart`

**Interfaces:**
- Produces:
  - `class DeliveryProgressCalculator { const DeliveryProgressCalculator(); Map<String, int> remainingQuantityBySalesOrderLine({required BusinessDocument salesOrder, required List<BusinessDocument> deliveryOrders, String? excludeDeliveryOrderId}); int remainingQuantityForLine(...same params, required String salesOrderLineItemId); }`
  - Delivery Order lines map to Sales Order lines by `sourceLineItemId`. Remaining quantities can go
    negative (over-delivery).

- [ ] **Step 1:** Write failing tests:
  - `'no deliveries → remaining equals ordered'`.
  - `'two partial deliveries subtract'`: ordered 10,000, delivered 3,000 and 2,500, remaining 4,500.
  - `'excludeDeliveryOrderId ignores the order being edited'`.
  - `'over-delivery yields negative remaining'`.
  - `'delivery lines without sourceLineItemId are ignored'`.
- [ ] **Step 2:** Run the tests. Expected: FAIL.
- [ ] **Step 3:** Implement.
- [ ] **Step 4 (Verify, flutter-tester):** Run the test file. Expected: pass.
- [ ] **Step 5 (Commit):** `git commit -m "feat: add delivery progress calculator"`

### Task 9: DocumentFactory, DocumentUpgradeService, DocumentValidator
**Agent:** flutter-coder

**Files:**
- Create: `lib/domain/services/id_generator.dart`, `document_factory.dart`, `document_upgrade_service.dart`, `document_validator.dart`
- Test: `test/domain/services/document_factory_test.dart`, `document_upgrade_service_test.dart`, `document_validator_test.dart`

**Interfaces:**
- Consumes: models, `DeliveryProgressCalculator`.
- Produces:
  - `abstract interface class IdGenerator { String generateId(); }`
  - `class DocumentFactory`:
    - constructor: `DocumentFactory({required IdGenerator idGenerator})`;
    - `BusinessDocument createStandalone({required DocumentType documentType, required String documentNumber, required DocumentSettings settings, required DateTime now})`:
      - new `documentId` and `chainId`;
      - copies every settings section for the type;
      - one empty line;
      - for a quotation, `validUntilDate = now + settings.quotationValidityDays`;
      - for a delivery order, `deliveryDate = now`.
    - `BusinessDocument duplicateAsDraft({required BusinessDocument source, required String documentNumber, required DateTime now})`:
      - new `documentId` and `chainId`;
      - `sourceDocumentId` null and unlocked;
      - new `lineItemId`s with `sourceLineItemId` null;
      - same type.
    - `BusinessDocument resetSectionToDefaults(BusinessDocument document, DocumentSection section, DocumentSettings settings)`;
    - `enum DocumentSection { company, headerAndFooter, pricing, signature, terms }`.
  - `class UpgradeResult { final BusinessDocument lockedSource; final BusinessDocument createdDocument; }`
  - `class DocumentUpgradeService`:
    - constructor: `DocumentUpgradeService({required IdGenerator idGenerator, DeliveryProgressCalculator deliveryProgressCalculator = const DeliveryProgressCalculator()})`;
    - `String? findUpgradeBlocker({required BusinessDocument source, required List<BusinessDocument> chainDocuments})` returns the reason or `null`:
      - "Delivery orders are the last stage";
      - "This chain already has a sales order";
      - "Every item on this sales order has been delivered".
    - `UpgradeResult createNextStage({required BusinessDocument source, required List<BusinessDocument> chainDocuments, required String documentNumber, required DateTime now})`:
      - follows spec section 3.4 rules 1–5;
      - throws `InvalidUpgradeException` with the blocker text;
      - keeps the source's company, customer, pricing and terms snapshots;
      - takes layout and signature defaults from the source;
      - `lockedSource` keeps any existing `lockedAt`, otherwise sets it to `now`.
  - `class DocumentValidator`:
    - `List<ValidationIssue> validate(BusinessDocument document, {BusinessDocument? salesOrder, List<BusinessDocument> otherDeliveryOrders = const []})`;
    - the delivery check runs only when `salesOrder` is given.

- [ ] **Step 1:** Write failing tests:
  - Factory:
    - `'createStandalone copies settings snapshot and allocates new chain'`;
    - `'quotation validity is 30 days by default'`;
    - `'duplicateAsDraft unlinks from chain and source'`;
    - `'resetSectionToDefaults(pricing) replaces only pricingTerms'`.
  - Upgrade:
    - `'quotation → sales order copies lines with sourceLineItemId and locks source'`;
    - `'second sales order in a chain is rejected'` (expects `InvalidUpgradeException`);
    - `'delivery order defaults to remaining quantities and omits fully delivered lines'`: SO lines A 10,000 and B 5,000; an existing DO delivers A 4,000 and B 5,000; the new DO has one line, A, with 6,000;
    - `'already locked sales order keeps original lockedAt'`;
    - `'delivery order upgrade is blocked'`.
  - Validator:
    - one test per `ValidationIssueKind`;
    - `'valid document has no issues'`.
- [ ] **Step 2:** Run `flutter test test/domain/services`. Expected: new tests FAIL.
- [ ] **Step 3:** Implement. Use a `SequentialIdGenerator` test fake in `test/support/` (`'id-1'`, `'id-2'`, …).
- [ ] **Step 4 (Verify, flutter-tester):** Run `flutter test test/domain` and `flutter analyze`. Expected: pass. Also confirm that `grep -rE "package:flutter|dart:io|drift" lib/domain` prints nothing.
- [ ] **Step 5 (Commit):** `git commit -m "feat: add document factory, upgrade service and validator"`

---

## Milestone 3: data

### Task 10: Repository interfaces, payload migrator, document repository on Drift
**Agent:** flutter-coder

**Files:**
- Create: `lib/data/repositories/*.dart` (all four interfaces), `lib/data/payload/document_payload_migrator.dart`, `lib/data/local/pacim_database.dart`, `database_connection.dart`, `drift_document_repository.dart`, `lib/data/uuid_id_generator.dart`
- Test: `test/data/contract/document_repository_contract.dart`, `test/data/local/drift_document_repository_test.dart`, `test/data/payload/document_payload_migrator_test.dart`

**Interfaces:**
- Produces:
  - The four interfaces exactly as in spec section 5.1. `NumberSequenceRepository`,
    `AssetRepository` and `SettingsRepository` are implemented in Tasks 11–12.
  - `PacimDatabase extends _$PacimDatabase`, `schemaVersion 1`, with tables:
    - `DocumentRows`: `documentId` PK, `documentType` text, `documentNumber`, `chainId`,
      `sourceDocumentId?`, `customerName`, `issueDate`, `grandTotalMinor`, `currencyCode`,
      `lockedAt?`, `updatedAt`, `schemaVersion`, `payloadJson`. Indexes on (documentType, issueDate),
      (chainId) and (documentType, documentNumber).
    - `NumberSequenceRows`: (documentType, year) PK, `lastSequence`.
    - `AssetRows`: `assetId` PK, `bytes` blob, `mimeType`.
    - `SettingsRows`: `id` PK = 1, `payloadJson`.
  - `PacimDatabase.forTesting(QueryExecutor executor)` and
    `QueryExecutor openPacimDatabaseConnection()`. The latter uses `driftDatabase(name: 'pacim_invoicer')`;
    the web options are added in Task 13.
  - `class DriftDocumentRepository implements DocumentRepository`:
    - constructor: `DriftDocumentRepository(PacimDatabase database, {DocumentTotalsCalculator totalsCalculator = const DocumentTotalsCalculator()})`;
    - the summary columns are derived from the document on every save;
    - `saveUpgrade` and `deleteDocument` throw `UnimplementedError` until Task 11.
  - `DocumentPayloadMigrator`:
    - `Map<String, dynamic> migrateToCurrent(Map<String, dynamic> payload, int fromVersion)`;
    - v1 is the identity;
    - throws `FormatException` when `fromVersion` is greater than the current version.
  - `class UuidIdGenerator implements IdGenerator` (uuid v4).
  - The contract suite takes a factory function:
    `void runDocumentRepositoryContract(Future<DocumentRepository> Function() createRepository)`.

- [ ] **Step 1:** Write the failing contract tests:
  - `'saveDocument then getDocument returns an equal document'`;
  - `'getDocument for unknown id throws DocumentNotFoundException'`;
  - `'saving over a locked stored document throws DocumentLockedException'`;
  - `'watchDocumentSummaries filters by type and searchText on number or customer, case-insensitive'`;
  - `'watchDocumentSummaries sorts by each DocumentSortField both directions'`;
  - `'watchDocumentSummaries applies issued date range inclusively'`;
  - `'watchDocumentSummaries respects limit'`;
  - `'summary grandTotalMinor matches DocumentTotalsCalculator'`;
  - `'watchDocumentChain groups QT, SO and DOs ordered by number'`;
  - `'watchDocumentSummaries emits again after a save'`.
  - Run the suite from `drift_document_repository_test.dart` with `PacimDatabase.forTesting(NativeDatabase.memory())`.
  - Migrator tests: `'v1 payload is unchanged'` and `'future version throws FormatException'`.
- [ ] **Step 2:** Run `flutter test test/data`. Expected: FAIL.
- [ ] **Step 3:** Implement and run `build_runner`. Searching uses a `LIKE` with `lower()` on `documentNumber` and `customerName`. Reads go through `DocumentPayloadMigrator`.
- [ ] **Step 4 (Verify, flutter-tester):** Run `flutter test test/data` and `flutter analyze`. Expected: pass.
- [ ] **Step 5 (Commit):** `git commit -m "feat: add repository interfaces and Drift document repository"`

### Task 11: Atomic numbering, upgrade transaction, delete-with-unlock
**Agent:** flutter-architect

**Files:**
- Create: `lib/data/local/drift_number_sequence_repository.dart`, `test/data/contract/number_sequence_repository_contract.dart`, `test/data/local/drift_number_sequence_repository_test.dart`
- Modify: `lib/data/local/drift_document_repository.dart` (`saveUpgrade`, `deleteDocument`), `test/data/contract/document_repository_contract.dart`

**Interfaces:**
- Consumes: Task 10's database and interfaces.
- Produces:
  - `DriftNumberSequenceRepository(PacimDatabase)`. `allocateNextSequence(type, year:, resetsYearly:)`
    runs in one transaction:
    - when `resetsYearly` is set, the key is (type, year); otherwise it's (type, 0);
    - it returns `lastSequence + 1` and stores it;
    - the first allocation returns 1.
  - `saveUpgrade`, in one transaction:
    - writes `createdDocument`;
    - writes `lockedSource`, bypassing the lock check only for the `lockedAt` change. The source's
      stored payload must otherwise equal the incoming one, or it throws `DocumentLockedException`.
  - `deleteDocument`, in one transaction:
    - throws `DocumentLockedException` if the document is locked;
    - deletes the row;
    - if the document had `sourceDocumentId` and no other row references that source, sets the
      source's `lockedAt` to null.

- [ ] **Step 1:** Write the failing contract tests.
  - Numbering:
    - `'first allocation is 1 and increments'`;
    - `'types have independent counters'`;
    - `'yearly reset starts at 1 in a new year; non-resetting continues'`;
    - `'20 concurrent allocations return 1..20 with no duplicates'`: `Future.wait` over 20 calls; expect the sorted results to equal `List.generate(20, (i) => i + 1)`.
  - Documents:
    - `'saveUpgrade writes created document and locks source atomically'`;
    - `'saveUpgrade failure leaves neither change'`: inject a `createdDocument` whose id collides with an existing locked document;
    - `'deleting the only SO created from a QT unlocks the QT'`;
    - `'deleting one of two DOs keeps the SO locked'`;
    - `'deleting a locked document throws'`.
- [ ] **Step 2:** Run `flutter test test/data`. Expected: FAIL.
- [ ] **Step 3:** Implement. Use `database.transaction`, and in it an `UPDATE ... SET last_sequence = last_sequence + 1 ... RETURNING` (or insert-or-ignore then update, then read inside the same transaction).
- [ ] **Step 4 (Verify, flutter-tester):** Run `flutter test test/data` three times in a row to catch flakiness. Expected: pass every time.
- [ ] **Step 5 (Commit):** `git commit -m "feat: add atomic numbering, upgrade transaction and delete unlock"`

### Task 12: Settings and asset repositories, image import
**Agent:** flutter-coder · **Parallel-safe with:** Task 11

**Files:**
- Create: `lib/data/local/drift_settings_repository.dart`, `drift_asset_repository.dart`, `lib/data/images/image_import_service.dart`, `test/data/contract/settings_repository_contract.dart`, `asset_repository_contract.dart`, `test/data/local/drift_settings_and_assets_test.dart`, `test/data/images/image_import_service_test.dart`

**Interfaces:**
- Produces:
  - `DriftSettingsRepository(PacimDatabase)`: `watchSettings` emits `DocumentSettings.initial()`
    when no row exists.
  - `DriftAssetRepository(PacimDatabase)`: `storeImage` hashes the bytes with SHA-256 (`crypto`),
    writes them insert-or-ignore, and returns the lowercase hex. Storing the same bytes twice returns
    the same id and leaves one row.
  - `class ImageImportService`:
    - `Future<Uint8List> prepareImageForStorage(Uint8List originalBytes)`:
      - decodes with `image`;
      - resizes so the longest edge is at most 600 px (never upscales);
      - re-encodes as PNG when the image has alpha, otherwise as JPEG at quality 85; if the result is
        still over 250 KB, lowers the quality in steps of 10, down to 45;
      - throws `ImageImportException('This file isn't a supported image')` when decoding fails.
    - Runs off the UI thread via `compute` (on web, `compute` runs inline).

- [ ] **Step 1:** Write failing tests:
  - `'settings default to initial when empty'`;
  - `'saveSettings then watchSettings emits saved value'`;
  - `'storing the same image twice returns the same id and one row'`;
  - `'loadImage unknown id returns null'`;
  - `'a 3000x1000 image is resized to 600x200'`;
  - `'output is at most 250 KB'`;
  - `'small images are not upscaled'`;
  - `'non-image bytes throw ImageImportException'`.
- [ ] **Step 2:** Run the tests. Expected: FAIL.
- [ ] **Step 3:** Implement.
- [ ] **Step 4 (Verify, flutter-tester):** Run `flutter test test/data` and `flutter analyze`. Expected: pass.
- [ ] **Step 5 (Commit):** `git commit -m "feat: add settings and asset repositories with image import"`

### Task 13: Drift on web (WASM) and repository providers
**Agent:** flutter-architect

**Files:**
- Create: `lib/data/repository_providers.dart`, `web/sqlite3.wasm`, `web/drift_worker.js`, `test/data/repository_providers_test.dart`
- Modify: `lib/data/local/database_connection.dart`, `lib/main.dart`

**Interfaces:**
- Produces Riverpod providers:
  - `pacimDatabaseProvider`, which disposes the database on dispose;
  - `documentRepositoryProvider`, `numberSequenceRepositoryProvider`, `settingsRepositoryProvider`
    and `assetRepositoryProvider`;
  - `idGeneratorProvider` (`UuidIdGenerator`) and `clockProvider` (`DateTime Function()`, default
    `DateTime.now`);
  - `documentFactoryProvider`, `documentUpgradeServiceProvider`, `documentValidatorProvider`,
    `imageImportServiceProvider` and `documentTotalsCalculatorProvider`.
- This is the only file that names a concrete repository class.
- `openPacimDatabaseConnection()` passes `DriftWebOptions(sqlite3Wasm: Uri.parse('sqlite3.wasm'), driftWorker: Uri.parse('drift_worker.js'))`.
- Take `sqlite3.wasm` and `drift_worker.js` from the releases matching the resolved `sqlite3` and
  `drift` versions in `pubspec.lock`, per drift's web documentation.

- [ ] **Step 1:** Write the failing test `'providers can be overridden with in-memory database'`:
  - create a `ProviderContainer` overriding `pacimDatabaseProvider` with `PacimDatabase.forTesting(NativeDatabase.memory())`;
  - read `documentRepositoryProvider` and save and get a document.
- [ ] **Step 2:** Run it. Expected: FAIL.
- [ ] **Step 3:** Implement. In `main.dart`, wrap the app in `ProviderScope`.
- [ ] **Step 4:** Run `flutter run -d chrome`. Use a temporary debug button or a test-only route to save a document, reload the page and confirm it persists. Remove the temporary code afterwards.
- [ ] **Step 5 (Verify, flutter-tester):** Run `flutter test`, `flutter analyze`, `flutter build web` and `flutter build windows --debug`. Expected: pass.
- [ ] **Step 6 (Commit):** `git commit -m "feat: wire repositories via providers and enable Drift on web"`

---

## Milestone 4: settings

### Task 14: Settings page
**Agent:** flutter-coder (load `frontend-design:frontend-design`)

**Files:**
- Create: `lib/features/settings/settings_page.dart`, `settings_controller.dart`, `header_preview.dart`, `sections/company_settings_section.dart`, `header_footer_settings_section.dart`, `pricing_settings_section.dart`, `signature_settings_section.dart`, `numbering_settings_section.dart`, `appearance_settings_section.dart`
- Modify: `lib/app/app_router.dart` (replace the placeholder), `lib/app/pacim_invoicer_app.dart` (theme mode from settings)
- Test: `test/features/settings/settings_controller_test.dart`, `settings_page_test.dart`, `test/support/fake_repositories.dart`

**Interfaces:**
- Consumes: `settingsRepositoryProvider`, `assetRepositoryProvider`, `imageImportServiceProvider`, `DocumentNumberFormatter`.
- Produces:
  - `settingsControllerProvider`: `AsyncNotifierProvider<SettingsController, DocumentSettings>`, with
    intent methods `updateCompanyDetails(CompanyDetails)`,
    `updateLayoutOptions(DocumentType, DocumentLayoutOptions)`, `updatePricingTerms(PricingTerms)`,
    `updateDefaultTerms(DocumentType, String)`, `updateFooterNote(String)`,
    `updateSignatureBlock(DocumentType, SignatureBlock)`,
    `updateNumberingRule(DocumentType, DocumentNumberingRule)`, `updateAppearance(String)`,
    `Future<void> importCompanyLogo(Uint8List)` and
    `Future<void> importSignatureImage(DocumentType, Uint8List)`.
  - Saves are debounced by 600 ms.
  - `test/support/fake_repositories.dart` holds in-memory fakes of all four repository interfaces,
    which later tasks reuse.
- UI per spec section 7.5:
  - left sub-navigation;
  - tabs per document type, tinted with `DocumentTypeColors`;
  - a `HeaderPreview` on the right;
  - the exact note "Changes apply to new documents. Existing documents keep their own copy.";
  - numbering fields show `findPatternProblems` inline, plus a preview of the next number;
  - image pick via `FilePicker.platform.pickFiles(type: FileType.image, withData: true)`.

- [ ] **Step 1:** Write failing tests:
  - `'updateCompanyDetails persists after debounce'`, using `fakeAsync`;
  - `'invalid numbering pattern shows problem text and is not saved'`;
  - `'importCompanyLogo stores prepared image and sets logoAssetId'`;
  - widget test: `'settings page shows the existing-documents note'`;
  - widget test: `'numbering preview shows QT-2026-0001'`, with `clockProvider` overridden to 2026.
- [ ] **Step 2:** Run the tests. Expected: FAIL.
- [ ] **Step 3:** Implement.
- [ ] **Step 4 (Verify, flutter-tester):** Run `flutter test test/features/settings` and `flutter analyze`. Expected: pass.
- [ ] **Step 5 (Commit):** `git commit -m "feat: add settings page"`

---

## Milestone 5: listings

### Task 15: Document listing pages
**Agent:** flutter-coder (load `frontend-design:frontend-design`)

**Files:**
- Create: `lib/features/document_list/document_list_page.dart`, `document_list_controller.dart`, `document_summary_table.dart`, `document_type_badge.dart`, `lib/features/document_editor/document_commands.dart`
- Modify: `lib/app/app_router.dart`
- Test: `test/features/document_list/document_list_controller_test.dart`, `document_list_page_test.dart`, `test/features/document_editor/document_commands_test.dart`

**Interfaces:**
- Consumes: `documentRepositoryProvider`, the factory, the upgrade service, `numberSequenceRepositoryProvider`, `settingsRepositoryProvider`, `DocumentNumberFormatter`, `clockProvider`.
- Produces:
  - `documentListControllerProvider`: a family `NotifierProvider` keyed by `DocumentType`, holding a
    `DocumentListQuery`. Methods: `setSearchText`, `setIssuedRange`, `setSort(DocumentSortField)`
    (toggles direction if the field is the same) and `loadMore()` (adds 50 to the limit).
  - `documentSummariesProvider`: a family `StreamProvider` keyed by `DocumentType`, reading from
    `watchDocumentSummaries(query)`.
  - `class DocumentCommands` (via `documentCommandsProvider`). All methods allocate the number via
    `allocateNextSequence` and then `DocumentNumberFormatter.format`.
    - `Future<String> createDocument(DocumentType type)`: returns the new id.
    - `Future<String> upgradeDocument(String sourceDocumentId)`: loads the chain via
      `getDocumentsInChain`, calls `createNextStage`, then `saveUpgrade`, and returns the created id.
    - `Future<String> duplicateDocument(String sourceDocumentId)`.
    - `Future<void> deleteDocument(String documentId)`.
    - `String? findUpgradeBlocker(...)` is exposed for menus.
- UI per spec section 7.3:
  - columns: number, customer, issue date, total (hidden when `!type.showsPricing`), status
    ("Draft" or "Locked") and chain;
  - column-header sorting;
  - the search box focuses on Ctrl+F;
  - a date range picker;
  - double-click or Enter opens `/documents/:id`;
  - a right-click `MenuAnchor` with Open, "Upgrade to <next stage displayName lowercase>",
    "Duplicate as new draft", "Export PDF" (disabled until Task 22) and "Delete" (drafts only, with
    a confirm dialog "Delete QT-2026-0004? This can't be undone." and buttons "Delete" / "Cancel");
  - the empty state "No quotations yet" with a "New quotation" button;
  - the command bar's "New quotation" (Ctrl+N) creates a document and navigates to it.
  - the status bar shows "<count> <plural lowercase>", for example "12 sales orders".

- [ ] **Step 1:** Write failing tests:
  - commands:
    - `'createDocument allocates QT-2026-0001 then QT-2026-0002'`;
    - `'upgradeDocument creates SO in same chain and locks QT'`;
    - `'duplicateDocument starts a new chain'`.
  - controller: `'setSort on same field toggles direction'`.
  - page:
    - `'empty state shows New quotation'`;
    - `'delivery order list hides the total column'`;
    - `'locked rows show Locked and hide Delete in the menu'`;
    - `'typing in search filters rows'`.
- [ ] **Step 2:** Run the tests. Expected: FAIL.
- [ ] **Step 3:** Implement.
- [ ] **Step 4 (Verify, flutter-tester):** Run `flutter test test/features` and `flutter analyze`. Expected: pass.
- [ ] **Step 5 (Commit):** `git commit -m "feat: add document listing pages and document commands"`

---

## Milestone 6: editor

### Task 16: DocumentEditorController and autosave
**Agent:** flutter-coder

**Files:**
- Create: `lib/features/document_editor/document_editor_controller.dart`, `document_editor_state.dart`
- Test: `test/features/document_editor/document_editor_controller_test.dart`

**Interfaces:**
- Consumes: `documentRepositoryProvider`, `settingsRepositoryProvider`, `DocumentFactory.resetSectionToDefaults`, `DocumentValidator`, `DeliveryProgressCalculator`, `roundHalfUpDivide`.
- Produces:
  - `@freezed DocumentEditorState`:
    - fields `BusinessDocument document`, `SaveStatus saveStatus`,
      `List<ValidationIssue> validationIssues`, `BusinessDocument? salesOrder` (for DOs) and
      `List<BusinessDocument> otherDeliveryOrders`;
    - `enum SaveStatus { saved, pending, saving, failed }`.
  - `documentEditorControllerProvider`: a family `AsyncNotifierProvider` keyed by `String documentId`.
  - Intents. Each one is a no-op on locked documents, returns a new state, sets `pending` and
    schedules a save 2 s after the last edit:
    - `updateIssueDate`, `updateValidUntilDate`, `updateDeliveryDate`, `updateCustomerReference`;
    - `updateCompanyDetails(CompanyDetails)`, `updateCustomerDetails(CustomerDetails)`;
    - `updateLayoutOptions(DocumentLayoutOptions)`, `updatePricingTerms(PricingTerms)`;
    - `updateCurrencyFormat(CurrencyFormat)`: when `decimalPlaces` changes, re-expresses every
      `unitPriceMinor` as `roundHalfUpDivide(price × 10^new, 10^old)`;
    - `updateNotes`, `updateTermsAndConditions`, `updateFooterNote`,
      `updateSignatureBlock(SignatureBlock)`;
    - `updateLineItem(String lineItemId, LineItem Function(LineItem) change)`;
    - `insertLineItem({required int atIndex})` returns the new `lineItemId`;
    - `duplicateLineItem(String lineItemId)`, `removeLineItem(String lineItemId)`;
    - `moveLineItem(String lineItemId, {required int toIndex})`;
    - `resetSectionToDefaults(DocumentSection)`.
  - Lifecycle:
    - `Future<void> saveNow()` cancels the debounce and saves immediately; it's a no-op when the
      status is `saved`;
    - `onDispose` calls `saveNow()` when the status is `pending`.
  - Error handling: a save error sets `failed` and the status bar message
    "Couldn't save — Retry"; `retrySave()` saves again.
  - On load, the controller subscribes to `watchDocument`. External changes, such as being locked by
    an upgrade from another view, replace the state when the status is `saved`.
  - Validation is recomputed on every change.

- [ ] **Step 1:** Write failing tests, using `fakeAsync` and fake repositories:
  - `'edit sets pending then saves once after 2s of idle'`: three edits 500 ms apart produce one save;
  - `'saveNow flushes immediately'`;
  - `'disposing the provider with pending edits saves them'`;
  - `'edits on a locked document are ignored'`;
  - `'save failure sets failed and retrySave recovers'`;
  - `'changing decimal places from 2 to 0 rounds 1050 to 11'`;
  - `'moveLineItem reorders'`;
  - `'removeLineItem removes'`;
  - `'insertLineItem returns id of empty line at index'`;
  - `'delivery order validation flags over-delivery against its sales order'`;
  - `'external lock replaces state when saved'`.
- [ ] **Step 2:** Run the tests. Expected: FAIL.
- [ ] **Step 3:** Implement.
- [ ] **Step 4 (Verify, flutter-tester):** Run `flutter test test/features/document_editor` and `flutter analyze`. Expected: pass.
- [ ] **Step 5 (Commit):** `git commit -m "feat: add document editor controller with debounced autosave"`

### Task 17: A4 document page view
**Agent:** flutter-coder (load `frontend-design:frontend-design`)

**Files:**
- Create: `lib/shared/document_page_metrics.dart`, `lib/features/document_editor/document_page/*.dart`, `lib/features/document_editor/document_editor_page.dart`
- Modify: `lib/app/app_router.dart`
- Test: `test/features/document_editor/document_page_view_test.dart`, `test/shared/document_page_metrics_test.dart`

**Interfaces:**
- Consumes: `documentEditorControllerProvider`, `DocumentTotalsCalculator`, the formatters, `AppTypography.documentFontFamily`, `DocumentTypeColors`, `assetRepositoryProvider`.
- Produces:
  - `class DocumentPageMetrics`:
    - `static const pageWidthMm = 210`, `pageHeightMm = 297`, `marginMm = 18`;
    - `static const stageBandWidthPx = 4`;
    - `static const pointsPerMm = 72 / 25.4`;
    - `static double mmToLogicalPixels(double mm)`: 1 mm = 96 / 25.4 px at 100% zoom;
    - `static List<LineItemColumn> visibleColumns(DocumentLayoutOptions options, DocumentType type)`:
      - `enum LineItemColumn { index, description, unit, quantity, unitPrice, discount, amount }`;
      - every column has a `flex` ratio: index 0.6, description 5, unit 1.2, quantity 1.2,
        unitPrice 1.8, discount 1.2, amount 2;
      - pricing columns are dropped when `!type.showsPricing`;
      - unit and discount columns follow the layout flags.
  - `InlineTextField`:
    - `({required String value, required ValueChanged<String> onCommitted, bool readOnly, TextStyle? style, int? maxLines, String? placeholder})`;
    - looks like printed text until hover or focus, then shows a 1 px `rule` outline (an `action`
      outline when focused);
    - commits on blur and on Enter (single-line).
  - `DocumentPageView({required String documentId})`:
    - a white page of A4 proportions with a single soft shadow;
    - the left stage band uses `DocumentTypeColors.inkFor(type)`;
    - sections are header (logo, company, type title, number, dates), customer, a
      `LineItemGridSlot` placeholder until Task 18, totals (hidden for DOs), notes and terms,
      signature, and footer with "Page 1 of 1";
    - sections hide according to `DocumentLayoutOptions`.
  - Zoom: `pageZoomProvider` (`StateProvider`-equivalent `Notifier<double>`, 0.5–2.0).
    Ctrl + mouse wheel changes it, and a "Fit width" button sits in the command bar.
  - `DocumentEditorPage` lays out: command bar (Save, Upgrade, Duplicate, Export PDF and Print
    buttons; the actions are wired in Tasks 20 and 22), a breadcrumb slot, then the page canvas and
    the properties pane slot.
    - It shows "This document no longer exists" with a "Back to <plural>" link on
      `DocumentNotFoundException`.

- [ ] **Step 1:** Write failing tests:
  - `'visibleColumns hides pricing for delivery orders'`;
  - `'mmToLogicalPixels(210) ≈ 793.7'`;
  - `'page renders company name, number and customer'`;
  - `'committing customer name calls updateCustomerDetails'`;
  - `'hidden notes block when showNotes false'`;
  - `'delivery order page has no totals section'`;
  - `'missing document shows no-longer-exists message'`.
- [ ] **Step 2:** Run the tests. Expected: FAIL.
- [ ] **Step 3:** Implement.
- [ ] **Step 4 (Verify, flutter-tester):** Run `flutter test test/features/document_editor test/shared` and `flutter analyze`. Expected: pass.
- [ ] **Step 5 (Commit):** `git commit -m "feat: add A4 document page view with inline fields"`

### Task 18: Inline line-item grid (keyboard and focus)
**Agent:** flutter-architect

**Files:**
- Create: `lib/features/document_editor/line_item_grid/line_item_grid.dart`, `line_item_row.dart`, `grid_cell_address.dart`, `grid_focus_controller.dart`, `grid_shortcuts.dart`
- Modify: `lib/features/document_editor/document_page/document_page_view.dart` (replace the slot)
- Test: `test/features/document_editor/line_item_grid_test.dart`, `grid_focus_controller_test.dart`

**Interfaces:**
- Consumes: the controller's line intents, `DocumentPageMetrics.visibleColumns`, `parseMoneyInput`, `parseQuantityInput`, `parsePercentInput`, the formatters, `DeliveryProgressCalculator` (for DO hints).
- Produces:
  - `@immutable class GridCellAddress { final String lineItemId; final LineItemColumn column; }`
  - `class GridFocusController`:
    - pure Dart, unit-testable;
    - `GridCellAddress? next(GridCellAddress from, List<String> lineIds, List<LineItemColumn> editableColumns)`,
      `previous(...)` and `below(...)`;
    - returns `null` at the edges, so the caller decides whether to add a row.
  - `LineItemGrid({required String documentId})`:
    - one focusable cell per editable column (description, unit, quantity, unitPrice, discount);
    - index and amount are read-only;
    - the description is multi-line and grows the row; long text wraps.
  - Keys:
    - Tab and Shift+Tab move to the next or previous cell, wrapping across rows;
    - Enter (single-line cells) moves down, and on the last row inserts a row and focuses its
      description;
    - Ctrl+Enter inserts a row below and focuses it;
    - Ctrl+Delete removes the row and focuses the same column on the neighbouring row;
    - Alt+↑ and Alt+↓ move the row and keep focus on it.
  - Number cells:
    - show the formatted value; on focus they show the raw editable text;
    - on blur they parse. A `null` result keeps the previous value and shows an error outline in
      `Theme.colorScheme.error` with tooltip "Enter a number".
  - Each row has a hover menu (`MenuAnchor`): "Insert row above", "Insert row below", "Duplicate row"
    and "Delete row", plus a drag handle (`ReorderableListView` with `buildDefaultDragHandles: false`).
  - "+ Add item" below the last row.
  - For a DO row whose quantity exceeds what remains, a soft hint below the quantity:
    "Only {remaining} left to deliver".
  - Read-only when locked: no menus, handles or add row.

- [ ] **Step 1:** Write failing tests:
  - `GridFocusController`:
    - `'Tab order wraps to next row'`;
    - `'next on the last cell returns null'`;
    - `'below on the last row returns null'`.
  - Widget tests:
    - `'Tab moves focus from description to unit'`;
    - `'Enter on last row quantity adds a row and focuses its description'`;
    - `'Ctrl+Enter inserts below'`;
    - `'Ctrl+Delete removes row and keeps focus in grid'`;
    - `'Alt+Down moves row down'`;
    - `'typing abc in price keeps old value and shows Enter a number'`;
    - `'typing 1,234.50 in price stores 123450'`;
    - `'multi-line description of 2000 chars wraps without overflow errors'`;
    - `'locked document shows no add-item row'`;
    - `'delivery over-quantity shows remaining hint'`.
- [ ] **Step 2:** Run the tests. Expected: FAIL.
- [ ] **Step 3:** Implement. Keep one `FocusNode` per cell, keyed by `GridCellAddress` and disposed when its row is removed. Use `Shortcuts` + `Actions` with intents in `grid_shortcuts.dart`.
- [ ] **Step 4 (Verify, flutter-tester):** Run `flutter test test/features/document_editor` and `flutter analyze`. Expected: pass.
- [ ] **Step 5 (Commit):** `git commit -m "feat: add keyboard-driven inline line item grid"`

### Task 19: Properties pane, locked banner, unsaved-changes guard
**Agent:** flutter-coder

**Files:**
- Create: `lib/features/document_editor/properties_pane/*.dart`, `locked_document_banner.dart`, `unsaved_changes_guard.dart`
- Modify: `document_editor_page.dart`
- Test: `test/features/document_editor/properties_pane_test.dart`, `locked_document_banner_test.dart`, `unsaved_changes_guard_test.dart`

**Interfaces:**
- Consumes: controller intents, `settingsControllerProvider` (for the reset), `documentChainProvider` (Task 20; until then the banner takes the child summary as a parameter).
- Produces:
  - **`PropertiesPane({required String documentId})`:**
    - 300 px wide and collapsible, with the toggle in the command bar;
    - sections "Document", "Header & footer", "Pricing & currency" and "Signature";
    - each section ends with a "Reset to defaults" button that calls
      `resetSectionToDefaults(DocumentSection.x)`;
    - in the Pricing section, tax rate and currency fields use `parsePercentInput` and validate
      inline.
  - **`LockedDocumentBanner({required BusinessDocument document, required DocumentSummary? createdFrom})`:**
    - text: "This {displayName lowercase} is locked because {createdFrom.documentNumber} was created
      from it";
    - buttons "Duplicate as new draft" and "Open {number}".
  - **`UnsavedChangesGuard`:**
    - wraps the editor in a `PopScope`, plus a window close handler on Windows
      (`windowManager.setPreventClose(true)` and `onWindowClose`);
    - when the status is `pending` it calls `saveNow()` and then proceeds;
    - when the status is `failed` it shows the dialog "Save changes before leaving?" with the
      buttons "Retry save", "Leave without saving" and "Cancel".
  - **Narrow layouts (< 900 px):** the pane opens as a bottom sheet from a "Properties" button.

- [ ] **Step 1:** Write failing tests:
  - `'Reset to defaults on pricing restores settings pricing'`;
  - `'locked banner text names the created document'`;
  - `'leaving with pending edits saves before navigating'`;
  - `'leaving with failed save shows dialog'`;
  - `'below 900px properties open in a bottom sheet'`.
- [ ] **Step 2:** Run the tests. Expected: FAIL.
- [ ] **Step 3:** Implement.
- [ ] **Step 4 (Verify, flutter-tester):** Run `flutter test test/features/document_editor` and `flutter analyze`. Expected: pass.
- [ ] **Step 5 (Commit):** `git commit -m "feat: add properties pane, locked banner and unsaved changes guard"`

---

## Milestone 7: chain

### Task 20: Chain breadcrumb, editor commands, shortcuts
**Agent:** flutter-coder

**Files:**
- Create: `lib/features/document_editor/chain_breadcrumb/chain_breadcrumb.dart`, `document_chain_provider.dart`
- Modify: `document_editor_page.dart`, `locked_document_banner.dart`
- Test: `test/features/document_editor/chain_breadcrumb_test.dart`, `document_editor_commands_test.dart`

**Interfaces:**
- Consumes: `watchDocumentChain`, `DocumentCommands`, `findUpgradeBlocker`.
- Produces:
  - `documentChainProvider`: a family `StreamProvider<DocumentChain>` keyed by `chainId`.
  - `ChainBreadcrumb({required DocumentChain chain, required String currentDocumentId})`:
    - chips tinted per `DocumentTypeColors`, separated by "›";
    - the current chip uses semibold text and an ink border;
    - several DOs collapse into a dropdown chip ("DO-2026-0003 ▾") listing every DO;
    - a missing next stage shows a "+ Sales order" or "+ Delivery order" chip when
      `findUpgradeBlocker` is null, and tapping it upgrades and navigates;
    - every DO shows "+ Delivery order" while the SO has remaining quantities.
  - Command bar wiring:
    - Save calls `saveNow`;
    - "Upgrade to <next>" is disabled with a tooltip giving the blocker;
    - "Duplicate as new draft" and "Delete" (drafts only) are wired.
  - Shortcuts: Ctrl+S save, Ctrl+Shift+U upgrade, Ctrl+N new document of the same type.
  - The banner reads `createdFrom` from the chain.

- [ ] **Step 1:** Write failing tests:
  - `'breadcrumb shows QT › SO › DO dropdown with two DOs'`;
  - `'current chip is emphasised'`;
  - `'standalone quotation shows + Sales order chip'`;
  - `'tapping + Sales order upgrades and navigates to new document'`;
  - `'Upgrade button disabled with blocker tooltip when chain has SO'`;
  - `'Ctrl+S calls saveNow'`.
- [ ] **Step 2:** Run the tests. Expected: FAIL.
- [ ] **Step 3:** Implement.
- [ ] **Step 4 (Verify, flutter-tester):** Run `flutter test` and `flutter analyze`. Expected: pass.
- [ ] **Step 5 (Commit):** `git commit -m "feat: add chain breadcrumb and editor commands"`

---

## Milestone 8: PDF

### Task 21: DocumentPdfBuilder with pagination
**Agent:** flutter-architect

**Files:**
- Create: `lib/features/pdf_export/document_pdf_builder.dart`, `pdf_fonts.dart`
- Test: `test/features/pdf_export/document_pdf_builder_test.dart`

**Interfaces:**
- Consumes: `BusinessDocument`, `DocumentPageMetrics` (`visibleColumns`, margins, flex ratios), `DocumentTotalsCalculator`, the formatters.
- Produces:
  - `class PdfFontSet`, with `static Future<PdfFontSet> load()`. It reads the IBM Plex `.ttf`
    files with `rootBundle` into `pw.Font.ttf`.
  - `class DocumentPdfBuilder`:
    - constructor: `DocumentPdfBuilder({required PdfFontSet fonts, DocumentTotalsCalculator totalsCalculator = const DocumentTotalsCalculator()})`;
    - `Future<Uint8List> build(BusinessDocument document, {required Map<String, Uint8List> imagesByAssetId})`.
  - Layout, using `pw.MultiPage`:
    - A4 page with 18 mm margins;
    - a 4 pt stage band on every page;
    - header on page 1 only;
    - the item table repeats its column header on each page;
    - totals, notes and terms, and signature after the table;
    - a footer on every page with the footer note and "Page x of y";
    - visibility follows `DocumentLayoutOptions` and `showsPricing`;
    - tabular figures (`pw.TextStyle(fontFeatures: [...])` if supported, otherwise Plex digits,
      which are already fixed-width).
  - A single description longer than a page must split across pages (rows may span pages), never
    throw `TooManyPagesException` for realistic input, and never clip.

- [ ] **Step 1:** Write failing tests (extract the text through the `pdf` package's `PdfDocument` parsing, or assert on the widget tree via a builder seam `List<pw.Widget> buildContent(...)`):
  - `'builds a non-empty PDF starting with %PDF'`;
  - `'60 lines produce more than one page'`;
  - `'content includes document number and customer name'`;
  - `'delivery order PDF contains no currency symbol'`;
  - `'a 2000-character multi-line description builds without exception'`;
  - `'hidden signature is absent'`.
- [ ] **Step 2:** Run the tests. Expected: FAIL.
- [ ] **Step 3:** Implement. Load the fonts in tests with `TestWidgetsFlutterBinding.ensureInitialized()`.
- [ ] **Step 4 (Verify, flutter-tester):** Run `flutter test test/features/pdf_export` and `flutter analyze`. Expected: pass.
- [ ] **Step 5 (Commit):** `git commit -m "feat: add paginated PDF builder"`

### Task 22: PDF export service and wiring
**Agent:** flutter-coder

**Files:**
- Create: `lib/features/pdf_export/pdf_export_service.dart`
- Modify: `document_editor_page.dart`, `document_list_page.dart`
- Test: `test/features/pdf_export/pdf_export_service_test.dart`

**Interfaces:**
- Consumes: `DocumentPdfBuilder`, `assetRepositoryProvider`, `DocumentValidator`, `printing`, `file_picker`.
- Produces:
  - `class PdfExportService`, via `pdfExportServiceProvider`:
    - `String suggestedFileName(BusinessDocument document)`: `"<number> <customerName>.pdf"`.
      Characters `<>:"/\|?*` and control characters are replaced by `-`, whitespace is collapsed, and
      the name drops the customer when it's empty. It's capped at 120 characters.
    - `Future<void> printDocument(BusinessDocument)`: `Printing.layoutPdf`.
    - `Future<PdfExportOutcome> exportDocument(BusinessDocument)`:
      - Windows: `FilePicker.platform.saveFile(fileName:, type: FileType.custom, allowedExtensions: ['pdf'], bytes:)`;
      - Android: `Printing.sharePdf`;
      - web: `Printing.sharePdf`, which triggers a download;
      - returns `enum PdfExportOutcome { exported, cancelled }`.
  - Before exporting, when validation issues exist, a dialog titled "Export with issues?" lists the
    `message`s, with the buttons "Export anyway" and "Cancel".
  - Ctrl+P runs Export PDF, and the list context menu item "Export PDF" is enabled.
  - A success shows the status bar message "Exported <fileName>".

- [ ] **Step 1:** Write failing tests:
  - `'suggestedFileName sanitises'`: `QT-2026-0001` with customer `A/B: "Co"` gives `'QT-2026-0001 A-B- -Co-.pdf'`;
  - `'empty customer uses number only'`;
  - `'long names are capped at 120 chars ending in .pdf'`;
  - widget test: `'export with issues shows dialog listing messages'`.
- [ ] **Step 2:** Run the tests. Expected: FAIL.
- [ ] **Step 3:** Implement.
- [ ] **Step 4 (Verify, flutter-tester):** Run `flutter test`, `flutter analyze`, `flutter build windows --debug` and `flutter build web`. Expected: pass.
- [ ] **Step 5 (Commit):** `git commit -m "feat: add PDF export, print and save"`

---

## Milestone 9: polish

### Task 23: Narrow layouts, dark theme, end-to-end QA
**Agent:** flutter-coder (load `frontend-design:frontend-design`)

**Files:**
- Modify: shell, list, editor and settings widgets as needed
- Create: `integration_test/document_flow_test.dart`
- Modify: `pubspec.yaml` (dev dependency `integration_test` from the SDK)

**Interfaces:**
- Consumes: everything.
- Produces:
  - **Below 600 px:** the page scales to the width (`FittedBox` on the page width) and the grid
    scrolls horizontally inside the page.
  - **Dark theme:** the dark theme applies the dark tokens across the chrome while the page stays
    white.
  - **Appearance setting:** `appearance` is wired to `themeModeProvider`.
  - **Focus rings:** visible keyboard focus rings everywhere (2 px `action`).
  - **Integration test:** walks the whole flow:
    - create a quotation, set the customer and add two items;
    - upgrade to a sales order and confirm the quotation is locked;
    - create two partial delivery orders and confirm the remaining quantities;
    - navigate through the breadcrumb;
    - build a PDF.

- [ ] **Step 1:** Write `integration_test/document_flow_test.dart` with the flow above. It uses in-memory repository overrides and asserts the breadcrumb chips, the "Locked" status and the remaining hint.
- [ ] **Step 2:** Run `flutter test integration_test -d windows`. Expected: FAIL until the polish is done, or pass immediately; either way, record the result.
- [ ] **Step 3:** Implement the narrow-layout and dark-theme gaps found while running at 1280, 800 and 400 px widths in both themes.
- [ ] **Step 4 (Verify, flutter-tester):**
  - Run `flutter analyze` and `flutter test`.
  - Run `flutter test integration_test -d windows`.
  - Build `flutter build windows`, `flutter build web` and `flutter build apk --debug`.
  - Expected: all pass.
- [ ] **Step 5 (Manual check, orchestrator, then the user):**
  - Run `flutter run -d windows` and walk the integration flow by hand.
  - Repeat on `-d chrome`.
  - Repeat on an Android emulator if one is available.
- [ ] **Step 6 (Commit):** `git commit -m "feat: polish narrow layouts and dark theme; add end-to-end flow test"`
