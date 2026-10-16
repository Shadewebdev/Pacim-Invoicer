# Pacim Invoicer — Design Spec

Date: 2026-10-17
Status: Draft for review

## 1. Purpose

Pacim Invoicer makes it fast to create business documents — Quotations, Sales Orders and Delivery
Orders — and to carry one document forward into the next stage without retyping. It is a desktop-first
Flutter app (Windows first, then Android and web) that feels like a native Windows application.

Success looks like:
- A new document can be filled in directly on an A4 page, including its item rows, with no dialogs.
- A Quotation can be turned into a Sales Order, and a Sales Order into one or more Delivery Orders, in
  one action, with all documents linked and navigable.
- Every document exports to a PDF that matches what was on screen.
- The storage layer can be swapped from local SQLite to Firestore (free Spark plan) without touching
  features or domain code.

## 2. Scope

In scope:
- Document types: Quotation, Sales Order, Delivery Order.
- Upgrading between stages; chain linking and breadcrumb navigation.
- Header/footer content with global defaults in Settings and per-document overrides.
- Inline item grid.
- One listing page per document type.
- PDF export, preview and print.
- Local storage (Drift/SQLite) on Windows, Android and web.
- Light and dark themes.

Out of scope for now:
- Master lists (customers, products). Every value is typed into, and stays inside, the document.
- Multi-company, multi-user and permissions.
- Firestore implementation (designed for, not built).
- Invoices, payments, stock.

## 3. Core concepts and rules

### 3.1 Documents are self-contained snapshots
A document stores every value it displays: company details, customer details, currency, tax, terms,
signature and images. Later changes to Settings never alter existing documents. This guarantees an
old document always reproduces exactly as it was.

### 3.2 Global defaults and per-document overrides
- Settings hold the defaults: company details, logo, address, contact lines, header/footer block toggles,
  currency format, tax label and rate, default terms, footer note, signatory name and title, signature
  image, and the numbering pattern for each type.
- Creating a document copies the current defaults into it.
- Editing a document's header, footer, pricing or signature changes only that document's copy.
- "Reset to defaults" in the editor's properties pane re-copies the current Settings into that
  section of the document.

### 3.3 Chains
- Every document has a `chainId`. A document created standalone starts a new chain (new UUID).
- Shape: at most one Quotation and one Sales Order per chain; a Sales Order can have many Delivery
  Orders (partial deliveries).
- Any type can be created standalone. Upgrading is a convenience, not a required flow.
- Allowed upgrades: Quotation → Sales Order (only if the chain has no Sales Order yet);
  Sales Order → Delivery Order (repeatable).

### 3.4 Upgrade behaviour
1. A new document of the next type is created by copying the source's contents.
2. It gets a new `documentId`, the next number for its type, the same `chainId`, and
   `sourceDocumentId` = the source.
3. Each copied line keeps `sourceLineItemId` pointing at the source line.
4. For a new Delivery Order from a Sales Order, each line's quantity defaults to the remaining quantity:
   Sales Order quantity minus the quantity already delivered on that line by other Delivery Orders in
   the chain (matched by `sourceLineItemId`). Fully delivered lines are omitted.
5. The source is locked (`lockedAt` set). Creating the new document and locking the source happen in
   one transaction.
6. The new document opens in the editor.

### 3.5 Lifecycle and locking
- No explicit "issue" step. A document is editable until a next-stage document is created from it.
- A locked document is read-only. It can still be exported, viewed, duplicated as a new draft, and
  (for a Sales Order) upgraded to further Delivery Orders.
- Only unlocked documents can be deleted. Deleting a document unlocks its source if the source has no
  other documents created from it (in the same transaction).
- Delivering more than the remaining quantity is allowed, with a soft inline hint on the row.

### 3.6 Document numbering
- Each type has a pattern in Settings, for example `QT-{yyyy}-{seq:4}`. Tokens: `{yyyy}`, `{yy}`,
  `{mm}`, `{seq:N}` (zero-padded to N digits). The prefix is free text.
- Counters are per type and increase forever. They don't reset yearly by default; a "Reset yearly"
  option resets `{seq}` when the year changes.
- The number is allocated when the document is created and never changes. Numbers aren't reused
  after deletion.
