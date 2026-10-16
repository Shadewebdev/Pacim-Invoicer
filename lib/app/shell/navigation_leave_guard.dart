import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Lets the screen being shown veto in-app navigation, for example an editor
/// whose last save failed. Registering does not notify anyone, so a screen can
/// register while it is being built.
class NavigationLeaveGuardRegistry {
  Object? _owner;
  Future<bool> Function()? _confirmLeaving;

  /// Makes [confirmLeaving] the check that runs before leaving. The newest
  /// registration wins, which matters while one screen replaces another.
  void register(Object owner, Future<bool> Function() confirmLeaving) {
    _owner = owner;
    _confirmLeaving = confirmLeaving;
  }

  /// Removes [owner]'s registration, unless a newer owner has replaced it.
  void unregister(Object owner) {
    if (!identical(_owner, owner)) return;
    _owner = null;
    _confirmLeaving = null;
  }

  /// True when nothing objects to leaving the current screen.
  Future<bool> confirmLeaving() async => await _confirmLeaving?.call() ?? true;
}

final navigationLeaveGuardProvider = Provider<NavigationLeaveGuardRegistry>(
  (ref) => NavigationLeaveGuardRegistry(),
);

/// Goes to [location] unless the current screen objects to being left.
/// Returns whether it navigated; there is nothing to navigate without a router.
Future<bool> goAfterLeaveGuard(
  BuildContext context,
  WidgetRef ref,
  String location,
) async {
  final router = GoRouter.maybeOf(context);
  final mayLeave = await ref
      .read(navigationLeaveGuardProvider)
      .confirmLeaving();
  if (!mayLeave || router == null) return false;
  router.go(location);
  return true;
}
