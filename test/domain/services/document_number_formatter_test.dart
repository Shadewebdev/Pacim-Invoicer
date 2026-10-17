import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/domain/services/document_number_formatter.dart';

void main() {
  const formatter = DocumentNumberFormatter();
  final date = DateTime(2026, 3, 9);

  test('formats tokens', () {
    expect(
      formatter.format('QT-{yyyy}-{seq:4}', sequence: 7, date: date),
      'QT-2026-0007',
    );
    expect(
      formatter.format('SO{yy}{mm}/{seq:3}', sequence: 12, date: date),
      'SO2603/012',
    );
  });

  test('a longer sequence is not truncated', () {
    expect(
      formatter.format('DO-{seq:2}', sequence: 1234, date: date),
      'DO-1234',
    );
  });

  test('reports pattern problems', () {
    expect(formatter.findPatternProblems('QT-{yyyy}', resetsYearly: false), [
      'Add {seq:N} so each number is unique',
    ]);
    expect(
      formatter.findPatternProblems('QT-{dd}-{seq:4}', resetsYearly: false),
      ['Unknown token {dd}'],
    );
    expect(
      formatter.findPatternProblems('QT-{yyyy}-{seq:4}', resetsYearly: true),
      isEmpty,
    );
    expect(
      formatter.findPatternProblems('{seq:2}{seq:3}', resetsYearly: false),
      ['Use {seq:N} only once'],
    );
    expect(formatter.findPatternProblems('{seq:0}', resetsYearly: false), [
      'Unknown token {seq:0}',
      'Add {seq:N} so each number is unique',
    ]);
  });

  test('a yearly reset needs a year token', () {
    expect(formatter.findPatternProblems('QT-{seq:4}', resetsYearly: true), [
      'Add {yyyy} or {yy} so yearly numbers stay unique',
    ]);
    expect(
      formatter.findPatternProblems('QT-{seq:4}', resetsYearly: false),
      isEmpty,
    );
    expect(
      formatter.findPatternProblems('QT{yy}-{seq:4}', resetsYearly: true),
      isEmpty,
    );
  });
}