- Allocation is atomic: a transaction on the counter row now, and on the counter document in Firestore
  later.

### 3.7 Money and quantities
- Amounts are stored as integer minor units (`int` cents) according to the document's currency
  decimal places. Quantities are stored as integers scaled by 1000 (so `2.5` is `2500`).
- Line amount = round_half_up(quantity × unit price × (1 − discount%)).
- Subtotal = sum of line amounts. Tax = round_half_up(subtotal × tax rate). Grand total = subtotal + tax.
  Line discounts are shown as their own column and summed as "Discount" for display.
- Totals are always computed by `DocumentTotalsCalculator`, never stored as the source of truth. The
  stored `grandTotalMinor` column exists only for listing and sorting.
- Delivery Orders show quantities, units and descriptions only. Pricing is kept in the data, so that
  copying it back into a new draft loses nothing, but is hidden on the page and in the PDF.

### 3.8 Currency
`CurrencyFormat`: `currencyCode` (e.g. `MYR`), `symbol` (e.g. `RM`), `decimalPlaces` (0–3),
`symbolPosition` (before/after), `thousandsSeparator` and `decimalSeparator`. The default comes from
Settings and is copied into each document. Each document can edit its own in the Pricing & currency
panel. Changing decimal places on a document re-expresses existing prices at the new precision, with
rounding.

## 4. Data model

All models are immutable (`freezed`) and JSON-serializable (`json_serializable`). Names describe intent.

```
BusinessDocument
  documentId: String (UUID v4)
  documentType: DocumentType { quotation, salesOrder, deliveryOrder }
  documentNumber: String
  chainId: String (UUID v4)
  sourceDocumentId: String?
  lockedAt: DateTime?
  schemaVersion: int
  issueDate: DateTime
  validUntilDate: DateTime?          // Quotation
  deliveryDate: DateTime?            // Delivery Order
  customerReference: String?         // e.g. customer PO number
  companyDetails: CompanyDetails
  customerDetails: CustomerDetails
  layoutOptions: DocumentLayoutOptions
  pricingTerms: PricingTerms
  lineItems: List<LineItem>
  notes: String
  termsAndConditions: String
  footerNote: String
  signatureBlock: SignatureBlock
  createdAt, updatedAt: DateTime

CompanyDetails   { companyName, registrationNumber, addressLines: List<String>, phone, email,
                   website, logoAssetId: String? }
CustomerDetails  { customerName, attentionTo, addressLines, phone, email,
                   deliveryAddressLines (Delivery Order) }
DocumentLayoutOptions { showLogo, showCompanyRegistration, showCustomerReference, showNotes,
                   showTermsAndConditions, showFooterNote, showSignature, showPageNumbers,
                   showDiscountColumn, showUnitColumn }
PricingTerms     { currencyFormat: CurrencyFormat, taxLabel, taxRatePercentScaled (×100: 800 = 8%),
                   isTaxEnabled }
LineItem         { lineItemId (UUID), sourceLineItemId?, description, unit, quantityScaled (×1000),
                   unitPriceMinor, discountPercentScaled (×100) }
SignatureBlock   { signatoryName, signatoryTitle, signatureAssetId?, signatureCaption
                   (e.g. "Authorised signature", "Received by") }

DocumentSettings (global, a single record)
  companyDetails, layoutOptionsByType: Map<DocumentType, DocumentLayoutOptions>,
  pricingTerms, defaultTermsByType, defaultFooterNote, signatureBlockByType,
  numberingRuleByType: Map<DocumentType, DocumentNumberingRule { pattern, resetsYearly }>

DocumentSummary (listing row projection)
  documentId, documentType, documentNumber, chainId, sourceDocumentId, customerName,
  issueDate, grandTotalMinor, currencyCode, isLocked, updatedAt

DocumentChain (breadcrumb)
  chainId, quotation: DocumentSummary?, salesOrder: DocumentSummary?,
  deliveryOrders: List<DocumentSummary> (ordered by documentNumber)
```

`schemaVersion` starts at 1. `DocumentPayloadMigrator` upgrades stored JSON from older versions on
read.

## 5. Architecture

Feature-first layout over a pure domain core. Dependencies point inward:
features → domain and data interfaces. Data implementations depend on domain only.

