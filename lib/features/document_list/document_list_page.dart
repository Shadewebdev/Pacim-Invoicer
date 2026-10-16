import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/shell/status_bar_count_provider.dart';
import '../../app/theme/app_color_tokens.dart';
import '../../app/theme/app_typography.dart';
import '../../domain/exceptions/document_exceptions.dart';
import '../../domain/models/currency_format.dart';
import '../../domain/models/document_summary.dart';
import '../../domain/models/document_type.dart';
import '../../shared/formatting/date_formatter.dart';
import '../document_editor/document_commands.dart';
import '../settings/settings_controller.dart';
import 'document_list_controller.dart';
import 'document_summary_table.dart';

const Duration _searchDebounce = Duration(milliseconds: 300);
const double _searchFieldWidth = 260;

/// The listing for one document type: command bar, table and empty state.
class DocumentListPage extends ConsumerStatefulWidget {
  const DocumentListPage({required this.documentType, super.key});

  final DocumentType documentType;

  @override
  ConsumerState<DocumentListPage> createState() => _DocumentListPageState();
}

class _DocumentListPageState extends ConsumerState<DocumentListPage> {
  final FocusNode _searchFocusNode = FocusNode(debugLabel: 'document search');
  final TextEditingController _searchController = TextEditingController();
  late final StatusBarCountController _statusBarCount;
  Timer? _searchTimer;
  String? _shownCount;

  DocumentType get _type => widget.documentType;

  String get _newDocumentLabel => 'New ${_type.displayName.toLowerCase()}';

  @override
  void initState() {
    super.initState();
    _statusBarCount = ref.read(statusBarCountProvider.notifier);
  }

