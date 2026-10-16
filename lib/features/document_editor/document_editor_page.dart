import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_color_tokens.dart';
import '../../app/theme/app_typography.dart';
import '../../domain/exceptions/document_exceptions.dart';
import '../../domain/models/document_type.dart';
import 'document_editor_controller.dart';
import 'document_editor_state.dart';
import 'document_page/document_canvas.dart';
import 'document_page/document_page_view.dart';
import 'document_page/page_zoom_provider.dart';
import 'created_from_document_provider.dart';
import 'locked_document_banner.dart';
import 'properties_pane/properties_pane.dart';
import 'unsaved_changes_guard.dart';

const double _commandBarHeight = 44;
const double _breadcrumbHeight = 40;

/// Narrower editors open the properties pane as a bottom sheet instead.
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fitsPaneBesidePage =
              constraints.maxWidth >= _propertiesPaneMinimumWindowWidth;
          final showsPropertiesPane =
              fitsPaneBesidePage && _isPropertiesPaneOpen;
          return Column(
            children: [
              _CommandBar(
                documentId: widget.documentId,
                state: value,
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
              // Task 20 fills this with the document chain breadcrumb.
              const SizedBox(
                key: ValueKey('breadcrumbSlot'),
                height: _breadcrumbHeight,
                width: double.infinity,
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
        },
      ),
    );
  }

  Widget _buildLockedBanner(DocumentEditorState value) {
    final createdFrom = ref
        .watch(
          createdFromDocumentProvider((
            documentId: value.document.documentId,
            chainId: value.document.chainId,
          )),
        )
        .value;
    return LockedDocumentBanner(
      document: value.document,
      createdFrom: createdFrom,
      // Task 20 wires "Duplicate as new draft".
      onDuplicateAsNewDraft: null,
      onOpenCreatedDocument: (summary) =>
          GoRouter.of(context).go('/documents/${summary.documentId}'),
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
    required this.onFitWidth,
    required this.propertiesButtonLabel,
    required this.onPropertiesPressed,
  });

  final String documentId;
  final DocumentEditorState state;
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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.chrome,
        border: Border(bottom: BorderSide(color: tokens.rule)),
      ),
      child: SizedBox(
        height: _commandBarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Tooltip(
                        message: state.isLocked
                            ? 'Locked documents cannot be changed'
                            : 'Save now',
                        child: FilledButton(
                          onPressed: state.isLocked
                              ? null
                              : () async {
                                  // Blur first so a field being typed in commits.
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  await Future<void>.delayed(Duration.zero);
                                  await controller.saveNow();
                                },
                          child: const Text('Save'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (nextStage != null)
                        _DisabledAction(
                          label:
                              'Upgrade to ${nextStage.displayName.toLowerCase()}',
                          tooltip: 'Upgrade is not available yet',
                        ),
                      const _DisabledAction(
                        label: 'Duplicate',
                        tooltip: 'Duplicate is not available yet',
                      ),
                      const _DisabledAction(
                        label: 'Export PDF',
                        tooltip: 'Export PDF is not available yet',
                      ),
                      const _DisabledAction(
                        label: 'Print',
                        tooltip: 'Print is not available yet',
                      ),
                    ],
                  ),
                ),
              ),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _DisabledAction extends StatelessWidget {
  const _DisabledAction({required this.label, required this.tooltip});

  final String label;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Tooltip(
        message: tooltip,
        child: TextButton(onPressed: null, child: Text(label)),
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

class _MissingDocument extends StatelessWidget {
  const _MissingDocument({required this.documentType});

  final DocumentType documentType;

  @override
  Widget build(BuildContext context) {
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
            onPressed: () =>
                GoRouter.of(context).go('/${documentType.routeSegment}'),
            child: Text(
              'Back to ${documentType.pluralDisplayName.toLowerCase()}',
            ),
          ),
        ],
      ),
    );
  }
}
