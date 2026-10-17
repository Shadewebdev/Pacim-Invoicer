import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/shell/status_bar_message_provider.dart';
import '../../data/repositories/document_repository.dart';
import '../../data/repository_providers.dart';
import '../../domain/exceptions/document_exceptions.dart';
import '../../domain/models/business_document.dart';
import '../../domain/models/company_details.dart';
import '../../domain/models/currency_format.dart';
import '../../domain/models/customer_details.dart';
import '../../domain/models/document_layout_options.dart';
import '../../domain/models/document_type.dart';
import '../../domain/models/line_item.dart';
import '../../domain/models/pricing_terms.dart';
import '../../domain/models/signature_block.dart';
import '../../domain/services/document_factory.dart';
import '../../domain/services/document_totals_calculator.dart';
import 'document_editor_state.dart';

const Duration _autosaveDelay = Duration(seconds: 2);
const String _saveFailedMessage = "Couldn't save — Retry";

/// Holds one document being edited, saves it 2 seconds after the last edit,
/// keeps its validation issues current and ignores edits once it is locked.
class DocumentEditorController extends AsyncNotifier<DocumentEditorState> {
  DocumentEditorController(this.documentId);

  final String documentId;

  late DocumentRepository _repository;
  late DateTime Function() _clock;
  StreamSubscription<BusinessDocument>? _storedDocumentSubscription;
  Timer? _autosaveTimer;

  /// True while saving is held back, for example during a delete.
  bool _isAutosaveHeld = false;
  Future<void> _lastSave = Future<void>.value();

  /// The last state published, readable while the provider is disposing.
  DocumentEditorState? _latestState;

  /// Counts edits, so a save can tell whether the user typed while it ran.
  int _editCount = 0;

  /// The document as last loaded from or written to storage.
  BusinessDocument? _lastSavedDocument;

  @override
  Future<DocumentEditorState> build() async {
    _repository = ref.read(documentRepositoryProvider);
    _clock = ref.read(clockProvider);
    ref.onDispose(_onDispose);

    final document = await _repository.getDocument(documentId);
    final loaded = await _loadDeliveryContext(document);
    _lastSavedDocument = loaded.document;
    _storedDocumentSubscription = _repository
        .watchDocument(documentId)
        .listen(_onStoredDocument, onError: (Object _) {});
    return loaded;
  }

  // Intents. Each is a no-op on a locked document.

  void updateIssueDate(DateTime? date) => _edit(
    (document) => document.copyWith(issueDate: date ?? document.issueDate),
  );

  void updateValidUntilDate(DateTime? date) =>
      _edit((document) => document.copyWith(validUntilDate: date));

  void updateDeliveryDate(DateTime? date) =>
      _edit((document) => document.copyWith(deliveryDate: date));

  void updateCustomerReference(String? reference) =>
      _edit((document) => document.copyWith(customerReference: reference));

  void updateCompanyDetails(CompanyDetails companyDetails) =>
      _edit((document) => document.copyWith(companyDetails: companyDetails));

  void updateCustomerDetails(CustomerDetails customerDetails) =>
      _edit((document) => document.copyWith(customerDetails: customerDetails));

  void updateLayoutOptions(DocumentLayoutOptions layoutOptions) =>
      _edit((document) => document.copyWith(layoutOptions: layoutOptions));

  void updatePricingTerms(PricingTerms pricingTerms) =>
      _edit((document) => document.copyWith(pricingTerms: pricingTerms));

  /// Replaces the currency format. When the decimal places change, every unit
  /// price is re-expressed in the new minor unit so it keeps its value.
  void updateCurrencyFormat(CurrencyFormat currencyFormat) => _edit((document) {
    final oldPlaces = document.pricingTerms.currencyFormat.decimalPlaces;
    final newPlaces = currencyFormat.decimalPlaces;
    final pricingTerms = document.pricingTerms.copyWith(
      currencyFormat: currencyFormat,
    );
    if (oldPlaces == newPlaces) {
      return document.copyWith(pricingTerms: pricingTerms);
    }
    final newScale = BigInt.from(10).pow(newPlaces);
    final oldScale = BigInt.from(10).pow(oldPlaces);
    return document.copyWith(
      pricingTerms: pricingTerms,
      lineItems: [
        for (final line in document.lineItems)
          line.copyWith(
            unitPriceMinor: roundHalfUpDivide(
              BigInt.from(line.unitPriceMinor) * newScale,
              oldScale,
            ),
          ),
      ],
    );
  });

  void updateNotes(String notes) =>
      _edit((document) => document.copyWith(notes: notes));

  void updateTermsAndConditions(String termsAndConditions) => _edit(
    (document) => document.copyWith(termsAndConditions: termsAndConditions),
  );

  void updateFooterNote(String footerNote) =>
      _edit((document) => document.copyWith(footerNote: footerNote));

  void updateSignatureBlock(SignatureBlock signatureBlock) =>
      _edit((document) => document.copyWith(signatureBlock: signatureBlock));

