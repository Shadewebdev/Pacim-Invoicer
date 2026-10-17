import 'package:flutter_test/flutter_test.dart';

import '../support/document_flow_scenario.dart';

void main() {
  // The same scenario integration_test/document_flow_test.dart runs on a
  // device, so CI covers it without one.
  testWidgets(
    'quotation to sales order to two partial deliveries, then PDF export',
    runDocumentFlowScenario,
  );
}
