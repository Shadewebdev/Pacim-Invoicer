import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'document_editor_controller.dart';
import 'document_editor_state.dart';

/// Lets the guard take over the window's close button. The app uses the
/// window_manager implementation on Windows; tests use a fake.
abstract interface class WindowCloseInterceptor {
  /// Stops the window closing by itself and calls [onCloseRequested] instead.
  Future<void> startIntercepting(Future<void> Function() onCloseRequested);

  Future<void> stopIntercepting();

  /// Closes the window for good, after the person agreed to leave.
  Future<void> closeWindow();
}

class _WindowManagerCloseInterceptor
    with WindowListener
    implements WindowCloseInterceptor {
  Future<void> Function()? _onCloseRequested;

  @override
  Future<void> startIntercepting(
    Future<void> Function() onCloseRequested,
  ) async {
    _onCloseRequested = onCloseRequested;
    windowManager.addListener(this);
    await windowManager.setPreventClose(true);
  }

  @override
  Future<void> stopIntercepting() async {
    _onCloseRequested = null;
    windowManager.removeListener(this);
    await windowManager.setPreventClose(false);
  }

  @override
  Future<void> closeWindow() => windowManager.destroy();

  @override
  void onWindowClose() {
    final onCloseRequested = _onCloseRequested;
    if (onCloseRequested != null) unawaited(onCloseRequested());
  }
}

/// Null where the window cannot be intercepted (web and mobile).
final windowCloseInterceptorProvider = Provider<WindowCloseInterceptor?>(
  (ref) => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows
      ? _WindowManagerCloseInterceptor()
      : null,
);

/// Wraps the editor so that leaving it (back, or closing the window) never
/// silently loses edits.
///
/// Pending edits are saved first. If saving fails, the person chooses between
/// retrying, leaving anyway and staying. The app hiding or pausing also saves,
/// because a browser tab or backgrounded app may never come back.
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
  WindowCloseInterceptor? _windowCloseInterceptor;

  /// True once the person agreed to leave, so the next pop goes through.
  bool _mayPop = false;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onHide: _flushEdits,
      onPause: _flushEdits,
    );
    _windowCloseInterceptor = ref.read(windowCloseInterceptorProvider);
    unawaited(_windowCloseInterceptor?.startIntercepting(_onCloseRequested));
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    unawaited(_windowCloseInterceptor?.stopIntercepting());
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
  Future<bool> _confirmLeaving() async {
    await _commitFocusedField();
    while (true) {
      final status = _saveStatus;
      if (status == SaveStatus.pending || status == SaveStatus.saving) {
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
    // The route did not go anywhere, so the next attempt must ask again.
    if (!didPop && mounted) setState(() => _mayPop = false);
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
