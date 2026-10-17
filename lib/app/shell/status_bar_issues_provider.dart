import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The open document's validation issues, for example
/// "2 issues: Customer name is empty; …". Null hides them.
class StatusBarIssuesController extends Notifier<String?> {
  @override
  String? build() => null;

  void showIssues(String issues) => state = issues;

  /// Hides the issues, but only when they are still [issues], so an editor
  /// that replaced this one keeps its own; does nothing once the provider is
  /// gone.
  void clearIssues(String? issues) {
    if (issues == null || !ref.mounted) return;
    if (state == issues) state = null;
  }
}

final statusBarIssuesProvider =
    NotifierProvider<StatusBarIssuesController, String?>(
      StatusBarIssuesController.new,
    );