  void updateLineItem(String lineItemId, LineItem Function(LineItem) change) =>
      _edit(
        (document) => document.copyWith(
          lineItems: [
            for (final line in document.lineItems)
              if (line.lineItemId == lineItemId) change(line) else line,
          ],
        ),
      );

  /// Inserts an empty line at [atIndex] (clamped to the list) and returns its
  /// id, or null when the document is locked and nothing changed.
  String? insertLineItem({required int atIndex}) {
    final current = state.value;
    if (current == null || current.isLocked) return null;
    final newLine = LineItem(
      lineItemId: ref.read(idGeneratorProvider).generateId(),
    );
    _edit((document) => _withLineInserted(document, newLine, atIndex));
    return newLine.lineItemId;
  }

  /// Inserts a copy of the line right below it. The copy is a line the user
  /// created, so it does not claim the original's sales order line.
  void duplicateLineItem(String lineItemId) {
    final current = state.value;
    if (current == null || current.isLocked) return;
    final index = current.document.lineItems.indexWhere(
      (line) => line.lineItemId == lineItemId,
    );
    if (index < 0) return;
    final copy = current.document.lineItems[index].copyWith(
      lineItemId: ref.read(idGeneratorProvider).generateId(),
      sourceLineItemId: null,
    );
    _edit((document) => _withLineInserted(document, copy, index + 1));
  }

  void removeLineItem(String lineItemId) => _edit(
    (document) => document.copyWith(
      lineItems: [
        for (final line in document.lineItems)
          if (line.lineItemId != lineItemId) line,
      ],
    ),
  );

  /// Moves a line so it sits at [toIndex] in the resulting list.
  void moveLineItem(String lineItemId, {required int toIndex}) => _edit((
    document,
  ) {
    final lines = [...document.lineItems];
    final fromIndex = lines.indexWhere((line) => line.lineItemId == lineItemId);
    if (fromIndex < 0) return document;
    final moved = lines.removeAt(fromIndex);
    lines.insert(toIndex.clamp(0, lines.length), moved);
    return document.copyWith(lineItems: lines);
  });

  /// Replaces one section with the current global settings.
  Future<void> resetSectionToDefaults(DocumentSection section) async {
    if (state.value == null || state.requireValue.isLocked) return;
    final settings = await ref
        .read(settingsRepositoryProvider)
        .watchSettings()
        .first;
    if (!ref.mounted) return;
    final factory = ref.read(documentFactoryProvider);
    _edit(
      (document) => factory.resetSectionToDefaults(document, section, settings),
    );
  }

  // Lifecycle.

  /// Saves pending edits now instead of waiting for the idle delay.
  Future<void> saveNow() async {
    _autosaveTimer?.cancel();
    final current = state.value;
    if (current == null || current.saveStatus == SaveStatus.saved) return;
    await _enqueueSave();
  }

  /// Completes once every save started so far has finished, whether or not it
  /// succeeded.
  Future<void> whenIdle() => _lastSave.catchError((Object _) {});

  /// Saves again after a failed save.
  Future<void> retrySave() => saveNow();

  /// Drops every edit made since the last save and returns to the last saved
  /// document, so leaving the editor afterwards saves nothing.
  void discardPendingChanges() {
    _autosaveTimer?.cancel();
    final current = state.value;
    final saved = _lastSavedDocument;
    if (current == null || saved == null) return;
    _editCount++;
    _publish(
      _revalidated(
        current.copyWith(document: saved, saveStatus: SaveStatus.saved),
      ),
    );
  }

  /// Stops every save, including the one when the editor closes, until
  /// [releaseAutosave]. Pending edits stay in state. Used while the document
  /// is being deleted, so autosave cannot write it back.
  void holdAutosave() {
    _isAutosaveHeld = true;
    _autosaveTimer?.cancel();
  }

  /// Lets saving resume after [holdAutosave], re-arming autosave when edits
  /// are waiting.
  void releaseAutosave() {
    _isAutosaveHeld = false;
    if (state.value?.saveStatus == SaveStatus.pending) {
      _autosaveTimer?.cancel();
      _autosaveTimer = Timer(_autosaveDelay, () => unawaited(_enqueueSave()));
    }
  }

  // Internals.

  void _publish(DocumentEditorState editorState) {
    _latestState = editorState;
    if (editorState.saveStatus == SaveStatus.saved) {
      _lastSavedDocument = editorState.document;
    }
    state = AsyncData(editorState);
  }

  void _edit(BusinessDocument Function(BusinessDocument) change) {
    final current = state.value;
    if (current == null || current.isLocked) return;
    final changed = change(current.document);
    if (changed == current.document) return;
    _editCount++;
    _publish(
      _revalidated(
        current.copyWith(document: changed, saveStatus: SaveStatus.pending),
      ),
    );
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(_autosaveDelay, () => unawaited(_enqueueSave()));
  }

  BusinessDocument _withLineInserted(
    BusinessDocument document,
    LineItem line,
    int index,
  ) {
    final lines = [...document.lineItems];
    lines.insert(index.clamp(0, lines.length), line);
    return document.copyWith(lineItems: lines);
  }

