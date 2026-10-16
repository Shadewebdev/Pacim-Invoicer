import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/shell/status_bar_message_provider.dart';
import '../../app/theme/theme_mode_provider.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repository_providers.dart';
import '../../domain/models/company_details.dart';
import '../../domain/models/document_layout_options.dart';
import '../../domain/models/document_numbering_rule.dart';
import '../../domain/models/document_settings.dart';
import '../../domain/models/document_type.dart';
import '../../domain/models/pricing_terms.dart';
import '../../domain/models/signature_block.dart';
import '../../domain/services/document_number_formatter.dart';

const Duration _saveDebounce = Duration(milliseconds: 600);
const DocumentNumberFormatter _numberFormatter = DocumentNumberFormatter();

/// Holds the global settings, saves edits 600 ms after the last change and
/// keeps the app theme mode in step with the appearance setting.
class SettingsController extends AsyncNotifier<DocumentSettings> {
  late SettingsRepository _settingsRepository;
  Timer? _saveTimer;
  DocumentSettings? _pendingSettings;
  Future<void> _lastSave = Future<void>.value();

  @override
  Future<DocumentSettings> build() async {
    _settingsRepository = ref.read(settingsRepositoryProvider);
    ref.onDispose(_flushPendingSaveOnDispose);
    final settings = await _settingsRepository.watchSettings().first;
    _applyThemeMode(settings.appearance);
    return settings;
  }

  /// Reasons [pattern] cannot be saved as a numbering rule; empty when valid.
  List<String> findNumberingPatternProblems(String pattern) =>
      _numberFormatter.findPatternProblems(pattern);

  void updateCompanyDetails(CompanyDetails companyDetails) => _applyChange(
    (current) => current.copyWith(companyDetails: companyDetails),
  );

  void updateLayoutOptions(DocumentType type, DocumentLayoutOptions options) =>
      _applyChange(
        (current) => current.copyWith(
          layoutOptionsByType: {...current.layoutOptionsByType, type: options},
        ),
      );

  void updatePricingTerms(PricingTerms pricingTerms) =>
      _applyChange((current) => current.copyWith(pricingTerms: pricingTerms));

  void updateDefaultTerms(DocumentType type, String terms) => _applyChange(
    (current) => current.copyWith(
      defaultTermsByType: {...current.defaultTermsByType, type: terms},
    ),
  );

  /// Ignores values outside 1 to 365 days.
  void updateQuotationValidityDays(int days) {
    if (days < 1 || days > 365) return;
    _applyChange((current) => current.copyWith(quotationValidityDays: days));
  }

  void updateFooterNote(String footerNote) => _applyChange(
    (current) => current.copyWith(defaultFooterNote: footerNote),
  );

  void updateSignatureBlock(DocumentType type, SignatureBlock signatureBlock) =>
      _applyChange(
        (current) => current.copyWith(
          signatureBlockByType: {
            ...current.signatureBlockByType,
            type: signatureBlock,
          },
        ),
      );

  /// Ignores a rule whose pattern has problems; everything else still saves.
  void updateNumberingRule(DocumentType type, DocumentNumberingRule rule) {
    if (findNumberingPatternProblems(rule.pattern).isNotEmpty) return;
    _applyChange(
      (current) => current.copyWith(
        numberingRuleByType: {...current.numberingRuleByType, type: rule},
      ),
    );
  }

  /// [appearance] is `system`, `light` or `dark`.
  void updateAppearance(String appearance) {
    _applyChange((current) => current.copyWith(appearance: appearance));
    _applyThemeMode(appearance);
  }

  /// Throws `ImageImportException` when [originalBytes] is not an image.
  Future<void> importCompanyLogo(Uint8List originalBytes) async {
    final assetId = await _storePreparedImage(originalBytes);
    final current = state.value;
    if (current == null) return;
    updateCompanyDetails(current.companyDetails.copyWith(logoAssetId: assetId));
  }

  /// Throws `ImageImportException` when [originalBytes] is not an image.
  Future<void> importSignatureImage(
    DocumentType type,
    Uint8List originalBytes,
  ) async {
    final assetId = await _storePreparedImage(originalBytes);
    final current = state.value;
    if (current == null) return;
    updateSignatureBlock(
      type,
      current.signatureBlockByType[type]!.copyWith(signatureAssetId: assetId),
    );
  }

  Future<String> _storePreparedImage(Uint8List originalBytes) async {
    final prepared = await ref
        .read(imageImportServiceProvider)
        .prepareImageForStorage(originalBytes);
    return ref.read(assetRepositoryProvider).storeImage(prepared);
  }

  void _applyChange(DocumentSettings Function(DocumentSettings) change) {
    final current = state.value;
    if (current == null) return;
    final next = change(current);
    if (next == current) return;
    state = AsyncData(next);
    _pendingSettings = next;
    _saveTimer?.cancel();
    _saveTimer = Timer(_saveDebounce, _savePendingSettings);
  }

  void _applyThemeMode(String appearance) {
    ref.read(themeModeProvider.notifier).setThemeMode(switch (appearance) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    });
  }

  void _savePendingSettings() {
    final settings = _pendingSettings;
    if (settings == null) return;
    _pendingSettings = null;
    _lastSave = _lastSave.then((_) async {
      try {
        await _settingsRepository.saveSettings(settings);
      } on Object {
        if (ref.mounted) {
          ref
              .read(statusBarMessageProvider.notifier)
              .showMessage("Couldn't save settings");
        }
      }
    });
  }

  void _flushPendingSaveOnDispose() {
    _saveTimer?.cancel();
    final settings = _pendingSettings;
    if (settings == null) return;
    _pendingSettings = null;
    final repository = _settingsRepository;
    final previousSave = _lastSave;
    // Nothing is left to report to once the provider is gone.
    unawaited(
      previousSave
          .then((_) => repository.saveSettings(settings))
          .catchError((Object _) {}),
    );
  }
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, DocumentSettings>(
      SettingsController.new,
    );
