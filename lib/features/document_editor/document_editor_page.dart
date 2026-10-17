import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/shell/navigation_leave_guard.dart';
import '../../app/theme/app_color_tokens.dart';
import '../../app/theme/app_typography.dart';
import '../../domain/exceptions/document_exceptions.dart';
import '../../domain/models/business_document.dart';
import '../../domain/models/document_type.dart';
import 'document_editor_controller.dart';
import 'document_editor_state.dart';
import 'document_page/document_canvas.dart';
import 'document_page/document_page_view.dart';
import 'document_page/page_zoom_provider.dart';
import 'chain_breadcrumb/chain_breadcrumb.dart';
import 'chain_breadcrumb/document_chain_provider.dart';
import 'document_editor_actions.dart';
import 'locked_document_banner.dart';
import 'properties_pane/properties_pane.dart';
import 'unsaved_changes_guard.dart';

const double _commandBarHeight = 44;
const double _commandBarSecondRowHeight = 36;
const double _breadcrumbHeight = 40;

/// The commands and the status/zoom group together need about this much; any
/// narrower and the second group wraps onto its own row.
const double _commandBarSplitMinimumWidth = 1450;

/// The commands alone need about this much; narrower and they scroll in one
/// row instead of wrapping, which caps the whole bar at two rows (80 px).
const double _commandWrapMinimumWidth = 760;

/// Gap between command buttons, wrapped or scrolling.
const double _commandSpacing = 8;

/// The A4 page needs about 794 px and the pane 300 px, so the pane only fits
/// beside the page from 1000 px; narrower editors open it as a bottom sheet.
const double _propertiesPaneMinimumWindowWidth = 1000;
const double _propertiesSheetMaximumHeightFraction = 0.85;

/// The document editor: command bar, breadcrumb, A4 page canvas and the
/// properties pane.
class DocumentEditorPage extends ConsumerStatefulWidget {
  const DocumentEditorPage({required this.documentId, super.key});

  final String documentId;

  @override
  ConsumerState<DocumentEditorPage> createState() => _DocumentEditorPageState();
}

class _DocumentEditorPageState extends ConsumerState<DocumentEditorPage> {
  double _canvasWidth = 0;

  /// The type of the last document this page showed, used if it disappears.
  DocumentType? _lastKnownType;

  bool _isPropertiesPaneOpen = true;

  late final DocumentEditorActions _actions = DocumentEditorActions(
    context: context,
    ref: ref,
    currentDocumentId: () => widget.documentId,
    restoreFocus: _pageFocusNode.requestFocus,
  );

  final FocusNode _pageFocusNode = FocusNode(
    debugLabel: 'document editor page',
    skipTraversal: true,
  );

  @override
  void dispose() {
    _pageFocusNode.dispose();
    super.dispose();
  }

  /// Upgrades like the Upgrade button would: nothing happens while it is
  /// hidden or disabled.
  void _upgradeFromShortcut(BusinessDocument document) {
    if (document.documentType.nextStage == null) return;
    final blocker = ref.read(
      upgradeBlockerProvider((
        documentId: document.documentId,
        chainId: document.chainId,
      )),
    );
    if (blocker.hasValue && blocker.value == null) {
      unawaited(_actions.upgradeCurrent());
    }
  }

