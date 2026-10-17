import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatusBarMessageController extends Notifier<String?> {
  @override
  String? build() => null;

  void showMessage(String? message) => state = message;

  /// Hides [message] if it is still the one shown, leaving any newer
  /// message in place.
  void clearMessage(String message) {
    if (state == message) state = null;
  }
}

final statusBarMessageProvider =
    NotifierProvider<StatusBarMessageController, String?>(
      StatusBarMessageController.new,
    );
