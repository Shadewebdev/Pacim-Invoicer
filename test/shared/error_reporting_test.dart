import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/shared/error_reporting.dart';

void main() {
  test('logs the error with its stack and describes it', () {
    final logged = <String?>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) => logged.add(message);
    addTearDown(() => debugPrint = originalDebugPrint);
    final stack = StackTrace.fromString('#0 somewhere (file.dart:1:1)');

    final description = reportAndDescribeError(StateError('broken'), stack);

    expect(description, 'Bad state: broken');
    expect(logged.single, contains('Bad state: broken'));
    expect(logged.single, contains('#0 somewhere (file.dart:1:1)'));
  });
}
