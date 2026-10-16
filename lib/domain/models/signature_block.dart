import 'package:freezed_annotation/freezed_annotation.dart';

part 'signature_block.freezed.dart';
part 'signature_block.g.dart';

@freezed
abstract class SignatureBlock with _$SignatureBlock {
  const factory SignatureBlock({
    @Default('') String signatoryName,
    @Default('') String signatoryTitle,
    String? signatureAssetId,
    @Default('') String signatureCaption,
  }) = _SignatureBlock;

  factory SignatureBlock.fromJson(Map<String, dynamic> json) =>
      _$SignatureBlockFromJson(json);
}