```
lib/
  main.dart
  app/
    pacim_invoicer_app.dart        MaterialApp.router, themes
    app_router.dart                go_router routes
    theme/                         color tokens, typography, component themes
    shell/                         title bar, navigation sidebar, status bar, AppShell
  domain/
    models/                        freezed models (section 4)
    services/
      document_totals_calculator.dart
      document_upgrade_service.dart
      delivery_progress_calculator.dart
      document_number_formatter.dart
      document_factory.dart         new standalone document from settings
    exceptions/                    DocumentNotFoundException, DocumentLockedException,
                                   InvalidUpgradeException, StorageWriteException
  data/
    repositories/                  abstract interfaces
      document_repository.dart
      settings_repository.dart
      asset_repository.dart
      number_sequence_repository.dart
    local/                         Drift implementations
      pacim_database.dart          tables + migrations
      drift_document_repository.dart, drift_settings_repository.dart,
      drift_asset_repository.dart, drift_number_sequence_repository.dart
    payload/document_payload_migrator.dart
    repository_providers.dart      the single place implementations are chosen
  features/
    document_list/                 DocumentListPage, controller, table widgets
    document_editor/               DocumentEditorPage, DocumentEditorController,
                                   document_page/ (A4 canvas widgets), line_item_grid/,
                                   properties_pane/, chain_breadcrumb/
    settings/                      SettingsPage, sections
    pdf_export/                    DocumentPdfBuilder, PdfExportService
  shared/
    document_page_metrics.dart     page size, margins, column widths (screen + PDF)
    formatting/                    money, quantity, date formatters
```

### 5.1 Repository interfaces

```dart
abstract interface class DocumentRepository {
  Stream<List<DocumentSummary>> watchDocumentSummaries(DocumentListQuery query);
  Future<BusinessDocument> getDocument(String documentId);
  Stream<BusinessDocument> watchDocument(String documentId);
  Stream<DocumentChain> watchDocumentChain(String chainId);
  Future<List<BusinessDocument>> getDocumentsInChain(String chainId);
  Future<void> saveDocument(BusinessDocument document);     // throws DocumentLockedException
  Future<void> saveUpgrade({required BusinessDocument lockedSource,
                            required BusinessDocument createdDocument}); // one transaction
  Future<void> deleteDocument(String documentId);           // unlocked only
}

abstract interface class NumberSequenceRepository {
  Future<int> allocateNextSequence(DocumentType type, {required int year, required bool resetsYearly});
}

abstract interface class AssetRepository {
  Future<String> storeImage(Uint8List bytes);   // returns SHA-256 assetId; idempotent
  Future<Uint8List?> loadImage(String assetId);
}

abstract interface class SettingsRepository {
  Stream<DocumentSettings> watchSettings();
  Future<void> saveSettings(DocumentSettings settings);
}
```

`DocumentListQuery`: type, search text (number or customer), date range, sort field and direction,
page size and cursor.

### 5.2 Local storage (Drift)
- Tables:
  - `documents`: the `DocumentSummary` columns plus `payloadJson` and `schemaVersion`. Indexes on
    (type, issueDate), (chainId), (type, documentNumber).
  - `number_sequences`: (type, year) → lastSequence.
  - `assets`: assetId → bytes, mimeType.
  - `settings`: a single row holding JSON.
- Platforms: native SQLite via `drift_flutter` on Windows and Android, and Drift WASM (IndexedDB/OPFS)
  on web.
- `saveDocument` refuses writes when the stored row is locked.

### 5.3 Future Firestore (Spark plan, no billing, no Cloud Functions)
The design needs no server code:
- Collections:
  - `documents/{documentId}`: summary fields top-level plus a `payload` map.
  - `counters/{type_year}`.
  - `assets/{sha256}`: base64 image.
  - `settings/default`.
- Numbering: a client-side `runTransaction` on the counter document.
- Upgrades: a client-side transaction that writes the new document and sets `lockedAt` on the source.
- Images: Cloud Storage isn't available on Spark for new projects, so images live in Firestore. They
  are downscaled on import (longest edge ≤ 600 px, re-encoded to PNG/JPEG ≤ ~250 KB), which keeps
  them well under the 1 MiB document limit. Downscaling happens in `ImageImportService` for both
  storage backends, so documents look identical either way.
