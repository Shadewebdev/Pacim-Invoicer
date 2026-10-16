import 'package:pacim_invoicer/domain/services/id_generator.dart';

/// Test fake that hands out `id-1`, `id-2`, ... in order.
class SequentialIdGenerator implements IdGenerator {
  int _nextNumber = 1;

  @override
  String generateId() => 'id-${_nextNumber++}';
}
