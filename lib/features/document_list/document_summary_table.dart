import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_color_tokens.dart';
import '../../app/theme/app_typography.dart';
import '../../domain/models/document_list_query.dart';
import '../../domain/models/document_summary.dart';
import '../../domain/models/document_type.dart';
import '../../shared/formatting/date_formatter.dart';
import '../../shared/formatting/money_formatter.dart';
import 'document_list_controller.dart';
import 'document_type_badge.dart';

const double _rowHeight = 32;
const double _numberColumnWidth = 150;
const double _dateColumnWidth = 120;
const double _totalColumnWidth = 130;
const double _statusColumnWidth = 90;
const double _chainColumnWidth = 260;
const double _chainColumnMinimumTableWidth = 900;

/// Below this table width the issue date goes too, and columns tighten.
///
/// These thresholds compare the table's own width, not the window's: the
/// sidebar or rail takes 56-220 px of the window, so the shared
/// `AppBreakpoints` (window widths) would cut the columns at the wrong point.
const double _dateColumnMinimumTableWidth = 600;
const double _compactNumberColumnWidth = 116;
const double _compactTotalColumnWidth = 100;
const double _compactStatusColumnWidth = 72;
const double _loadMoreDistance = 240;

/// The listing table: sortable header, 32 px rows, a right-click menu per row.
class DocumentSummaryTable extends StatefulWidget {
  const DocumentSummaryTable({
    required this.summaries,
    required this.documentType,
    required this.sortField,
    required this.sortDescending,
    required this.canLoadMore,
    required this.onSortChanged,
    required this.onLoadMore,
    required this.onOpen,
    required this.onUpgrade,
    required this.onDuplicate,
    required this.onExportPdf,
    required this.onDelete,
    required this.findUpgradeBlocker,
    super.key,
  });

  final List<DocumentSummary> summaries;
  final DocumentType documentType;
  final DocumentSortField sortField;
  final bool sortDescending;
  final bool canLoadMore;
  final ValueChanged<DocumentSortField> onSortChanged;
  final VoidCallback onLoadMore;
  final ValueChanged<DocumentSummary> onOpen;
  final ValueChanged<DocumentSummary> onUpgrade;
  final ValueChanged<DocumentSummary> onDuplicate;
  final ValueChanged<DocumentSummary> onExportPdf;
  final ValueChanged<DocumentSummary> onDelete;

  /// The reason the row cannot be upgraded, or null when it can.
  final Future<String?> Function(DocumentSummary summary) findUpgradeBlocker;

  @override
  State<DocumentSummaryTable> createState() => _DocumentSummaryTableState();
}

