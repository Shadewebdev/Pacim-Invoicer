import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../app/shell/navigation_leave_guard.dart';
import '../../app/shell/status_bar_message_provider.dart';
import 'document_editor_controller.dart';
import 'document_editor_state.dart';

/// Lets editors take over the window's close button. The app uses the
/// window_manager implementation on Windows; tests use a fake or a
/// [StackedWindowCloseInterceptor] with recording callbacks.
abstract interface class WindowCloseInterceptor {
  /// Stops the window closing by itself and calls [onCloseRequested] instead.
  Future<void> startIntercepting(Future<void> Function() onCloseRequested);

  /// Withdraws a handler given to [startIntercepting].
  Future<void> stopIntercepting(Future<void> Function() onCloseRequested);

  /// Closes the window for good, after the person agreed to leave.
  Future<void> closeWindow();
}

/// Keeps a stack of handlers so one editor replacing another cannot switch
/// close prevention off: a new editor registers before the old one leaves.
/// The newest handler gets close requests, and prevention ends only when the
/// last handler is withdrawn.
class StackedWindowCloseInterceptor implements WindowCloseInterceptor {
  StackedWindowCloseInterceptor({
    required this.setPreventClose,
    required this.destroyWindow,
  });

  final Future<void> Function({required bool isPrevented}) setPreventClose;
  final Future<void> Function() destroyWindow;
  final List<Future<void> Function()> _handlers = [];

  @override
  Future<void> startIntercepting(
    Future<void> Function() onCloseRequested,
  ) async {
    _handlers.add(onCloseRequested);
    if (_handlers.length == 1) await setPreventClose(isPrevented: true);
  }

  @override
  Future<void> stopIntercepting(
    Future<void> Function() onCloseRequested,
  ) async {
    if (!_handlers.remove(onCloseRequested)) return;
    if (_handlers.isEmpty) await setPreventClose(isPrevented: false);
  }

  @override
  Future<void> closeWindow() => destroyWindow();

  /// Passes a close request from the window to the newest handler.
  Future<void> handleCloseRequested() async {
    if (_handlers.isEmpty) return;
    await _handlers.last();
  }
}

class _WindowManagerCloseListener with WindowListener {
  _WindowManagerCloseListener(this._interceptor);

  final StackedWindowCloseInterceptor _interceptor;

  @override
  void onWindowClose() => unawaited(_interceptor.handleCloseRequested());
}

StackedWindowCloseInterceptor _createWindowManagerInterceptor() {
  final interceptor = StackedWindowCloseInterceptor(
    setPreventClose: ({required isPrevented}) =>
        windowManager.setPreventClose(isPrevented),
    destroyWindow: windowManager.destroy,
  );
  windowManager.addListener(_WindowManagerCloseListener(interceptor));
  return interceptor;
}

/// Null where the window cannot be intercepted (web and mobile).
final windowCloseInterceptorProvider = Provider<WindowCloseInterceptor?>(
  (ref) => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows
      ? _createWindowManagerInterceptor()
      : null,
);

/// The most save attempts made for one leave request before staying put.
const int _maximumSaveAttempts = 3;

const String _saveCapReachedMessage =
    "Couldn't save. Your changes are still here.";

/// Wraps the editor so that leaving it (back, closing the window or choosing
/// another destination) never silently loses edits.
///
/// Pending edits are saved first. If saving fails, the person chooses between
/// retrying, leaving anyway (which discards the edits) and staying. The app
/// hiding or pausing also saves, because a browser tab or backgrounded app may
/// never come back.
class UnsavedChangesGuard extends ConsumerStatefulWidget {
  const UnsavedChangesGuard({
    required this.documentId,
    required this.child,
    super.key,
  });

  final String documentId;
  final Widget child;

  @override
  ConsumerState<UnsavedChangesGuard> createState() =>
      _UnsavedChangesGuardState();
}

class _UnsavedChangesGuardState extends ConsumerState<UnsavedChangesGuard> {
  late final AppLifecycleListener _lifecycleListener;
  late final NavigationLeaveGuardRegistry _leaveGuardRegistry;
  WindowCloseInterceptor? _windowCloseInterceptor;

  /// One tear-off, so withdrawing it later matches what was registered.
  late final Future<void> Function() _closeHandler = _onCloseRequested;

  /// True once the person agreed to leave, so the next pop goes through.
  bool _mayPop = false;

