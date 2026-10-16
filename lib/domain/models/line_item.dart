import 'package:freezed_annotation/freezed_annotation.dart';

part 'line_item.freezed.dart';
part 'line_item.g.dart';

/// One row of a document. Quantity is scaled by 1000, discount by 100.
@freezed
abstract class LineItem with _$LineItem {
  const factory LineItem({
    required String lineItemId,
    String? sourceLineItemId,
    @Default('') String description,
    @Default('') String unit,
    @Default(1000) int quantityScaled,
    @Default(0) int unitPriceMinor,
    @Default(0) int discountPercentScaled,
  }) = _LineItem;

  factory LineItem.fromJson(Map<String, dynamic> json) =>
      _$LineItemFromJson(json);
}
