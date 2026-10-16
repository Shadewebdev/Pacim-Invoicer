import 'package:freezed_annotation/freezed_annotation.dart';

part 'company_details.freezed.dart';
part 'company_details.g.dart';

@freezed
abstract class CompanyDetails with _$CompanyDetails {
  const factory CompanyDetails({
    @Default('') String companyName,
    @Default('') String registrationNumber,
    @Default(<String>[]) List<String> addressLines,
    @Default('') String phone,
    @Default('') String email,
    @Default('') String website,
    String? logoAssetId,
  }) = _CompanyDetails;

  factory CompanyDetails.fromJson(Map<String, dynamic> json) =>
      _$CompanyDetailsFromJson(json);
}
