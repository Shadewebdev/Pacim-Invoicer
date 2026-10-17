import 'package:pacim_invoicer/domain/models/document_type.dart';

abstract interface class NumberSequenceRepository {
  Future<int> allocateNextSequence(
    DocumentType type, {
    required int year,
    required bool resetsYearly,
  });

  /// The sequence [allocateNextSequence] would return now, without using it,
  /// for previews. Another allocation may take it first.
  Future<int> peekNextSequence(
    DocumentType type, {
    required int year,
    required bool resetsYearly,
  });
}
