import 'package:flutter_test/flutter_test.dart';

import '../support/document_flow_scenario.dart';

void main() {
  // The same scenario integration_test/document_flow_test.dart runs on a
  // device, so CI covers it without one. Its Drift variant runs only there:
  // Drift completes a stream's cancellation on the real event loop, so
  // `watch().first` never finishes under the fake clock of widget tests.
  testWidgets(
    'quotation to sales order to two partial deliveries, then PDF export',
    runDocumentFlowScenario,
  );
}
