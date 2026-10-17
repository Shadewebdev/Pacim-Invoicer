import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/data/repositories/number_sequence_repository.dart';
import 'package:pacim_invoicer/domain/models/document_type.dart';

/// Behaviour every [NumberSequenceRepository] implementation must satisfy.
///
/// Every call to [createRepository] must return a fresh, empty repository.
void runNumberSequenceRepositoryContract(
  Future<NumberSequenceRepository> Function() createRepository,
) {
  group('NumberSequenceRepository contract', () {
    late NumberSequenceRepository repository;

    setUp(() async {
      repository = await createRepository();
    });

    Future<int> allocate(
      DocumentType type, {
      int year = 2026,
      bool resetsYearly = false,
    }) {
      return repository.allocateNextSequence(
        type,
        year: year,
        resetsYearly: resetsYearly,
      );
    }

    test('first allocation is 1 and increments', () async {
      expect(await allocate(DocumentType.quotation), 1);
      expect(await allocate(DocumentType.quotation), 2);
      expect(await allocate(DocumentType.quotation), 3);
    });

    test('types have independent counters', () async {
      expect(await allocate(DocumentType.quotation), 1);
      expect(await allocate(DocumentType.quotation), 2);
      expect(await allocate(DocumentType.salesOrder), 1);
      expect(await allocate(DocumentType.deliveryOrder), 1);
      expect(await allocate(DocumentType.salesOrder), 2);
      expect(await allocate(DocumentType.quotation), 3);
    });

    test(
      'yearly reset starts at 1 in a new year; non-resetting continues',
      () async {
        expect(await allocate(DocumentType.quotation, resetsYearly: true), 1);
        expect(await allocate(DocumentType.quotation, resetsYearly: true), 2);
        expect(
          await allocate(
            DocumentType.quotation,
            year: 2027,
            resetsYearly: true,
          ),
          1,
        );

        expect(await allocate(DocumentType.salesOrder), 1);
        expect(await allocate(DocumentType.salesOrder), 2);
        expect(await allocate(DocumentType.salesOrder, year: 2027), 3);
      },
    );

    test(
      'turning yearly reset on mid-year continues above numbers of this year',
      () async {
        expect(await allocate(DocumentType.quotation, year: 2025), 1);
        expect(await allocate(DocumentType.quotation), 2);
        expect(await allocate(DocumentType.quotation), 3);

        expect(await allocate(DocumentType.quotation, resetsYearly: true), 4);
        expect(
          await allocate(
            DocumentType.quotation,
            year: 2027,
            resetsYearly: true,
          ),
          1,
        );
      },
    );

    test('turning yearly reset off continues above every number', () async {
      expect(await allocate(DocumentType.quotation, year: 2025), 1);
      for (var expected = 1; expected <= 5; expected++) {
        expect(
          await allocate(DocumentType.quotation, resetsYearly: true),
          expected,
        );
      }

      expect(await allocate(DocumentType.quotation), 6);
      // And back on in the same year: still above everything issued in it.
      expect(await allocate(DocumentType.quotation, resetsYearly: true), 7);
    });

    test('peekNextSequence tells the next sequence without using it', () async {
      Future<int> peek({int year = 2026, bool resetsYearly = false}) =>
          repository.peekNextSequence(
            DocumentType.quotation,
            year: year,
            resetsYearly: resetsYearly,
          );

      expect(await peek(), 1);
      expect(await allocate(DocumentType.quotation), 1);
      expect(await allocate(DocumentType.quotation), 2);
      expect(await peek(), 3);
      expect(await peek(), 3);
      expect(await peek(resetsYearly: true), 3);
      expect(await peek(year: 2027, resetsYearly: true), 1);
      expect(await allocate(DocumentType.quotation), 3);
    });

    test('20 concurrent allocations return 1..20 with no duplicates', () async {
      final results = await Future.wait([
        for (var i = 0; i < 20; i++) allocate(DocumentType.deliveryOrder),
      ]);
      expect(results.toList()..sort(), List.generate(20, (i) => i + 1));
      expect(await allocate(DocumentType.deliveryOrder), 21);
    });
  });
}