  /// The leave check being run, so a second request shares its outcome.
  Future<bool>? _leavingCheckInFlight;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onHide: _flushEdits,
      onPause: _flushEdits,
    );
    _leaveGuardRegistry = ref.read(navigationLeaveGuardProvider)
      ..register(this, _confirmLeaving);
    _windowCloseInterceptor = ref.read(windowCloseInterceptorProvider);
    unawaited(_windowCloseInterceptor?.startIntercepting(_closeHandler));
  }

  @override
  void didUpdateWidget(UnsavedChangesGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.documentId == widget.documentId) return;
    // Registrations call back into this state, which now reads the new id.
    // The document left behind keeps its edits, so save them.
    _mayPop = false;
    unawaited(
      ref
          .read(documentEditorControllerProvider(oldWidget.documentId).notifier)
          .saveNow(),
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _leaveGuardRegistry.unregister(this);
    unawaited(_windowCloseInterceptor?.stopIntercepting(_closeHandler));
    super.dispose();
  }

  DocumentEditorController get _controller =>
      ref.read(documentEditorControllerProvider(widget.documentId).notifier);

  SaveStatus? get _saveStatus => ref
      .read(documentEditorControllerProvider(widget.documentId))
      .value
      ?.saveStatus;

  /// Blurs the focused field so its typed text is committed as an edit.
  Future<void> _commitFocusedField() async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future<void>.delayed(Duration.zero);
  }

  Future<void> _flushEdits() async {
    await _commitFocusedField();
    await _controller.saveNow();
  }

  /// Saves pending edits and returns true when it is fine to leave: nothing
  /// is unsaved, or the person chose to leave without saving.
  Future<bool> _confirmLeaving() => _leavingCheckInFlight ??= _runLeavingCheck()
      .whenComplete(() => _leavingCheckInFlight = null);

  Future<bool> _runLeavingCheck() async {
    await _commitFocusedField();
    var saveAttempts = 0;
    while (true) {
      final status = _saveStatus;
      if (status == SaveStatus.pending || status == SaveStatus.saving) {
        // A save that keeps leaving edits unsaved is not worth waiting for.
        if (saveAttempts++ >= _maximumSaveAttempts) {
          ref
              .read(statusBarMessageProvider.notifier)
              .showMessage(_saveCapReachedMessage);
          return false;
        }
        await _controller.saveNow();
        continue;
      }
      if (status != SaveStatus.failed) return true;
      if (!mounted) return false;
      final choice = await showDialog<_LeaveChoice>(
        context: context,
        builder: (context) => const _SaveBeforeLeavingDialog(),
      );
      switch (choice) {
        case _LeaveChoice.retrySave:
          await _controller.retrySave();
        case _LeaveChoice.leaveWithoutSaving:
          _controller.discardPendingChanges();
          return true;
        case _LeaveChoice.cancel || null:
          return false;
      }
    }
  }

  Future<void> _onPopBlocked() async {
    if (!await _confirmLeaving() || !mounted) return;
    setState(() => _mayPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    final didPop = await Navigator.of(context).maybePop();
    if (didPop || !mounted) return;
    // The route did not go anywhere, so the next attempt must ask again.
    setState(() => _mayPop = false);
    // Nothing to pop back to, as when the editor was opened with `go` and
    // Android back is pressed: go to the document type's list instead.
    final type = ref
        .read(documentEditorControllerProvider(widget.documentId))
        .value
        ?.document
        .documentType;
    if (type == null) return;
    await goAfterLeaveGuard(context, ref, '/${type.routeSegment}');
  }

  Future<void> _onCloseRequested() async {
    if (await _confirmLeaving()) await _windowCloseInterceptor?.closeWindow();
  }

  @override
  Widget build(BuildContext context) {
    // Keeps the editor alive while it is on screen.
    ref.watch(
      documentEditorControllerProvider(widget.documentId)
          .select((state) => state.hasValue),
    );
    return PopScope(
      canPop: _mayPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) unawaited(_onPopBlocked());
      },
      child: widget.child,
    );
  }
}

enum _LeaveChoice { retrySave, leaveWithoutSaving, cancel }

class _SaveBeforeLeavingDialog extends StatelessWidget {
  const _SaveBeforeLeavingDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save changes before leaving?'),
      content: const Text("The latest changes couldn't be saved."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_LeaveChoice.cancel),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(_LeaveChoice.leaveWithoutSaving),
          child: const Text('Leave without saving'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_LeaveChoice.retrySave),
          child: const Text('Retry save'),
        ),
      ],
    );
  }
}
