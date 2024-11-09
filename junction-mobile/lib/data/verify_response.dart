import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'verify_response.g.dart';

abstract class VerifyResponse
    implements Built<VerifyResponse, VerifyResponseBuilder> {
  factory VerifyResponse([void Function(VerifyResponseBuilder) updates]) =
      _$VerifyResponse;

  VerifyResponse._();

  static Serializer<VerifyResponse> get serializer =>
      _$verifyResponseSerializer;

  @BuiltValueField(wireName: 'is_verified')
  bool get isVerified;

  @BuiltValueField(wireName: 'verification_id')
  String get verificationId;
}
