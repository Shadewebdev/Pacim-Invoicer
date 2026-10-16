import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_color_tokens.dart';
import '../../app/theme/app_typography.dart';
import '../../data/repository_providers.dart';
import '../../domain/models/document_settings.dart';
import '../../domain/models/document_type.dart';
import '../../domain/services/document_number_formatter.dart';
import 'asset_image_provider.dart';
import 'header_preview.dart';
import 'sections/appearance_settings_section.dart';
import 'sections/company_settings_section.dart';
import 'sections/header_footer_settings_section.dart';
import 'sections/numbering_settings_section.dart';
import 'sections/pricing_settings_section.dart';
import 'sections/signature_settings_section.dart';
import 'settings_controller.dart';

const double _previewMinimumWidth = 900;
const double _previewPaneWidth = 340;
const double _subNavigationWidth = 190;
const double _stackedNavigationMaximumWidth = 640;

enum _SettingsSection {
  company('Company'),
  headerFooter('Header & footer'),
  pricing('Pricing & currency'),
  signature('Signature'),
  numbering('Numbering'),
  appearance('Appearance');

  const _SettingsSection(this.label);

  final String label;
}

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  _SettingsSection _section = _SettingsSection.company;
  DocumentType _selectedType = DocumentType.quotation;

  @override
  Widget build(BuildContext context) {
    final settingsValue = ref.watch(settingsControllerProvider);
    return settingsValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          const Center(child: Text("Couldn't load settings")),
      data: _buildPage,
    );
  }

  Widget _buildPage(DocumentSettings settings) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorTokens>()!;
    final controller = ref.read(settingsControllerProvider.notifier);
    final previewDate = ref.read(clockProvider)();
    final selectedRule = settings.numberingRuleByType[_selectedType]!;
    final sampleDocumentNumber = const DocumentNumberFormatter().format(
      selectedRule.pattern,
      sequence: 1,
      date: previewDate,
    );
    final logoAssetId = settings.companyDetails.logoAssetId;
    final logoBytes = logoAssetId == null
        ? null
        : ref.watch(assetImageBytesProvider(logoAssetId)).value;

    final form = switch (_section) {
      _SettingsSection.company => CompanySettingsSection(
        settings: settings,
        controller: controller,
      ),
      _SettingsSection.headerFooter => HeaderFooterSettingsSection(
        settings: settings,
        controller: controller,
        selectedType: _selectedType,
        onTypeSelected: _selectType,
      ),
      _SettingsSection.pricing => PricingSettingsSection(
        settings: settings,
        controller: controller,
      ),
      _SettingsSection.signature => SignatureSettingsSection(
        settings: settings,
        controller: controller,
        selectedType: _selectedType,
        onTypeSelected: _selectType,
      ),
      _SettingsSection.numbering => NumberingSettingsSection(
        settings: settings,
        controller: controller,
        selectedType: _selectedType,
        onTypeSelected: _selectType,
        previewDate: previewDate,
      ),
      _SettingsSection.appearance => AppearanceSettingsSection(
        settings: settings,
        controller: controller,
      ),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final showsPreview = constraints.maxWidth >= _previewMinimumWidth;
        final stacksNavigation =
            constraints.maxWidth < _stackedNavigationMaximumWidth;
        final navigation = _SettingsNavigation(
          selected: _section,
          isHorizontal: stacksNavigation,
          onSelected: (section) => setState(() => _section = section),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text(
                    'Changes apply to new documents. Existing documents keep their own copy.',
                    style: TextStyle(
                      fontSize: AppTypography.body,
                      color: tokens.ink.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: stacksNavigation
                  ? Column(
                      children: [
                        navigation,
                        const Divider(),
                        Expanded(child: form),
                      ],
                    )
                  : Row(
                      children: [
                        SizedBox(width: _subNavigationWidth, child: navigation),
                        const VerticalDivider(),
                        Expanded(child: form),
                        if (showsPreview) ...[
                          const VerticalDivider(),
                          SizedBox(
                            width: _previewPaneWidth,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: HeaderPreview(
                                settings: settings,
                                documentType: _selectedType,
                                sampleDocumentNumber: sampleDocumentNumber,
                                logoBytes: logoBytes,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  void _selectType(DocumentType type) => setState(() => _selectedType = type);
}

class _SettingsNavigation extends StatelessWidget {
  const _SettingsNavigation({
    required this.selected,
    required this.isHorizontal,
    required this.onSelected,
  });

  final _SettingsSection selected;
  final bool isHorizontal;
  final ValueChanged<_SettingsSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final items = [
      for (final section in _SettingsSection.values)
        _SettingsNavigationItem(
          label: section.label,
          isSelected: section == selected,
          onTap: () => onSelected(section),
        ),
    ];
    if (isHorizontal) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(children: items),
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      children: items,
    );
  }
}

class _SettingsNavigationItem extends StatelessWidget {
  const _SettingsNavigationItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorTokens>()!;
    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: isSelected ? tokens.chrome : null,
            border: Border(
              left: BorderSide(
                color: isSelected ? tokens.action : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppTypography.body,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