- Quotas (50k reads and 20k writes per day): autosave debounces about 2 s after the last edit and also
  saves on leaving the document. Listings use `limit()` pages over top-level fields. Chains load with
  `where('chainId', ==)`.
- Security: Firebase Auth plus security rules restricting access to signed-in users. The lock check
  is enforced in the rules too (`resource.data.lockedAt == null` for updates).
- Switching backends is one change in `repository_providers.dart`. The repository contract test suite
  (section 9) runs against the Firestore emulator before switching.

## 6. State management and data flow

- Riverpod (`flutter_riverpod`, code-free `Notifier`/`AsyncNotifier` classes).
- `documentRepositoryProvider` and its siblings are defined in `repository_providers.dart`.
- `documentListControllerProvider(DocumentType)` holds the query (search, filter, sort) and exposes
  `AsyncValue<List<DocumentSummary>>` from `watchDocumentSummaries`.
- `documentEditorControllerProvider(documentId)`:
  - Holds `DocumentEditorState { document: BusinessDocument, saveStatus: SaveStatus
    { saved, pending, saving, failed }, validationIssues }`.
  - Every edit is a named intent method: `updateCustomerName`, `updateLineItemQuantity(lineItemId, …)`,
    `insertLineItemAfter`, `removeLineItem`, `moveLineItem`, `resetSectionToDefaults(section)`, and so on.
  - Each method produces a new immutable document and schedules a debounced save.
  - The editor and the PDF both render from `state.document`.
- `documentChainProvider(chainId)` streams the breadcrumb.
- `DocumentUpgradeService.createNextStage(source, chainDocuments, settings)` is pure and returns
  `(lockedSource, createdDocument)`. The controller allocates the number, then calls
  `saveUpgrade`, then navigates.

## 7. User interface

### 7.1 Visual system — "the duplicate book"
Quotations, sales orders and delivery orders traditionally came in carbonless multi-part books
(white, yellow and pink copies). Each type gets a copy-paper tint, used only to identify the type:
breadcrumb chips, list badges, and a 4 px band down the left edge of the page. Everything else is quiet,
neutral Windows-like chrome. The memorable element is editing directly on a real A4 page, where what you
see is the PDF.

Color tokens (light):
| Token | Hex | Use |
|---|---|---|
| chrome | `#ECEEF1` | title bar, sidebar, command bar |
| surface | `#F7F8FA` | panes, tables, canvas backdrop |
| paper | `#FFFFFF` | the A4 page |
| ink | `#1E2633` | primary text |
| rule | `#D5D9E0` | dividers, table lines, field outlines |
| action | `#2A5BD7` | primary buttons, focus rings, selection |
| quotationTint / quotationInk | `#DCE6FA` / `#2E56B8` | |
| salesOrderTint / salesOrderInk | `#FBEFB8` / `#7C6100` | |
| deliveryOrderTint / deliveryOrderInk | `#F7D9E0` / `#A23B5A` | |

Dark theme: chrome `#1D2128`, surface `#252A32`, ink `#E6E9EE`, rule `#3A404A`, action `#7FA2F5`.
Tints are dimmed to about 30% opacity. The page stays white.

Typography:
- UI text: Segoe UI Variable on Windows (system font), falling back to bundled Noto Sans on
  Android and web.
- Document page and PDF: bundled IBM Plex Sans (OFL licence) with tabular figures. The same font in both
  places guarantees the page matches the PDF.
- Scale: 12 caption, 13 body and table, 14 field, 16 pane title, 20 page title.
- Sentence case everywhere, no all-caps labels.

Density and shape: 32 px table rows and controls, 4 px corner radius on controls, 0 radius on the
page, no card shadows except a single soft shadow under the page. Hover states, visible focus
rings, right-click context menus, and tooltips that show shortcuts.

### 7.2 App shell
```
┌ [icon] Pacim Invoicer ─────────────────────────────── ─ □ ✕ ┐  custom title bar (window_manager)
│ Quotations      │ command bar (page-specific actions)        │
│ Sales orders    ├────────────────────────────────────────────┤
│ Delivery orders │ page content                               │
│                 │                                            │
│ Settings        │                                            │
├─────────────────┴────────────────────────────────────────────┤
│ status bar: save state · item counts                         │
└──────────────────────────────────────────────────────────────┘
```
Sidebar width: 220 px on wide windows, collapsing to a 56 px rail below 900 px and a drawer below
600 px.