  void _fitWidth() {
    if (_canvasWidth <= 0) return;
    final available = _canvasWidth - 2 * documentCanvasPadding;
    ref
        .read(pageZoomProvider.notifier)
        .setZoom(available / DocumentPageView.pageWidth);
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(
      documentEditorControllerProvider(widget.documentId),
    );
    final value = editorState.value;
    if (value != null) _lastKnownType = value.document.documentType;

    if (editorState.hasError &&
        editorState.error is DocumentNotFoundException) {
      return _MissingDocument(
        documentType: _lastKnownType ?? DocumentType.quotation,
      );
    }
    if (value == null) {
      if (editorState.hasError) {
        return const Center(child: Text('This document could not be opened'));
      }
      return const Center(child: CircularProgressIndicator());
    }

    return UnsavedChangesGuard(
      documentId: widget.documentId,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
              unawaited(_actions.save()),
          const SingleActivator(
            LogicalKeyboardKey.keyU,
            control: true,
            shift: true,
          ): () =>
              _upgradeFromShortcut(value.document),
          const SingleActivator(LogicalKeyboardKey.keyN, control: true): () =>
              unawaited(_actions.createSameType()),
          const SingleActivator(LogicalKeyboardKey.keyP, control: true): () =>
              unawaited(_actions.exportPdf()),
        },
        // Takes focus when nothing else has it, so shortcuts always work.
        child: Focus(
          focusNode: _pageFocusNode,
          autofocus: true,
          child: LayoutBuilder(
            builder: (context, constraints) =>
                _buildEditor(value, constraints.maxWidth),
          ),
        ),
      ),
    );
  }

  Widget _buildEditor(DocumentEditorState value, double maxWidth) {
    final fitsPaneBesidePage = maxWidth >= _propertiesPaneMinimumWindowWidth;
    final showsPropertiesPane = fitsPaneBesidePage && _isPropertiesPaneOpen;
    final upgradeBlocker = ref.watch(
      upgradeBlockerProvider((
        documentId: value.document.documentId,
        chainId: value.document.chainId,
      )),
    );
    return Column(
      children: [
        _CommandBar(
          documentId: widget.documentId,
          state: value,
          actions: _actions,
          upgradeBlocker: upgradeBlocker,
          onFitWidth: _fitWidth,
          propertiesButtonLabel: !fitsPaneBesidePage
              ? 'Properties'
              : _isPropertiesPaneOpen
              ? 'Hide properties'
              : 'Show properties',
          onPropertiesPressed: fitsPaneBesidePage
              ? () => setState(
                  () => _isPropertiesPaneOpen = !_isPropertiesPaneOpen,
                )
              : _openPropertiesSheet,
        ),
        if (value.isLocked) _buildLockedBanner(value),
        _BreadcrumbBar(
          key: const ValueKey('breadcrumbSlot'),
          document: value.document,
          actions: _actions,
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: DocumentCanvas(
                  documentId: widget.documentId,
                  onViewportWidthChanged: (width) => _canvasWidth = width,
                ),
              ),
              if (showsPropertiesPane)
                SizedBox(
                  key: const ValueKey('propertiesPane'),
                  width: propertiesPaneWidth,
                  child: PropertiesPane(documentId: widget.documentId),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLockedBanner(DocumentEditorState value) {
    final chain = ref
        .watch(documentChainProvider(value.document.chainId))
        .value;
    return LockedDocumentBanner(
      document: value.document,
      createdFrom: chain == null
          ? null
          : documentCreatedFrom(chain, value.document.documentId),
      onDuplicateAsNewDraft: () => unawaited(_actions.duplicate()),
      onOpenCreatedDocument: (summary) =>
          unawaited(_actions.open(summary.documentId)),
    );
  }

  Future<void> _openPropertiesSheet() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.sizeOf(context).height *
            _propertiesSheetMaximumHeightFraction,
      ),
      builder: (context) => PropertiesPane(documentId: widget.documentId),
    );
  }
}

class _CommandBar extends ConsumerWidget {
  const _CommandBar({
    required this.documentId,
    required this.state,
    required this.actions,
    required this.upgradeBlocker,
    required this.onFitWidth,
    required this.propertiesButtonLabel,
    required this.onPropertiesPressed,
  });

  final String documentId;
  final DocumentEditorState state;
  final DocumentEditorActions actions;

