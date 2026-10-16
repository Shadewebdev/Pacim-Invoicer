import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatusBarMessageController extends Notifier<String?> {
  @override
  String? build() => null;

  void showMessage(String? message) => state = message;
}

final statusBarMessageProvider =
    NotifierProvider<StatusBarMessageController, String?>(
      StatusBarMessageController.new,
    );
