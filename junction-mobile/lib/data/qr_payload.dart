import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'qr_payload.g.dart';

abstract class QrPayload implements Built<QrPayload, QrPayloadBuilder> {
  factory QrPayload([void Function(QrPayloadBuilder) updates]) = _$QrPayload;

  QrPayload._();

  static Serializer<QrPayload> get serializer => _$qrPayloadSerializer;

  @BuiltValueField(wireName: 'session_key')
  String get sessionKey;

  @BuiltValueField(wireName: 'expires_at')
  String get expiresAt;
}
