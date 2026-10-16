import 'package:flutter/material.dart';

/// Replaced by the real editor in a later task.
class DocumentEditorPage extends StatelessWidget {
  const DocumentEditorPage({required this.documentId, super.key});

  final String documentId;

  @override
  Widget build(BuildContext context) =>
      Center(child: Text('Document $documentId'));
}
