import 'package:pacim_invoicer/domain/models/document_type.dart';

abstract interface class NumberSequenceRepository {
  Future<int> allocateNextSequence(
    DocumentType type, {
    required int year,
    required bool resetsYearly,
  });
}
