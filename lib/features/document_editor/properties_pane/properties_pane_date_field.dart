import 'package:flutter/material.dart';

import '../../../app/theme/app_typography.dart';
import '../../../shared/formatting/date_formatter.dart';

/// A labelled date that opens the date picker when tapped. Passing
/// [onCleared] adds a clear button, for dates that are optional.
class PropertiesPaneDateField extends StatelessWidget {
  const PropertiesPaneDateField({
    required this.label,
    required this.date,
    required this.fallbackPickerDate,
    required this.onChanged,
    this.onCleared,
    this.isEnabled = true,
    super.key,
  });

  final String label;
  final DateTime? date;

  /// What the picker opens on when [date] is not set.
  final DateTime fallbackPickerDate;
  final ValueChanged<DateTime> onChanged;
  final VoidCallback? onCleared;
  final bool isEnabled;

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date ?? fallbackPickerDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = date;
    final canClear = onCleared != null && currentDate != null && isEnabled;
    return InkWell(
      onTap: isEnabled ? () => _pick(context) : null,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        isEmpty: currentDate == null,
        decoration: InputDecoration(
          labelText: label,
          enabled: isEnabled,
          suffixIcon: canClear
              ? IconButton(
                  tooltip: 'Clear ${label.toLowerCase()}',
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: onCleared,
                )
              : const Icon(Icons.calendar_today_outlined, size: 16),
        ),
        child: Text(
          currentDate == null ? '' : formatDocumentDate(currentDate),
          style: const TextStyle(fontSize: AppTypography.field),
        ),
      ),
    );
  }
}