### 7.3 Listing page (one per type)
- Command bar: New \<type\>, search box (Ctrl+F), date range filter, refresh.
- Table columns: number, customer, issue date, total (hidden for Delivery Orders), status (Draft or
  Locked), chain (tinted chips of the other documents in the chain).
- Click a column header to sort. The table loads more rows as you scroll. Double-click or Enter opens a
  document.
- Context menu: Open, Upgrade to \<next\>, Duplicate as new draft, Export PDF, Delete (drafts only,
  with confirmation).
- Empty state: "No quotations yet", with a "New quotation" button.

### 7.4 Document editor
```
│ [Save] [Upgrade to delivery order] [Duplicate] [Export PDF] [Print]    │
│ (QT-2026-0004) › (SO-2026-0002) › (DO-2026-0003 ▾)                     │
├──────────────────────────────────────────────┬─────────────────────────┤
│ ▌┌───────────── A4 page ──────────────────┐  │ Document                │
│ ▌│ [logo] Company / address    QUOTATION  │  │ Header & footer         │
│ ▌│                       No. QT-2026-0004 │  │ Pricing & currency      │
│ ▌│ Bill to (editable)    Date, Valid until│  │ Signature               │
│ ▌│ #  Description  Unit  Qty  Price  Disc  Amount                │      │
│ ▌│ 1  ...inline cells...                  │  │ [Reset to defaults]     │
│ ▌│ + Add item                             │  │                         │
│ ▌│                 Subtotal / Tax / Total │  │                         │
│ ▌│ Notes · Terms        Signature block   │  │                         │
│ ▌│ Footer note                 Page 1 of 1│  │                         │
│ ▌└────────────────────────────────────────┘  │                         │
```
- Breadcrumb: tinted chips for the chain. The current document is emphasised. Delivery Orders appear
  as a dropdown chip when there are several. Chips that don't exist yet show a "+" (for example
  "+ Sales order" on a quotation) as an upgrade shortcut.
- The page is rendered at 100% by default, with zoom (Ctrl + mouse wheel, fit-width button).
  Text fields on the page look like printed text until hovered or focused, then show an outline.
- Line item grid:
  - Each cell is a text field.
  - Tab and Shift+Tab move between cells. Enter moves down a row and, on the last row, adds a row.
  - Ctrl+Enter inserts a row below. Ctrl+Delete removes the row. Alt+↑/↓ reorders.
  - Rows can also be reordered by dragging the handle.
  - Number cells accept free typing and format on blur.
  - Each row has a hover menu: insert above, insert below, duplicate, delete.
- Properties pane (300 px, collapsible):
  - Document: dates and customer reference.
  - Header & footer: content and block toggles.
  - Pricing & currency: currency format, tax.
  - Signature: name, title, caption, image.
  - Each section has "Reset to defaults".
- Locked documents: a banner reads "This quotation is locked because SO-2026-0002 was created from it",
  with "Duplicate as new draft" and "Open SO-2026-0002" buttons. All fields are read-only.
- Shortcuts: Ctrl+N new document of the current type, Ctrl+S save now, Ctrl+P export PDF,
  Ctrl+Shift+U upgrade.

### 7.5 Settings page
Left sub-navigation: Company, Header & footer, Pricing & currency, Signature, Numbering, Appearance
(light, dark or system). Header & footer, signature and numbering are configured per document type,
using tabs tinted by type. A live mini preview of the page header shows on the right. A note reads:
"Changes apply to new documents. Existing documents keep their own copy."

### 7.6 Narrow layouts (Android and small windows)
The sidebar becomes a rail or drawer, the properties pane becomes a bottom sheet, the page scales to
fit the width, and the item grid scrolls horizontally inside the page.

## 8. PDF export
- `DocumentPdfBuilder.build(BusinessDocument, Map<String, Uint8List> images) → Future<Uint8List>`,
  using the `pdf` package widgets.
