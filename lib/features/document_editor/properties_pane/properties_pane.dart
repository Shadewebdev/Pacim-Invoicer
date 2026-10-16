import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_color_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/repository_providers.dart';
import '../../../domain/services/document_factory.dart';
import '../document_editor_controller.dart';
import 'document_properties_section.dart';
import 'header_footer_properties_section.dart';
import 'pricing_properties_section.dart';
import 'signature_properties_section.dart';

/// The width the pane takes beside the page.
const double propertiesPaneWidth = 300;

/// Edits one document's dates, header, footer, pricing and signature. The
/// parent decides how wide the pane is.
///
/// Each section except the first can be reset to the current settings, which
/// re-copies the defaults into this document only.
class PropertiesPane extends ConsumerStatefulWidget {
  const PropertiesPane({required this.documentId, super.key});

  final String documentId;

  @override
  ConsumerState<PropertiesPane> createState() => _PropertiesPaneState();
}

class _PropertiesPaneState extends ConsumerState<PropertiesPane> {
  /// Bumped after a reset so every field shows the restored values.
  int _resetGeneration = 0;

  Future<void> _resetSections(List<DocumentSection> sections) async {
    final controller = ref.read(
      documentEditorControllerProvider(widget.documentId).notifier,
    );
    for (final section in sections) {
      await controller.resetSectionToDefaults(section);
    }
    if (mounted) setState(() => _resetGeneration++);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorTokens>()!;
    final editorState = ref.watch(
      documentEditorControllerProvider(widget.documentId),
    );
    final value = editorState.value;
    if (value == null) return const SizedBox.shrink();

    final controller = ref.read(
      documentEditorControllerProvider(widget.documentId).notifier,
    );
    final document = value.document;
    final isLocked = value.isLocked;
    final today = ref.read(clockProvider)();

    return Material(
      color: tokens.surface,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Text(
                'Properties',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontSize: AppTypography.paneTitle),
              ),
            ),
            DocumentPropertiesSection(
              document: document,
              controller: controller,
              today: today,
              isLocked: isLocked,
              resetGeneration: _resetGeneration,
            ),
            HeaderFooterPropertiesSection(
              document: document,
              controller: controller,
              isLocked: isLocked,
              resetGeneration: _resetGeneration,
              onReset: () => unawaited(
                _resetSections(const [
                  DocumentSection.company,
                  DocumentSection.headerAndFooter,
                  DocumentSection.terms,
                ]),
              ),
            ),
            // Delivery orders carry no prices (spec 3.7).
            if (document.documentType.showsPricing)
              PricingPropertiesSection(
                document: document,
                controller: controller,
                isLocked: isLocked,
                resetGeneration: _resetGeneration,
                onReset: () =>
                    unawaited(_resetSections(const [DocumentSection.pricing])),
              ),
            SignaturePropertiesSection(
              document: document,
              controller: controller,
              isLocked: isLocked,
              resetGeneration: _resetGeneration,
              onReset: () =>
                  unawaited(_resetSections(const [DocumentSection.signature])),
            ),
          ],
        ),
      ),
    );
  }
}
