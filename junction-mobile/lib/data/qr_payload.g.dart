// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<QrPayload> _$qrPayloadSerializer = new _$QrPayloadSerializer();

class _$QrPayloadSerializer implements StructuredSerializer<QrPayload> {
  @override
  final Iterable<Type> types = const [QrPayload, _$QrPayload];
  @override
  final String wireName = 'QrPayload';

  @override
  Iterable<Object?> serialize(Serializers serializers, QrPayload object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'session_key',
      serializers.serialize(object.sessionKey,
          specifiedType: const FullType(String)),
      'expires_at',
      serializers.serialize(object.expiresAt,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  QrPayload deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new QrPayloadBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'session_key':
          result.sessionKey = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'expires_at':
          result.expiresAt = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$QrPayload extends QrPayload {
  @override
  final String sessionKey;
  @override
  final String expiresAt;

  factory _$QrPayload([void Function(QrPayloadBuilder)? updates]) =>
      (new QrPayloadBuilder()..update(updates))._build();

  _$QrPayload._({required this.sessionKey, required this.expiresAt})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        sessionKey, r'QrPayload', 'sessionKey');
    BuiltValueNullFieldError.checkNotNull(expiresAt, r'QrPayload', 'expiresAt');
  }

  @override
  QrPayload rebuild(void Function(QrPayloadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  QrPayloadBuilder toBuilder() => new QrPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is QrPayload &&
        sessionKey == other.sessionKey &&
        expiresAt == other.expiresAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sessionKey.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'QrPayload')
          ..add('sessionKey', sessionKey)
          ..add('expiresAt', expiresAt))
        .toString();
  }
}

class QrPayloadBuilder implements Builder<QrPayload, QrPayloadBuilder> {
  _$QrPayload? _$v;

  String? _sessionKey;
  String? get sessionKey => _$this._sessionKey;
  set sessionKey(String? sessionKey) => _$this._sessionKey = sessionKey;

  String? _expiresAt;
  String? get expiresAt => _$this._expiresAt;
  set expiresAt(String? expiresAt) => _$this._expiresAt = expiresAt;

  QrPayloadBuilder();

  QrPayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sessionKey = $v.sessionKey;
      _expiresAt = $v.expiresAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(QrPayload other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$QrPayload;
  }

  @override
  void update(void Function(QrPayloadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  QrPayload build() => _build();

  _$QrPayload _build() {
    final _$result = _$v ??
        new _$QrPayload._(
            sessionKey: BuiltValueNullFieldError.checkNotNull(
                sessionKey, r'QrPayload', 'sessionKey'),
            expiresAt: BuiltValueNullFieldError.checkNotNull(
                expiresAt, r'QrPayload', 'expiresAt'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
