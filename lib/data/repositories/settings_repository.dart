import 'package:pacim_invoicer/domain/models/document_settings.dart';

abstract interface class SettingsRepository {
  Stream<DocumentSettings> watchSettings();
  Future<void> saveSettings(DocumentSettings settings);
}
