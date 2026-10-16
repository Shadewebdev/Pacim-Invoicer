import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/business_document.dart';
import '../document_editor_controller.dart';

/// The edited document, rebuilding the caller only when the document itself
/// changes (not on save status or validation changes).
BusinessDocument watchEditedDocument(WidgetRef ref, String documentId) {
  return ref.watch(
    documentEditorControllerProvider(documentId)
        .select((state) => state.requireValue.document),
  );
}
