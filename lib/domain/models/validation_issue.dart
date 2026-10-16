import 'package:freezed_annotation/freezed_annotation.dart';

part 'validation_issue.freezed.dart';
part 'validation_issue.g.dart';

enum ValidationIssueKind {
  missingCustomerName,
  noLineItems,
  zeroQuantity,
  deliveryExceedsRemaining,
}

/// A problem found while validating a document, optionally tied to one line.
@freezed
abstract class ValidationIssue with _$ValidationIssue {
  const ValidationIssue._();

  const factory ValidationIssue({
    required ValidationIssueKind kind,
    String? lineItemId,
  }) = _ValidationIssue;

  factory ValidationIssue.fromJson(Map<String, dynamic> json) =>
      _$ValidationIssueFromJson(json);

  String get message => switch (kind) {
    ValidationIssueKind.missingCustomerName => 'Customer name is empty',
    ValidationIssueKind.noLineItems => 'This document has no items',
    ValidationIssueKind.zeroQuantity => 'An item has a quantity of zero',
    ValidationIssueKind.deliveryExceedsRemaining =>
      'An item delivers more than remains on the sales order',
  };
}
