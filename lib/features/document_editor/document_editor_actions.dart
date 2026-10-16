import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/shell/navigation_leave_guard.dart';
import '../../domain/exceptions/document_exceptions.dart';
import '../../domain/models/business_document.dart';
import '../../data/repository_providers.dart';
import 'document_commands.dart';
import 'document_editor_controller.dart';
import 'document_editor_state.dart';

/// What the editor's command bar, breadcrumb and shortcuts do. Each command
/// first saves what is being typed, so a command never works from a stale copy
/// of the document, and reports problems in a SnackBar.
/// How many times pending edits are saved before giving up, because an edit can
/// land while a save is running.
const int _maximumFlushAttempts = 3;

class DocumentEditorActions {
  DocumentEditorActions({
    required this.context,
    required this.ref,
    required this.currentDocumentId,
    required this.restoreFocus,
  });

  /// The editor page's context, which must stay mounted while commands run.
  final BuildContext context;
  final WidgetRef ref;

  /// Read on every use because the page can switch to another document.
  final String Function() currentDocumentId;

  /// Gives keyboard focus back to the page after a field was blurred, so the
  /// page shortcuts keep receiving keys.
  final VoidCallback restoreFocus;

  bool _isRunning = false;

  DocumentEditorController get _controller =>
      ref.read(documentEditorControllerProvider(currentDocumentId()).notifier);

  BusinessDocument? get _document => ref
      .read(documentEditorControllerProvider(currentDocumentId()))
      .value
      ?.document;

  DocumentCommands get _commands => ref.read(documentCommandsProvider);

  /// Commits the focused field and saves, for the Save button and Ctrl+S.
  Future<void> save() => _runExclusively(() async {
    await _flushPendingEdits();
  });

  /// Upgrades [sourceDocumentId] and opens the document it created.
  Future<void> upgrade(String sourceDocumentId) => _runExclusively(() async {
    if (!await _flushPendingEdits(refusal: 'upgrading')) return;
    final sourceNumber = await _numberOf(sourceDocumentId);
    await _runCommand("Couldn't upgrade $sourceNumber. Try again.", () {
      return _openCreated(_commands.upgradeDocument(sourceDocumentId));
    });
  });

  /// Upgrades the document being edited, for the Upgrade button and its shortcut.
  Future<void> upgradeCurrent() => upgrade(currentDocumentId());

  /// Copies the document being edited into a new draft and opens it.
  Future<void> duplicate() => _runExclusively(() async {
    if (!await _flushPendingEdits(refusal: 'duplicating')) return;
    await _runCommand(
      "Couldn't duplicate ${_document?.documentNumber ?? 'the document'}. Try again.",
      () => _openCreated(_commands.duplicateDocument(currentDocumentId())),
    );
  });

  /// Starts a new document of the type being edited and opens it.
  Future<void> createSameType() => _runExclusively(() async {
    final type = _document?.documentType;
    if (type == null) return;
    await _runCommand(
      "Couldn't create the ${type.displayName.toLowerCase()}. Try again.",
      () => _openCreated(_commands.createDocument(type)),
    );
  });

  /// Asks, then deletes the draft being edited and returns to its list.
  Future<void> delete() => _runExclusively(() async {
    final document = _document;
    if (document == null || document.isLocked) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          "Delete ${document.documentNumber}? This can't be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            autofocus: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    // Holding autosave stops pending edits being written back over the delete.
    _controller.holdAutosave();
    var isDeleted = false;
    await _runCommand(
      "Couldn't delete ${document.documentNumber}. Try again.",
      () async {
        await _commands.deleteDocument(document.documentId);
        isDeleted = true;
        _controller.discardPendingChanges();
        if (!context.mounted) return;
        await goAfterLeaveGuard(
          context,
          ref,
          '/${document.documentType.routeSegment}',
        );
      },
    );
    // A failed delete keeps the edits, so saving carries on as before.
    if (!isDeleted) _controller.releaseAutosave();
  });

  /// Opens another document of the chain.
  Future<void> open(String documentId) =>
      goAfterLeaveGuard(context, ref, '/documents/$documentId');

  Future<void> _openCreated(Future<String> creating) async {
    final documentId = await creating;
    if (!context.mounted) return;
    await goAfterLeaveGuard(context, ref, '/documents/$documentId');
  }

  /// Blurs the focused field, waits for its text to be committed as an edit
  /// and saves. Returns false, after telling the person, when the save failed.
  Future<bool> _flushPendingEdits({String? refusal}) async {
    for (var attempt = 0; attempt < _maximumFlushAttempts; attempt++) {
      FocusManager.instance.primaryFocus?.unfocus();
      restoreFocus();
      await Future<void>.delayed(Duration.zero);
      await _controller.saveNow();
      final status = ref
          .read(documentEditorControllerProvider(currentDocumentId()))
          .value
          ?.saveStatus;
      if (status == null || status == SaveStatus.saved) return true;
      // A failed save will not get better by trying again straight away.
      if (status == SaveStatus.failed) break;
    }
    if (refusal != null) {
      _showProblem("Couldn't save — fix this before $refusal");
    }
    return false;
  }

  /// The number of [documentId] for messages, or a stand-in if unreadable.
  Future<String> _numberOf(String documentId) async {
    try {
      return (await ref
              .read(documentRepositoryProvider)
              .getDocument(documentId))
          .documentNumber;
    } on Object {
      return 'the document';
    }
  }

  /// Ignores a command that arrives while another is still running, such as a
  /// double click on Upgrade.
  Future<void> _runExclusively(Future<void> Function() command) async {
    if (_isRunning) return;
    _isRunning = true;
    try {
      await command();
    } finally {
      _isRunning = false;
    }
  }

  Future<void> _runCommand(
    String failureMessage,
    Future<void> Function() command,
  ) async {
    try {
      await command();
    } on InvalidUpgradeException catch (exception) {
      _showProblem(exception.reason);
    } on DocumentLockedException {
      _showProblem("This document is locked, so it can't be changed.");
    } on Object {
      _showProblem(failureMessage);
    }
  }

  void _showProblem(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)
        ?.showSnackBar(SnackBar(content: Text(message)));
  }
}
