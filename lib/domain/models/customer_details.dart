import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_details.freezed.dart';
part 'customer_details.g.dart';

@freezed
abstract class CustomerDetails with _$CustomerDetails {
  const factory CustomerDetails({
    @Default('') String customerName,
    @Default('') String attentionTo,
    @Default(<String>[]) List<String> addressLines,
    @Default('') String phone,
    @Default('') String email,
    @Default(<String>[]) List<String> deliveryAddressLines,
  }) = _CustomerDetails;

  factory CustomerDetails.fromJson(Map<String, dynamic> json) =>
      _$CustomerDetailsFromJson(json);
}