class _DocumentSummaryTableState extends State<DocumentSummaryTable> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreNearBottom);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_loadMoreNearBottom)
      ..dispose();
    super.dispose();
  }

  void _loadMoreNearBottom() {
    if (!widget.canLoadMore || !_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < _loadMoreDistance) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showsChain =
            constraints.maxWidth >= _chainColumnMinimumTableWidth;
        final layout = _ColumnLayout(
          showsTotal: widget.documentType.showsPricing,
          showsChain: showsChain,
          showsDate: constraints.maxWidth >= _dateColumnMinimumTableWidth,
        );
        return Column(
          children: [
            _HeaderRow(
              layout: layout,
              sortField: widget.sortField,
              sortDescending: widget.sortDescending,
              onSortChanged: widget.onSortChanged,
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemExtent: _rowHeight,
                itemCount: widget.summaries.length,
                itemBuilder: (context, index) {
                  final summary = widget.summaries[index];
                  return _SummaryRow(
                    key: ValueKey(summary.documentId),
                    summary: summary,
                    layout: layout,
                    onOpen: widget.onOpen,
                    onUpgrade: widget.onUpgrade,
                    onDuplicate: widget.onDuplicate,
                    onExportPdf: widget.onExportPdf,
                    onDelete: widget.onDelete,
                    findUpgradeBlocker: widget.findUpgradeBlocker,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ColumnLayout {
  const _ColumnLayout({
    required this.showsTotal,
    required this.showsChain,
    required this.showsDate,
  });

  final bool showsTotal;
  final bool showsChain;
  final bool showsDate;

  double get numberWidth =>
      showsDate ? _numberColumnWidth : _compactNumberColumnWidth;
  double get totalWidth =>
      showsDate ? _totalColumnWidth : _compactTotalColumnWidth;
  double get statusWidth =>
      showsDate ? _statusColumnWidth : _compactStatusColumnWidth;
  double get statusInset => showsDate ? 16 : 8;
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.layout,
    required this.sortField,
    required this.sortDescending,
    required this.onSortChanged,
  });

  final _ColumnLayout layout;
  final DocumentSortField sortField;
  final bool sortDescending;
  final ValueChanged<DocumentSortField> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorTokens>()!;
    Widget sortable(String label, DocumentSortField field, {bool end = false}) {
      final isActive = sortField == field;
      return InkWell(
        onTap: () => onSortChanged(field),
        child: Row(
          mainAxisAlignment: end
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppTypography.body,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: tokens.ink,
                ),
              ),
            ),
            if (isActive)
              Icon(
                sortDescending ? Icons.arrow_downward : Icons.arrow_upward,
                size: 14,
                semanticLabel: sortDescending ? 'Descending' : 'Ascending',
              ),
          ],
        ),
      );
    }

    Widget plain(String label) => Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppTypography.body,
          fontWeight: FontWeight.w500,
          color: tokens.ink,
        ),
      ),
    );

    return Container(
      height: _rowHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: tokens.chrome,
        border: Border(bottom: BorderSide(color: tokens.rule)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: layout.numberWidth,
            child: sortable('Number', DocumentSortField.documentNumber),
          ),
          Expanded(child: sortable('Customer', DocumentSortField.customerName)),
          if (layout.showsDate)
            SizedBox(
              width: _dateColumnWidth,
              child: sortable('Issue date', DocumentSortField.issueDate),
            ),
          if (layout.showsTotal)
            SizedBox(
              width: layout.totalWidth,
              child: sortable('Total', DocumentSortField.grandTotal, end: true),
            ),
          SizedBox(
            width: layout.statusWidth,
            child: Padding(
              padding: EdgeInsets.only(left: layout.statusInset),
              child: plain('Status'),
            ),
          ),
          if (layout.showsChain)
            SizedBox(width: _chainColumnWidth, child: plain('Chain')),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatefulWidget {
  const _SummaryRow({
    required this.summary,
    required this.layout,
    required this.onOpen,
    required this.onUpgrade,
    required this.onDuplicate,
    required this.onExportPdf,
    required this.onDelete,
    required this.findUpgradeBlocker,
    super.key,
  });

  final DocumentSummary summary;
  final _ColumnLayout layout;
  final ValueChanged<DocumentSummary> onOpen;
  final ValueChanged<DocumentSummary> onUpgrade;
  final ValueChanged<DocumentSummary> onDuplicate;
  final ValueChanged<DocumentSummary> onExportPdf;
  final ValueChanged<DocumentSummary> onDelete;
  final Future<String?> Function(DocumentSummary summary) findUpgradeBlocker;

  @override
  State<_SummaryRow> createState() => _SummaryRowState();
}

class _SummaryRowState extends State<_SummaryRow> {
  final MenuController _menuController = MenuController();
  final FocusNode _focusNode = FocusNode(debugLabel: 'document row');
  bool _isHovered = false;
  String? _upgradeBlocker;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _openOnEnter(FocusNode node, KeyEvent event) {
    final isEnter =
        event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter;
    if (event is KeyDownEvent && isEnter) {
      widget.onOpen(widget.summary);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _showMenu(TapDownDetails details) async {
    _focusNode.requestFocus();
    final position = details.localPosition;
    if (widget.summary.documentType.nextStage != null) {
      final blocker = await widget.findUpgradeBlocker(widget.summary);
      if (!mounted) return;
      setState(() => _upgradeBlocker = blocker);
    }
    _menuController.open(position: position);
  }

  String _formatTotal() => formatMoney(
    widget.summary.grandTotalMinor,
    widget.summary.currencyFormat,
  );

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final tokens = Theme.of(context).extension<AppColorTokens>()!;
    final nextStage = summary.documentType.nextStage;
    final baseStyle = TextStyle(
      fontSize: AppTypography.body,
      color: tokens.ink,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return MenuAnchor(
      controller: _menuController,
      menuChildren: [
        MenuItemButton(
          onPressed: () => widget.onOpen(summary),
          child: const Text('Open'),
        ),
        if (nextStage != null)
          Tooltip(
            message: _upgradeBlocker ?? '',
            child: MenuItemButton(
              onPressed: _upgradeBlocker == null
                  ? () => widget.onUpgrade(summary)
                  : null,
              child: Text('Upgrade to ${nextStage.displayName.toLowerCase()}'),
            ),
          ),
        MenuItemButton(
          onPressed: () => widget.onDuplicate(summary),
          child: const Text('Duplicate as new draft'),
        ),
        MenuItemButton(
          onPressed: () => widget.onExportPdf(summary),
          child: const Text('Export PDF'),
        ),
        if (!summary.isLocked)
          MenuItemButton(
            onPressed: () => widget.onDelete(summary),
            child: const Text('Delete'),
          ),
      ],
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Focus(
          focusNode: _focusNode,
          onKeyEvent: _openOnEnter,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _focusNode.requestFocus,
            onDoubleTap: () => widget.onOpen(summary),
            onSecondaryTapDown: _showMenu,
            child: ListenableBuilder(
              listenable: _focusNode,
              builder: (context, child) {
                final isFocused = _focusNode.hasFocus;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: isFocused
                        ? tokens.action.withValues(alpha: 0.12)
                        : _isHovered
                        ? tokens.chrome
                        : null,
                    border: Border(
                      bottom: BorderSide(color: tokens.rule),
                      left: BorderSide(
                        width: 2,
                        color: isFocused ? tokens.action : Colors.transparent,
                      ),
                    ),
                  ),
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    SizedBox(
                      width: widget.layout.numberWidth,
                      child: Text(
                        summary.documentNumber,
                        style: baseStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        summary.customerName,
                        style: baseStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.layout.showsDate)
                      SizedBox(
                        width: _dateColumnWidth,
                        child: Text(
                          formatDocumentDate(summary.issueDate),
                          style: baseStyle,
                        ),
                      ),
                    if (widget.layout.showsTotal)
                      SizedBox(
                        width: widget.layout.totalWidth,
                        child: Text(
                          _formatTotal(),
                          textAlign: TextAlign.end,
                          style: baseStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    SizedBox(
                      width: widget.layout.statusWidth,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: widget.layout.statusInset,
                        ),
                        child: Text(
                          summary.isLocked ? 'Locked' : 'Draft',
                          style: baseStyle.copyWith(
                            fontWeight: summary.isLocked
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    if (widget.layout.showsChain)
                      SizedBox(
                        width: _chainColumnWidth,
                        child: _ChainChips(summary: summary),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tinted chips for the other documents in the row's chain.
class _ChainChips extends ConsumerWidget {
  const _ChainChips({required this.summary});

  final DocumentSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chain = ref.watch(listedDocumentChainProvider(summary.chainId)).value;
    if (chain == null) return const SizedBox.shrink();
    final others = [
      if (chain.quotation != null) chain.quotation!,
      if (chain.salesOrder != null) chain.salesOrder!,
      ...chain.deliveryOrders,
    ].where((other) => other.documentId != summary.documentId).toList();
    return ClipRect(
      child: Wrap(
        spacing: 4,
        children: [
          for (final other in others)
            DocumentTypeBadge(
              documentType: other.documentType,
              label: other.documentNumber,
            ),
        ],
      ),
    );
  }
}