  DocumentEditorState _revalidated(DocumentEditorState editorState) =>
      editorState.copyWith(
        validationIssues: ref
            .read(documentValidatorProvider)
            .validate(
              editorState.document,
              salesOrder: editorState.salesOrder,
              otherDeliveryOrders: editorState.otherDeliveryOrders,
            ),
      );

  /// Builds a saved state for [document], loading the sales order and the
  /// sibling delivery orders when [document] is a delivery order.
  Future<DocumentEditorState> _loadDeliveryContext(
    BusinessDocument document,
  ) async {
    if (document.documentType != DocumentType.deliveryOrder ||
        document.sourceDocumentId == null) {
      return _revalidated(DocumentEditorState(document: document));
    }
    final chain = await _repository.getDocumentsInChain(document.chainId);
    BusinessDocument? salesOrder;
    final otherDeliveryOrders = <BusinessDocument>[];
    for (final candidate in chain) {
      if (candidate.documentType == DocumentType.salesOrder) {
        salesOrder = candidate;
      } else if (candidate.documentType == DocumentType.deliveryOrder &&
          candidate.documentId != document.documentId) {
        otherDeliveryOrders.add(candidate);
      }
    }
    return _revalidated(
      DocumentEditorState(
        document: document,
        salesOrder: salesOrder,
        otherDeliveryOrders: otherDeliveryOrders,
      ),
    );
  }

  void _onStoredDocument(BusinessDocument stored) {
    final current = state.value;
    if (current == null ||
        current.saveStatus != SaveStatus.saved ||
        stored.updatedAt.isBefore(current.document.updatedAt) ||
        stored == current.document) {
      return;
    }
    unawaited(_adoptStoredDocument(stored));
  }

  Future<void> _adoptStoredDocument(BusinessDocument stored) async {
    final loaded = await _loadDeliveryContext(stored);
    final current = state.value;
    if (!ref.mounted ||
        current == null ||
        current.saveStatus != SaveStatus.saved) {
      return;
    }
    _publish(loaded);
  }

  /// Runs saves one after another so two never overlap.
  Future<void> _enqueueSave() {
    if (_isAutosaveHeld) return Future<void>.value();
    final previous = _lastSave;
    // A failed earlier save must never block the ones after it.
    final saved = previous
        .catchError((Object _) {})
        .then((_) => _saveCurrentDocument());
    _lastSave = saved;
    return saved;
  }

  Future<void> _saveCurrentDocument() async {
    final current = state.value;
    if (!ref.mounted ||
        current == null ||
        current.saveStatus == SaveStatus.saved) {
      return;
    }
    final editCountAtStart = _editCount;
    final toSave = current.document.copyWith(updatedAt: _clock());
    _publish(current.copyWith(saveStatus: SaveStatus.saving));
    try {
      await _repository.saveDocument(toSave);
      if (!ref.mounted) return;
      final latest = state.requireValue;
      _publish(
        editCountAtStart == _editCount
            ? latest.copyWith(document: toSave, saveStatus: SaveStatus.saved)
            : latest,
      );
    } on DocumentLockedException {
      try {
        await _reloadStoredDocument();
      } on Object {
        _markSaveFailed();
      }
    } on Object {
      _markSaveFailed();
    }
  }

  void _markSaveFailed() {
    if (!ref.mounted) return;
    _publish(state.requireValue.copyWith(saveStatus: SaveStatus.failed));
    ref.read(statusBarMessageProvider.notifier).showMessage(_saveFailedMessage);
  }

  /// Drops local edits for a document that was locked elsewhere.
  Future<void> _reloadStoredDocument() async {
    _autosaveTimer?.cancel();
    final stored = await _repository.getDocument(documentId);
    final loaded = await _loadDeliveryContext(stored);
    if (!ref.mounted) return;
    _editCount++;
    _publish(loaded);
  }

  void _onDispose() {
    _autosaveTimer?.cancel();
    unawaited(_storedDocumentSubscription?.cancel());
    final current = _latestState;
    final hasUnsavedEdits =
        current != null &&
        (current.saveStatus == SaveStatus.pending ||
            current.saveStatus == SaveStatus.failed);
    if (current == null || !hasUnsavedEdits || _isAutosaveHeld) return;
    final toSave = current.document.copyWith(updatedAt: _clock());
    final repository = _repository;
    // Nothing is left to report to once the provider is gone.
    unawaited(
      _lastSave
          .then((_) => repository.saveDocument(toSave))
          .catchError((Object _) {}),
    );
  }
}

final documentEditorControllerProvider =
    AsyncNotifierProvider.family<
      DocumentEditorController,
      DocumentEditorState,
      String
    >(DocumentEditorController.new, retry: _retryUnlessDocumentIsMissing);

/// Riverpod's default retry, except that a document that does not exist fails
/// once: retrying cannot make it appear.
Duration? _retryUnlessDocumentIsMissing(int retryCount, Object error) {
  if (error is DocumentNotFoundException) return null;
  return ProviderContainer.defaultRetry(retryCount, error);
}
