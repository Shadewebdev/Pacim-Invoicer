import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/domain/models/business_document.dart';
import 'package:pacim_invoicer/domain/models/customer_details.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';
import 'package:pacim_invoicer/domain/models/validation_issue.dart';
import 'package:pacim_invoicer/domain/services/document_validator.dart';

import '../../support/document_builders.dart';

void main() {
  const validator = DocumentValidator();

  List<ValidationIssueKind> kindsOf(List<ValidationIssue> issues) => [
    for (final issue in issues) issue.kind,
  ];

  test('valid document has no issues', () {
    expect(validator.validate(buildTestDocument()), isEmpty);
  });

  test('missingCustomerName', () {
    final document = buildTestDocument().copyWith(
      customerDetails: const CustomerDetails(customerName: '   '),
    );
    expect(kindsOf(validator.validate(document)), [
      ValidationIssueKind.missingCustomerName,
    ]);
  });

  test('noLineItems', () {
    final document = buildTestDocument(lineItems: const []);
    expect(kindsOf(validator.validate(document)), [
      ValidationIssueKind.noLineItems,
    ]);
  });

  test('zeroQuantity names the line', () {
    final document = buildTestDocument(
      lineItems: [
        buildTestLine(),
        buildTestLine(id: 'zero', quantityScaled: 0),
      ],
    );
    final issues = validator.validate(document);
    expect(kindsOf(issues), [ValidationIssueKind.zeroQuantity]);
    expect(issues.single.lineItemId, 'zero');
  });

  group('deliveryExceedsRemaining', () {
    final salesOrder = buildTestDocument(
      type: DocumentType.salesOrder,
      documentId: 'so-1',
      lineItems: [buildTestLine(id: 'A', quantityScaled: 10000)],
    );
    final earlierDelivery = buildTestDocument(
      type: DocumentType.deliveryOrder,
      documentId: 'do-1',
      lineItems: [
        buildTestLine(
          id: 'e',
          quantityScaled: 4000,
        ).copyWith(sourceLineItemId: 'A'),
      ],
    );
    BusinessDocument deliveryOf(int quantityScaled) => buildTestDocument(
      type: DocumentType.deliveryOrder,
      documentId: 'do-2',
      lineItems: [
        buildTestLine(
          id: 'n',
          quantityScaled: quantityScaled,
        ).copyWith(sourceLineItemId: 'A'),
      ],
    );

    test('flagged when over the remaining quantity', () {
      final issues = validator.validate(
        deliveryOf(6001),
        salesOrder: salesOrder,
        otherDeliveryOrders: [earlierDelivery],
      );
      expect(kindsOf(issues), [ValidationIssueKind.deliveryExceedsRemaining]);
      expect(issues.single.lineItemId, 'n');
    });

    test('not flagged at exactly the remaining quantity', () {
      expect(
        validator.validate(
          deliveryOf(6000),
          salesOrder: salesOrder,
          otherDeliveryOrders: [earlierDelivery],
        ),
        isEmpty,
      );
    });

    test('not checked without a sales order', () {
      expect(validator.validate(deliveryOf(999000)), isEmpty);
    });

    test('the document itself is excluded from other deliveries', () {
      final self = deliveryOf(6000);
      expect(
        validator.validate(
          self,
          salesOrder: salesOrder,
          otherDeliveryOrders: [earlierDelivery, self],
        ),
        isEmpty,
      );
    });
  });
}
