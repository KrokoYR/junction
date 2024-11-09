import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sign_response.g.dart';

abstract class SignResponse
    implements Built<SignResponse, SignResponseBuilder> {
  factory SignResponse([void Function(SignResponseBuilder) updates]) =
      _$SignResponse;

  SignResponse._();

  static Serializer<SignResponse> get serializer => _$signResponseSerializer;

  @BuiltValueField(wireName: 'is_valid')
  bool get isValid;
}
