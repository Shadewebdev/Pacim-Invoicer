import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_numbering_rule.freezed.dart';
part 'document_numbering_rule.g.dart';

/// Pattern such as `QT-{yyyy}-{seq:4}` and whether `{seq}` restarts each year.
@freezed
abstract class DocumentNumberingRule with _$DocumentNumberingRule {
  const factory DocumentNumberingRule({
    required String pattern,
    @Default(false) bool resetsYearly,
  }) = _DocumentNumberingRule;

  factory DocumentNumberingRule.fromJson(Map<String, dynamic> json) =>
      _$DocumentNumberingRuleFromJson(json);
}
