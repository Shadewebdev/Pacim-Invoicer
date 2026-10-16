/// Renders and validates document number patterns such as `QT-{yyyy}-{seq:4}`.
///
/// Tokens: `{yyyy}`, `{yy}`, `{mm}` and `{seq:N}` (N = 1-9, zero-padded; a
/// longer sequence is never truncated).
class DocumentNumberFormatter {
  const DocumentNumberFormatter();

  static final RegExp _tokenPattern = RegExp(r'\{([^}]*)\}');
  static final RegExp _sequenceTokenPattern = RegExp(r'^seq:([1-9])$');

  String format(
    String pattern, {
    required int sequence,
    required DateTime date,
  }) {
    return pattern.replaceAllMapped(_tokenPattern, (match) {
      final token = match.group(1)!;
      switch (token) {
        case 'yyyy':
          return date.year.toString().padLeft(4, '0');
        case 'yy':
          return (date.year % 100).toString().padLeft(2, '0');
        case 'mm':
          return date.month.toString().padLeft(2, '0');
      }
      final sequenceMatch = _sequenceTokenPattern.firstMatch(token);
      if (sequenceMatch != null) {
        final width = int.parse(sequenceMatch.group(1)!);
        return sequence.toString().padLeft(width, '0');
      }
      return match.group(0)!;
    });
  }

  /// User-facing reasons the [pattern] cannot produce unique numbers.
  List<String> findPatternProblems(String pattern) {
    final problems = <String>[];
    var sequenceTokenCount = 0;
    for (final match in _tokenPattern.allMatches(pattern)) {
      final token = match.group(1)!;
      if (_sequenceTokenPattern.hasMatch(token)) {
        sequenceTokenCount++;
      } else if (token != 'yyyy' && token != 'yy' && token != 'mm') {
        problems.add('Unknown token {$token}');
      }
    }
    if (sequenceTokenCount == 0) {
      problems.add('Add {seq:N} so each number is unique');
    } else if (sequenceTokenCount > 1) {
      problems.add('Use {seq:N} only once');
    }
    return problems;
  }
}