- Shares `DocumentPageMetrics` (A4, 18 mm margins, column width ratios) and the visibility rules from
  `DocumentLayoutOptions` with the on-screen page. Embeds IBM Plex Sans.
- Multi-page: the item table splits across pages and repeats its header row. The footer and
  "Page x of y" print on every page. Totals, signature and terms follow the table.
- `PdfExportService` handles output through the `printing` package:
  - preview and print dialog;
  - "Save as PDF" through a save dialog (`file_picker`) on Windows;
  - the share sheet on Android;
  - a browser download on web.
- Default file name: `<documentNumber> <customerName>.pdf`, sanitised.

## 9. Errors, validation and testing

Errors:
- Typed domain exceptions (section 5).
- An autosave failure sets `saveStatus = failed`, and the status bar shows "Couldn't save — Retry".
- Leaving or closing with unsaved or failed changes asks "Save changes before leaving?".
- A document that can't be found shows "This document no longer exists", with a link back to the list.

Validation is non-blocking. Issues are listed in the status bar and marked on fields:
- missing customer name;
- no line items;
- a line with zero quantity;
- a delivery quantity above what remains.

Export warns about these issues but allows continuing.

Testing (`flutter_test`, plus `mocktail` for fakes where needed):
- **Unit (domain):**
  - totals and rounding, including half-up and different currency decimal places;
  - discount and tax;
  - upgrade copying, line linking and lock;
  - delivery remaining across multiple Delivery Orders;
  - number pattern formatting and yearly reset;
  - payload migration.
- **Repository contract suite:**
  - The same tests run against any `DocumentRepository`, `NumberSequenceRepository`,
    `AssetRepository` and `SettingsRepository` implementation.
  - Coverage: saving and loading, lock enforcement, atomic upgrade, unique sequential numbers, chain
    queries, list filtering and sorting.
  - Runs against in-memory Drift now and the Firestore emulator later.
- **Widget tests:**
  - line item grid keyboard editing (Tab, Enter, Ctrl+Enter, Alt+↑/↓);
  - the breadcrumb with several Delivery Orders;
  - locked-document read-only behaviour;
  - listing sorting and search.
- **PDF smoke tests:** the PDF builds, a 60-line document produces more than one page, and key text is
  present.
- **Manual check on Windows, Android and web** before each milestone.

## 10. Packages

All from verified publishers or the Flutter/Dart teams, and widely used:

| Purpose | Package |
|---|---|
| State | `flutter_riverpod` |
| Routing | `go_router` (flutter.dev) |
| Models | `freezed`, `freezed_annotation`, `json_serializable`, `json_annotation`, `build_runner` |
| Storage | `drift`, `drift_flutter`, `drift_dev` (dev) |
| PDF | `pdf`, `printing` |
| Files | `file_picker` |
| Window chrome (Windows) | `window_manager` |
| IDs / hashing | `uuid`, `crypto` (dart.dev) |
| Image downscaling | `image` |
| Formatting | `intl` (dart.dev) |
| Paths | `path_provider` (flutter.dev) |
| Tests | `flutter_test`, `mocktail` |
| Later | `cloud_firestore`, `firebase_auth`, `firebase_core` (firebase.google.com) |

Fonts (IBM Plex Sans, Noto Sans) are bundled as assets, not fetched at runtime.

## 11. Coding conventions
- Names say what a thing is or does: `allocateNextSequence`, `remainingQuantityForLine`,
  `DocumentEditorController`. No abbreviations beyond the domain's own (QT, SO, DO appear only in number
  patterns and the UI).
- Small files with one purpose each. Widgets stay presentational, and controllers own behaviour.
- The domain layer has no Flutter or IO imports.
- Immutable models, with all mutation through named controller intents.
- `flutter_lints` with zero warnings; `dart format` enforced.

## 12. Milestones (for the implementation plan)
1. Project scaffold, theme tokens, app shell, routing.
2. Domain models and services, with unit tests.
3. Drift repositories and the contract test suite.
4. Settings page.
5. Listing pages.
6. Document editor: page canvas, inline grid, properties pane, autosave.
7. Upgrade flow, chain breadcrumb, locking.
8. PDF export.
9. Narrow-layout polish (Android and web), dark theme, final QA.
