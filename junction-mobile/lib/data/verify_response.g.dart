// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<VerifyResponse> _$verifyResponseSerializer =
    new _$VerifyResponseSerializer();

class _$VerifyResponseSerializer
    implements StructuredSerializer<VerifyResponse> {
  @override
  final Iterable<Type> types = const [VerifyResponse, _$VerifyResponse];
  @override
  final String wireName = 'VerifyResponse';

  @override
  Iterable<Object?> serialize(Serializers serializers, VerifyResponse object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'is_verified',
      serializers.serialize(object.isVerified,
          specifiedType: const FullType(bool)),
      'verification_id',
      serializers.serialize(object.verificationId,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  VerifyResponse deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new VerifyResponseBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'is_verified':
          result.isVerified = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
        case 'verification_id':
          result.verificationId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$VerifyResponse extends VerifyResponse {
  @override
  final bool isVerified;
  @override
  final String verificationId;

  factory _$VerifyResponse([void Function(VerifyResponseBuilder)? updates]) =>
      (new VerifyResponseBuilder()..update(updates))._build();

  _$VerifyResponse._({required this.isVerified, required this.verificationId})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        isVerified, r'VerifyResponse', 'isVerified');
    BuiltValueNullFieldError.checkNotNull(
        verificationId, r'VerifyResponse', 'verificationId');
  }

  @override
  VerifyResponse rebuild(void Function(VerifyResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VerifyResponseBuilder toBuilder() =>
      new VerifyResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VerifyResponse &&
        isVerified == other.isVerified &&
        verificationId == other.verificationId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, isVerified.hashCode);
    _$hash = $jc(_$hash, verificationId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VerifyResponse')
          ..add('isVerified', isVerified)
          ..add('verificationId', verificationId))
        .toString();
  }
}

class VerifyResponseBuilder
    implements Builder<VerifyResponse, VerifyResponseBuilder> {
  _$VerifyResponse? _$v;

  bool? _isVerified;
  bool? get isVerified => _$this._isVerified;
  set isVerified(bool? isVerified) => _$this._isVerified = isVerified;

  String? _verificationId;
  String? get verificationId => _$this._verificationId;
  set verificationId(String? verificationId) =>
      _$this._verificationId = verificationId;

  VerifyResponseBuilder();

  VerifyResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _isVerified = $v.isVerified;
      _verificationId = $v.verificationId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VerifyResponse other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$VerifyResponse;
  }

  @override
  void update(void Function(VerifyResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VerifyResponse build() => _build();

  _$VerifyResponse _build() {
    final _$result = _$v ??
        new _$VerifyResponse._(
            isVerified: BuiltValueNullFieldError.checkNotNull(
                isVerified, r'VerifyResponse', 'isVerified'),
            verificationId: BuiltValueNullFieldError.checkNotNull(
                verificationId, r'VerifyResponse', 'verificationId'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