  /// Why the document cannot be upgraded; data of null means it can be.
  final AsyncValue<String?> upgradeBlocker;
  final VoidCallback onFitWidth;
  final String propertiesButtonLabel;
  final VoidCallback onPropertiesPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppColorTokens>()!;
    final zoom = ref.watch(pageZoomProvider);
    final nextStage = state.document.documentType.nextStage;
    final controller = ref.read(
      documentEditorControllerProvider(documentId).notifier,
    );
    final blockerReason = upgradeBlocker.value;
    final canUpgrade = upgradeBlocker.hasValue && blockerReason == null;
    final upgradeLabel = 'Upgrade to ${nextStage?.displayName.toLowerCase()}';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.chrome,
        border: Border(bottom: BorderSide(color: tokens.rule)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final actionButtons = <Widget>[
              Tooltip(
                message: state.isLocked
                    ? 'Locked documents cannot be changed'
                    : 'Save (Ctrl+S)',
                child: FilledButton(
                  onPressed: state.isLocked
                      ? null
                      : () => unawaited(actions.save()),
                  child: const Text('Save'),
                ),
              ),
              if (nextStage != null)
                _CommandButton(
                  label: upgradeLabel,
                  tooltip: blockerReason ?? '$upgradeLabel (Ctrl+Shift+U)',
                  onPressed: canUpgrade
                      ? () => unawaited(actions.upgradeCurrent())
                      : null,
                ),
              _CommandButton(
                label: 'Duplicate',
                tooltip: 'Duplicate as new draft',
                onPressed: () => unawaited(actions.duplicate()),
              ),
              if (!state.isLocked)
                _CommandButton(
                  label: 'Delete',
                  tooltip: 'Delete this draft',
                  onPressed: () => unawaited(actions.delete()),
                ),
              _CommandButton(
                label: 'Export PDF',
                tooltip: 'Export PDF (Ctrl+P)',
                onPressed: () => unawaited(actions.exportPdf()),
              ),
              _CommandButton(
                label: 'Print',
                tooltip: 'Print',
                onPressed: () => unawaited(actions.printDocument()),
              ),
            ];
            final trailing = <Widget>[
              _SaveStatusLabel(
                status: state.saveStatus,
                onRetry: controller.retrySave,
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: onPropertiesPressed,
                child: Text(propertiesButtonLabel),
              ),
              TextButton(onPressed: onFitWidth, child: const Text('Fit width')),
              const SizedBox(width: 4),
              SizedBox(
                width: 44,
                child: Text(
                  '${(zoom * 100).round()}%',
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: AppTypography.caption),
                ),
              ),
            ];
            Widget scrollingRow(List<Widget> children) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(spacing: _commandSpacing, children: children),
            );
            // Narrower than both groups side by side, the status and view
            // controls drop to a second row, so no command is hidden.
            if (constraints.maxWidth < _commandBarSplitMinimumWidth) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (constraints.maxWidth < _commandWrapMinimumWidth)
                    SizedBox(
                      height: _commandBarHeight,
                      width: double.infinity,
                      child: scrollingRow(actionButtons),
                    )
                  else
                    Wrap(
                      spacing: _commandSpacing,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final button in actionButtons)
                          SizedBox(height: _commandBarHeight, child: button),
                      ],
                    ),
                  SizedBox(
                    height: _commandBarSecondRowHeight,
                    width: double.infinity,
                    child: scrollingRow(trailing),
                  ),
                ],
              );
            }
            return SizedBox(
              height: _commandBarHeight,
              child: Row(
                children: [
                  Expanded(child: scrollingRow(actionButtons)),
                  ...trailing,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The chain breadcrumb, with the "+" chip offered only when the next stage
/// can be created.
class _BreadcrumbBar extends ConsumerWidget {
  const _BreadcrumbBar({
    required this.document,
    required this.actions,
    super.key,
  });

  final BusinessDocument document;
  final DocumentEditorActions actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chain = ref.watch(documentChainProvider(document.chainId)).value;
    final upgradeSource = chain == null ? null : upgradeSourceFor(chain);
    final blocker = upgradeSource == null
        ? null
        : ref.watch(
            upgradeBlockerProvider((
              documentId: upgradeSource.documentId,
              chainId: document.chainId,
            )),
          );
    final canUpgrade =
        blocker != null && blocker.hasValue && blocker.value == null;
    return SizedBox(
      height: _breadcrumbHeight,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: chain == null
              ? null
              : ChainBreadcrumb(
                  chain: chain,
                  currentDocumentId: document.documentId,
                  onOpenDocument: (documentId) =>
                      unawaited(actions.open(documentId)),
                  onUpgrade: canUpgrade
                      ? (sourceId) => unawaited(actions.upgrade(sourceId))
                      : null,
                ),
        ),
      ),
    );
  }
}

class _CommandButton extends StatelessWidget {
  const _CommandButton({
    required this.label,
    required this.tooltip,
    this.onPressed,
  });

  final String label;
  final String tooltip;

  /// Null shows the button disabled.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Tooltip(
        message: tooltip,
        child: TextButton(onPressed: onPressed, child: Text(label)),
      ),
    );
  }
}

class _SaveStatusLabel extends StatelessWidget {
  const _SaveStatusLabel({required this.status, required this.onRetry});

  final SaveStatus status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: AppTypography.caption);
    return switch (status) {
      SaveStatus.saved => const Text('Saved', style: style),
      SaveStatus.pending => const Text('Unsaved changes', style: style),
      SaveStatus.saving => const Text('Saving', style: style),
      SaveStatus.failed => TextButton(
        onPressed: onRetry,
        child: const Text('Not saved, retry'),
      ),
    };
  }
}

class _MissingDocument extends ConsumerWidget {
  const _MissingDocument({required this.documentType});

  final DocumentType documentType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'This document no longer exists',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => unawaited(
              goAfterLeaveGuard(context, ref, '/${documentType.routeSegment}'),
            ),
            child: Text(
              'Back to ${documentType.pluralDisplayName.toLowerCase()}',
            ),
          ),
        ],
      ),
    );
  }
}
