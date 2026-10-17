import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/shell/status_bar_message_provider.dart';
import '../../domain/models/business_document.dart';
import '../../domain/models/validation_issue.dart';
import 'pdf_export_service.dart';

/// Exports [document] as a PDF, asking first when it has [issues]. Reports the
/// result in the status bar, and failures in a SnackBar.
Future<void> exportDocumentAsPdf({
  required BuildContext context,
  required WidgetRef ref,
  required BusinessDocument document,
  List<ValidationIssue> issues = const [],
}) async {
  if (issues.isNotEmpty && !await _confirmExportWithIssues(context, issues)) {
    return;
  }
  final service = ref.read(pdfExportServiceProvider);
  try {
    final outcome = await service.exportDocument(document);
    if (outcome == PdfExportOutcome.exported) {
      ref
          .read(statusBarMessageProvider.notifier)
          .showMessage('Exported ${service.suggestedFileName(document)}');
    }
  } on Object {
    if (!context.mounted) return;
    _showProblem(context, "Couldn't export ${document.documentNumber}");
  }
}

/// Opens the print dialog for [document], reporting failures in a SnackBar.
Future<void> printDocumentAsPdf({
  required BuildContext context,
  required WidgetRef ref,
  required BusinessDocument document,
}) async {
  try {
    await ref.read(pdfExportServiceProvider).printDocument(document);
  } on Object {
    if (!context.mounted) return;
    _showProblem(context, "Couldn't print ${document.documentNumber}");
  }
}

Future<bool> _confirmExportWithIssues(
  BuildContext context,
  List<ValidationIssue> issues,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Export with issues?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final issue in issues) Text(issue.message)],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          autofocus: true,
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Export anyway'),
        ),
      ],
    ),
  );
  return confirmed == true && context.mounted;
}

void _showProblem(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.maybeOf(context)
      ?.showSnackBar(SnackBar(content: Text(message)));
}
