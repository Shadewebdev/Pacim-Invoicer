import 'package:flutter/foundation.dart';

/// Logs [error] with its [stack], so a failure the user only sees as a short
/// message can still be diagnosed, and returns a one-line description of it.
///
/// It logs rather than calling `FlutterError.reportError`, because these
/// failures are handled: reporting them as Flutter errors would show the
/// red error screen in debug builds and fail widget tests that check the
/// handling.
String reportAndDescribeError(Object error, StackTrace stack) {
  final description = '$error';
  debugPrint('Handled error: $description\n$stack');
  return description;
}
