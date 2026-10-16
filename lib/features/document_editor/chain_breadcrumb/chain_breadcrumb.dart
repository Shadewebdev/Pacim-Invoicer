import 'package:flutter/material.dart';

import '../../../app/theme/app_color_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/document_type_colors.dart';
import '../../../domain/models/document_chain.dart';
import '../../../domain/models/document_summary.dart';

const double _chipHeight = 28;
const double _currentChipBorderWidth = 1.5;
const double _chipBorderWidth = 1;

/// The document a "+" chip would upgrade: the quotation while the chain has no
/// sales order, otherwise the sales order (delivery orders are repeatable).
/// Null when the chain has nothing to upgrade.
DocumentSummary? upgradeSourceFor(DocumentChain chain) =>
    chain.salesOrder ?? chain.quotation;

/// Chips for the documents of a chain, in stage order, with a "+" chip for the
/// next stage when [onUpgrade] is given.
class ChainBreadcrumb extends StatelessWidget {
  const ChainBreadcrumb({
    required this.chain,
    required this.currentDocumentId,
    required this.onOpenDocument,
    this.onUpgrade,
    super.key,
  });

  final DocumentChain chain;
  final String currentDocumentId;
  final ValueChanged<String> onOpenDocument;

  /// Called with the id of the document to upgrade. Null hides the "+" chip,
  /// for example when upgrading is blocked.
  final ValueChanged<String>? onUpgrade;

  @override
  Widget build(BuildContext context) {
    final upgradeSource = upgradeSourceFor(chain);
    final nextStage = upgradeSource?.documentType.nextStage;
    final children = <Widget>[
      if (chain.quotation case final quotation?)
        _DocumentChip(
          summary: quotation,
          isCurrent: quotation.documentId == currentDocumentId,
          onPressed: () => onOpenDocument(quotation.documentId),
        ),
      if (chain.salesOrder case final salesOrder?)
        _DocumentChip(
          summary: salesOrder,
          isCurrent: salesOrder.documentId == currentDocumentId,
          onPressed: () => onOpenDocument(salesOrder.documentId),
        ),
      if (chain.deliveryOrders.length == 1)
        _DocumentChip(
          summary: chain.deliveryOrders.single,
          isCurrent:
              chain.deliveryOrders.single.documentId == currentDocumentId,
          onPressed: () =>
              onOpenDocument(chain.deliveryOrders.single.documentId),
        )
      else if (chain.deliveryOrders.length > 1)
        _DeliveryOrderDropdown(
          deliveryOrders: chain.deliveryOrders,
          currentDocumentId: currentDocumentId,
          onOpenDocument: onOpenDocument,
        ),
      if (onUpgrade != null && upgradeSource != null && nextStage != null)
        _UpgradeChip(
          label: '+ ${nextStage.displayName}',
          onPressed: () => onUpgrade!(upgradeSource.documentId),
        ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text('›'),
              ),
            children[index],
          ],
        ],
      ),
    );
  }
}

/// The outlined, tinted pill every chip shares.
class _ChipFrame extends StatelessWidget {
  const _ChipFrame({
    required this.tint,
    required this.borderColor,
    required this.borderWidth,
    required this.onPressed,
    required this.child,
  });

  final Color tint;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(_chipHeight / 2);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tint,
        borderRadius: shape,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: shape,
          onTap: onPressed,
          child: SizedBox(
            height: _chipHeight - 2 * borderWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(widthFactor: 1, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class _DocumentChip extends StatelessWidget {
  const _DocumentChip({
    required this.summary,
    required this.isCurrent,
    required this.onPressed,
    this.label,
  });

  final DocumentSummary summary;
  final bool isCurrent;
  final VoidCallback onPressed;

  /// Replaces the document number, for the dropdown's trailing arrow.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorTokens>()!;
    final colors = theme.extension<DocumentTypeColors>()!;
    return _ChipFrame(
      tint: colors.tintFor(summary.documentType),
      borderColor: isCurrent ? tokens.ink : tokens.rule,
      borderWidth: isCurrent ? _currentChipBorderWidth : _chipBorderWidth,
      onPressed: onPressed,
      child: Text(
        label ?? summary.documentNumber,
        style: TextStyle(
          fontSize: AppTypography.body,
          color: colors.inkFor(summary.documentType),
          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _DeliveryOrderDropdown extends StatelessWidget {
  const _DeliveryOrderDropdown({
    required this.deliveryOrders,
    required this.currentDocumentId,
    required this.onOpenDocument,
  });

  final List<DocumentSummary> deliveryOrders;
  final String currentDocumentId;
  final ValueChanged<String> onOpenDocument;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<DocumentTypeColors>()!;
    final current = deliveryOrders
        .where((summary) => summary.documentId == currentDocumentId)
        .firstOrNull;
    final shown = current ?? deliveryOrders.last;
    return MenuAnchor(
      menuChildren: [
        for (final summary in deliveryOrders)
          MenuItemButton(
            onPressed: () => onOpenDocument(summary.documentId),
            child: Text(
              summary.documentNumber,
              style: TextStyle(
                color: colors.deliveryOrderInk,
                fontWeight: summary.documentId == currentDocumentId
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
      ],
      builder: (context, controller, child) => _DocumentChip(
        summary: shown,
        isCurrent: current != null,
        label: '${shown.documentNumber} ▾',
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}

class _UpgradeChip extends StatelessWidget {
  const _UpgradeChip({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorTokens>()!;
    return _ChipFrame(
      tint: Colors.transparent,
      borderColor: tokens.rule,
      borderWidth: _chipBorderWidth,
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(fontSize: AppTypography.body, color: tokens.action),
      ),
    );
  }
}