  @override
  void didUpdateWidget(DocumentListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.documentType != widget.documentType) {
      _searchTimer?.cancel();
      _searchController.text = ref
          .read(documentListControllerProvider(widget.documentType))
          .searchText;
    }
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    final shownCount = _shownCount;
    final statusBarCount = _statusBarCount;
    // Clear after the tree is torn down, and only our own text, so a page
    // that replaces this one keeps its count.
    Future.microtask(() => statusBarCount.clearCount(shownCount));
    super.dispose();
  }

  void _showCount(int count) {
    final label = count == 1 ? _type.displayName : _type.pluralDisplayName;
    final text = '$count ${label.toLowerCase()}';
    _shownCount = text;
    _statusBarCount.showCount(text);
  }

  void _onSearchChanged(String text) {
    _searchTimer?.cancel();
    _searchTimer = Timer(_searchDebounce, () {
      ref
          .read(documentListControllerProvider(_type).notifier)
          .setSearchText(text.trim());
    });
  }

  Future<void> _pickIssuedRange() async {
    final controller = ref.read(documentListControllerProvider(_type).notifier);
    final query = ref.read(documentListControllerProvider(_type));
    final today = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(today.year + 5),
      initialDateRange: query.issuedFrom != null && query.issuedTo != null
          ? DateTimeRange(start: query.issuedFrom!, end: query.issuedTo!)
          : null,
    );
    if (range != null) controller.setIssuedRange(range.start, range.end);
  }

  void _showProblem(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _runCommand(
    String failureMessage,
    Future<void> Function() command,
  ) async {
    try {
      await command();
    } on InvalidUpgradeException catch (exception) {
      _showProblem(exception.reason);
    } on DocumentLockedException {
      _showProblem('This document is locked, so it can\'t be changed.');
    } on Object {
      _showProblem(failureMessage);
    }
  }

  void _openDocument(String documentId) {
    if (!mounted) return;
    context.go('/documents/$documentId');
  }

  Future<void> _createDocument() => _runCommand(
    "Couldn't create the ${_type.displayName.toLowerCase()}. Try again.",
    () async {
      final documentId = await ref
          .read(documentCommandsProvider)
          .createDocument(_type);
      _openDocument(documentId);
    },
  );

  Future<void> _upgradeDocument(DocumentSummary summary) => _runCommand(
    "Couldn't upgrade ${summary.documentNumber}. Try again.",
    () async {
      final documentId = await ref
          .read(documentCommandsProvider)
          .upgradeDocument(summary.documentId);
      _openDocument(documentId);
    },
  );

  Future<void> _duplicateDocument(DocumentSummary summary) => _runCommand(
    "Couldn't duplicate ${summary.documentNumber}. Try again.",
    () async {
      final documentId = await ref
          .read(documentCommandsProvider)
          .duplicateDocument(summary.documentId);
      _openDocument(documentId);
    },
  );

  Future<void> _confirmAndDelete(DocumentSummary summary) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          "Delete ${summary.documentNumber}? This can't be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            autofocus: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _runCommand(
      "Couldn't delete ${summary.documentNumber}. Try again.",
      () =>
          ref.read(documentCommandsProvider).deleteDocument(summary.documentId),
    );
  }

  Future<String?> _findUpgradeBlocker(DocumentSummary summary) async {
    try {
      return await ref
          .read(documentCommandsProvider)
          .findUpgradeBlockerFor(summary.documentId);
    } on Object {
      return "Couldn't check whether this can be upgraded";
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(documentListControllerProvider(_type));
    final summariesValue = ref.watch(documentSummariesProvider(_type));
    final currencyFormat =
        ref
            .watch(settingsControllerProvider)
            .value
            ?.pricingTerms
            .currencyFormat ??
        CurrencyFormat.defaultFormat;

    ref.listen(documentSummariesProvider(_type), (previous, next) {
      final summaries = next.value;
      if (summaries != null) _showCount(summaries.length);
    });
    final loadedSummaries = summariesValue.value;
    if (loadedSummaries != null && _shownCount == null) {
      // The first value can arrive before the listener is attached.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showCount(loadedSummaries.length);
      });
    }

    final hasFilter =
        query.searchText.isNotEmpty ||
        query.issuedFrom != null ||
        query.issuedTo != null;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyF, control: true):
            _searchFocusNode.requestFocus,
        const SingleActivator(LogicalKeyboardKey.keyN, control: true):
            _createDocument,
      },
      child: Focus(
        autofocus: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CommandBar(
              newDocumentLabel: _newDocumentLabel,
              searchController: _searchController,
              searchFocusNode: _searchFocusNode,
              issuedFrom: query.issuedFrom,
              issuedTo: query.issuedTo,
              onNewDocument: _createDocument,
              onSearchChanged: _onSearchChanged,
              onPickIssuedRange: _pickIssuedRange,
              onClearIssuedRange: () => ref
                  .read(documentListControllerProvider(_type).notifier)
                  .setIssuedRange(null, null),
              onRefresh: () => ref.invalidate(documentSummariesProvider(_type)),
            ),
            Expanded(
              child: summariesValue.when(
                skipLoadingOnRefresh: true,
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text(
                    "Couldn't load ${_type.pluralDisplayName.toLowerCase()}. "
                    'Try Refresh.',
                  ),
                ),
                data: (summaries) {
                  if (summaries.isEmpty) {
                    return _EmptyState(
                      message: hasFilter
                          ? 'No matching ${_type.pluralDisplayName.toLowerCase()}'
                          : 'No ${_type.pluralDisplayName.toLowerCase()} yet',
                      newDocumentLabel: hasFilter ? null : _newDocumentLabel,
                      onNewDocument: _createDocument,
                    );
                  }
                  return DocumentSummaryTable(
                    summaries: summaries,
                    documentType: _type,
                    currencyFormat: currencyFormat,
                    sortField: query.sortField,
                    sortDescending: query.sortDescending,
                    canLoadMore: summaries.length >= query.limit,
                    onSortChanged: (field) => ref
                        .read(documentListControllerProvider(_type).notifier)
                        .setSort(field),
                    onLoadMore: () => ref
                        .read(documentListControllerProvider(_type).notifier)
                        .loadMore(),
                    onOpen: (summary) => _openDocument(summary.documentId),
                    onUpgrade: _upgradeDocument,
                    onDuplicate: _duplicateDocument,
                    onDelete: _confirmAndDelete,
                    findUpgradeBlocker: _findUpgradeBlocker,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommandBar extends StatelessWidget {
  const _CommandBar({
    required this.newDocumentLabel,
    required this.searchController,
    required this.searchFocusNode,
    required this.issuedFrom,
    required this.issuedTo,
    required this.onNewDocument,
    required this.onSearchChanged,
    required this.onPickIssuedRange,
    required this.onClearIssuedRange,
    required this.onRefresh,
  });

  final String newDocumentLabel;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final DateTime? issuedFrom;
  final DateTime? issuedTo;
  final VoidCallback onNewDocument;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onPickIssuedRange;
  final VoidCallback onClearIssuedRange;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorTokens>()!;
    final hasRange = issuedFrom != null && issuedTo != null;
    final rangeLabel = hasRange
        ? '${formatDocumentDate(issuedFrom!)} to ${formatDocumentDate(issuedTo!)}'
        : 'Any issue date';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: tokens.chrome,
        border: Border(bottom: BorderSide(color: tokens.rule)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Tooltip(
            message: '$newDocumentLabel (Ctrl+N)',
            child: FilledButton.icon(
              onPressed: onNewDocument,
              icon: const Icon(Icons.add, size: 18),
              label: Text(newDocumentLabel),
            ),
          ),
          SizedBox(
            width: _searchFieldWidth,
            child: Tooltip(
              message: 'Search (Ctrl+F)',
              child: TextField(
                controller: searchController,
                focusNode: searchFocusNode,
                onChanged: onSearchChanged,
                style: const TextStyle(fontSize: AppTypography.field),
                decoration: const InputDecoration(
                  hintText: 'Search number or customer',
                  prefixIcon: Icon(Icons.search, size: 18),
                ),
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: onPickIssuedRange,
            icon: const Icon(Icons.date_range, size: 18),
            label: Text(rangeLabel),
          ),
          if (hasRange)
            IconButton(
              tooltip: 'Clear date filter',
              onPressed: onClearIssuedRange,
              icon: const Icon(Icons.close, size: 18),
            ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, size: 18),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
    required this.newDocumentLabel,
    required this.onNewDocument,
  });

  final String message;
  final String? newDocumentLabel;
  final VoidCallback onNewDocument;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: Theme.of(context).textTheme.titleMedium),
          if (newDocumentLabel != null) ...[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onNewDocument,
              child: Text(newDocumentLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
