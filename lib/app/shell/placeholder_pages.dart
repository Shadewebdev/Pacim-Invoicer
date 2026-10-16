import 'package:flutter/material.dart';

import '../../domain/models/document_type.dart';

/// Replaced by the real listing page in a later task.
class DocumentListPage extends StatelessWidget {
  const DocumentListPage({required this.documentType, super.key});

  final DocumentType documentType;

  @override
  Widget build(BuildContext context) =>
      Center(child: Text('${documentType.pluralDisplayName} list'));
}

/// Replaced by the real editor in a later task.
class DocumentEditorPage extends StatelessWidget {
  const DocumentEditorPage({required this.documentId, super.key});

  final String documentId;

  @override
  Widget build(BuildContext context) =>
      Center(child: Text('Document $documentId'));
}
