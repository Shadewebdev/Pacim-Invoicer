import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/document_flow_scenario.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'quotation to sales order to two partial deliveries, then PDF export',
    runDocumentFlowScenario,
  );
}
