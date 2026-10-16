import 'package:pacim_invoicer/domain/services/id_generator.dart';
import 'package:uuid/uuid.dart';

/// Generates random (version 4) UUID strings.
class UuidIdGenerator implements IdGenerator {
  UuidIdGenerator([this._uuid = const Uuid()]);

  final Uuid _uuid;

  @override
  String generateId() => _uuid.v4();
}
