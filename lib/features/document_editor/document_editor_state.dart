import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/models/business_document.dart';
import '../../domain/models/validation_issue.dart';

part 'document_editor_state.freezed.dart';

/// Where the edited document stands relative to storage.
enum SaveStatus { saved, pending, saving, failed }

/// The document being edited with its save status and validation issues.
@freezed
abstract class DocumentEditorState with _$DocumentEditorState {
  const DocumentEditorState._();

  const factory DocumentEditorState({
    required BusinessDocument document,
    @Default(SaveStatus.saved) SaveStatus saveStatus,
    @Default([]) List<ValidationIssue> validationIssues,

    /// For a delivery order, the sales order it delivers against.
    BusinessDocument? salesOrder,

    /// For a delivery order, the other delivery orders of the same chain.
    @Default([]) List<BusinessDocument> otherDeliveryOrders,
  }) = _DocumentEditorState;

  bool get isLocked => document.isLocked;
}
