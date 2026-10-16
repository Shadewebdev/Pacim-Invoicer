import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The item count shown on the right of the status bar, for example
/// "12 sales orders". Null hides it.
class StatusBarCountController extends Notifier<String?> {
  @override
  String? build() => null;

  void showCount(String? count) => state = count;

  /// Hides the count, but only when it is still [count]; does nothing once
  /// the provider is gone (for example when the whole app is closing).
  void clearCount(String? count) {
    if (count == null || !ref.mounted) return;
    if (state == count) state = null;
  }
}

final statusBarCountProvider =
    NotifierProvider<StatusBarCountController, String?>(
      StatusBarCountController.new,
    );
