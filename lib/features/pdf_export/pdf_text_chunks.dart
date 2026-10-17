/// How many estimated lines one chunk of text may hold. A chunk is never
/// split across pages, so this bounds the white space a page break leaves.
const int defaultMaxLinesPerChunk = 6;

/// Splits [text] into chunks of at most [maxLinesPerChunk] estimated lines
/// of [charsPerLine] characters, so that each chunk can be laid out as a
/// widget that always fits on one page.
///
/// The `pdf` package cannot split a table row or a column child across
/// pages, so long text is cut into bounded pieces that the page breaks can
/// fall between. Chunks break at the text's own line breaks where possible;
/// only a paragraph too long for a whole chunk is cut, at word boundaries
/// (or inside a word longer than a line). No character other than the
/// line break or space at a cut is lost.
List<String> splitTextIntoChunks(
  String text, {
  required int charsPerLine,
  int maxLinesPerChunk = defaultMaxLinesPerChunk,
}) {
  assert(charsPerLine > 0 && maxLinesPerChunk > 0);
  final chunks = <String>[];
  final chunk = StringBuffer();
  var linesInChunk = 0;

  void flush() {
    chunks.add(chunk.toString());
    chunk.clear();
    linesInChunk = 0;
  }

  final paragraphs = text.replaceAll('\r\n', '\n').split('\n');
  for (final paragraph in paragraphs) {
    final lines = _estimateLines(paragraph, charsPerLine);
    // Keep a paragraph whole when it fits in a chunk of its own.
    if (linesInChunk > 0 &&
        linesInChunk + lines.length > maxLinesPerChunk &&
        lines.length <= maxLinesPerChunk) {
      flush();
    }
    for (var index = 0; index < lines.length; index++) {
      if (linesInChunk == maxLinesPerChunk) flush();
      if (linesInChunk > 0) {
        chunk.write(index == 0 ? '\n' : lines[index].separatorBefore);
      }
      chunk.write(lines[index].text);
      linesInChunk++;
    }
  }
  if (linesInChunk > 0 || chunks.isEmpty) flush();
  return chunks;
}

/// One estimated line of a paragraph and what joined it to the line before.
typedef _EstimatedLine = ({String text, String separatorBefore});

/// Greedy word wrap of [paragraph]; an empty paragraph is one empty line.
/// Lengths and cuts count Unicode code points, so a cut never splits a
/// surrogate pair.
List<_EstimatedLine> _estimateLines(String paragraph, int charsPerLine) {
  final lines = <_EstimatedLine>[];
  String? line;
  var lineLength = 0;
  var lineSeparator = '';

  void startLine(String separator, List<int> runes) {
    if (line != null) lines.add((text: line!, separatorBefore: lineSeparator));
    line = String.fromCharCodes(runes);
    lineLength = runes.length;
    lineSeparator = separator;
  }

  final words = paragraph.split(' ');
  for (var index = 0; index < words.length; index++) {
    final joiner = index == 0 ? '' : ' ';
    final word = words[index];
    final wordRunes = word.runes.toList();
    final current = line;
    if (current != null &&
        lineLength + joiner.length + wordRunes.length <= charsPerLine) {
      line = '$current$joiner$word';
      lineLength += joiner.length + wordRunes.length;
      continue;
    }
    // A word longer than a line is cut into line-sized pieces.
    var separator = joiner;
    var rest = wordRunes;
    while (rest.length > charsPerLine) {
      startLine(separator, rest.sublist(0, charsPerLine));
      rest = rest.sublist(charsPerLine);
      separator = '';
    }
    startLine(separator, rest);
  }
  lines.add((text: line ?? '', separatorBefore: lineSeparator));
  return lines;
}
