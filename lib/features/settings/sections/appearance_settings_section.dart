import 'package:flutter/material.dart';

import '../../../domain/models/document_settings.dart';
import '../settings_controller.dart';
import '../settings_fields.dart';

class AppearanceSettingsSection extends StatelessWidget {
  const AppearanceSettingsSection({
    required this.settings,
    required this.controller,
    super.key,
  });

  final DocumentSettings settings;
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionLayout(
      title: 'Appearance',
      children: [
        SegmentedButton<String>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 'system', label: Text('Use system setting')),
            ButtonSegment(value: 'light', label: Text('Light')),
            ButtonSegment(value: 'dark', label: Text('Dark')),
          ],
          selected: {settings.appearance},
          onSelectionChanged: (selection) =>
              controller.updateAppearance(selection.single),
        ),
      ],
    );
  }
}
