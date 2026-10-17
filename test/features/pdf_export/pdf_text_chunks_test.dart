import 'package:flutter_test/flutter_test.dart';
import 'package:pacim_invoicer/features/pdf_export/pdf_text_chunks.dart';

String _withoutWhitespace(String text) => text.replaceAll(RegExp(r'\s'), '');

int _estimatedLines(String chunk, int charsPerLine) => chunk
    .split('\n')
    .map((line) => line.isEmpty ? 1 : (line.length / charsPerLine).ceil())
    .fold(0, (sum, lines) => sum + lines);

void main() {
  test('short text stays one unchanged chunk', () {
    expect(splitTextIntoChunks('Steel bracket\nGalvanised', charsPerLine: 30), [
      'Steel bracket\nGalvanised',
    ]);
  });

  test('empty text is one empty chunk', () {
    expect(splitTextIntoChunks('', charsPerLine: 30), ['']);
  });

  test('multi-line text breaks at its own line breaks', () {
    final lines = [for (var i = 0; i < 20; i++) 'Line $i'];
    final chunks = splitTextIntoChunks(
      lines.join('\n'),
      charsPerLine: 30,
      maxLinesPerChunk: 6,
    );
    expect(chunks, hasLength(4));
    expect(chunks.first, lines.take(6).join('\n'));
    expect(chunks.join('\n'), lines.join('\n'));
  });

  test('an oversize paragraph splits at word boundaries and keeps words', () {
    final paragraph = List.filled(200, 'word').join(' ');
    final chunks = splitTextIntoChunks(
      paragraph,
      charsPerLine: 20,
      maxLinesPerChunk: 6,
    );
    expect(chunks.length, greaterThan(1));
    for (final chunk in chunks) {
      expect(_estimatedLines(chunk, 20), lessThanOrEqualTo(6));
      expect(chunk.split(' '), everyElement('word'));
    }
    expect(chunks.join(' '), paragraph);
  });

  test('a word longer than a line is split so chunks stay bounded', () {
    final word = 'x' * 500;
    final chunks = splitTextIntoChunks(
      word,
      charsPerLine: 20,
      maxLinesPerChunk: 6,
    );
    for (final chunk in chunks) {
      expect(chunk.length, lessThanOrEqualTo(120));
    }
    expect(chunks.join(), word);
  });

  test('a paragraph that fits a fresh chunk is not split mid-line', () {
    final chunks = splitTextIntoChunks(
      'a\nb\nc\nd\n${List.filled(10, 'word').join(' ')}',
      charsPerLine: 20,
      maxLinesPerChunk: 6,
    );
    expect(chunks, ['a\nb\nc\nd', List.filled(10, 'word').join(' ')]);
  });

  test('chunks rejoined keep every character of the text', () {
    final text = '${'Long description ' * 120}\n\nSecond paragraph\nend';
    final chunks = splitTextIntoChunks(text, charsPerLine: 25);
    expect(_withoutWhitespace(chunks.join()), _withoutWhitespace(text));
  });

  test('cuts never split a character outside the basic plane', () {
    final word = '😀' * 50;
    final chunks = splitTextIntoChunks(
      word,
      charsPerLine: 7,
      maxLinesPerChunk: 1,
    );
    expect(chunks.length, greaterThan(1));
    for (final chunk in chunks) {
      expect(chunk.runes.every((rune) => rune == 0x1F600), isTrue);
      expect(chunk.runes.length, lessThanOrEqualTo(7));
    }
    expect(chunks.join(), word);
  });
}
