// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<SignResponse> _$signResponseSerializer =
    new _$SignResponseSerializer();

class _$SignResponseSerializer implements StructuredSerializer<SignResponse> {
  @override
  final Iterable<Type> types = const [SignResponse, _$SignResponse];
  @override
  final String wireName = 'SignResponse';

  @override
  Iterable<Object?> serialize(Serializers serializers, SignResponse object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'is_valid',
      serializers.serialize(object.isValid,
          specifiedType: const FullType(bool)),
    ];

    return result;
  }

  @override
  SignResponse deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new SignResponseBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'is_valid':
          result.isValid = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
      }
    }

    return result.build();
  }
}

class _$SignResponse extends SignResponse {
  @override
  final bool isValid;

  factory _$SignResponse([void Function(SignResponseBuilder)? updates]) =>
      (new SignResponseBuilder()..update(updates))._build();

  _$SignResponse._({required this.isValid}) : super._() {
    BuiltValueNullFieldError.checkNotNull(isValid, r'SignResponse', 'isValid');
  }

  @override
  SignResponse rebuild(void Function(SignResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SignResponseBuilder toBuilder() => new SignResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SignResponse && isValid == other.isValid;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, isValid.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SignResponse')
          ..add('isValid', isValid))
        .toString();
  }
}

class SignResponseBuilder
    implements Builder<SignResponse, SignResponseBuilder> {
  _$SignResponse? _$v;

  bool? _isValid;
  bool? get isValid => _$this._isValid;
  set isValid(bool? isValid) => _$this._isValid = isValid;

  SignResponseBuilder();

  SignResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _isValid = $v.isValid;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SignResponse other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$SignResponse;
  }

  @override
  void update(void Function(SignResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SignResponse build() => _build();

  _$SignResponse _build() {
    final _$result = _$v ??
        new _$SignResponse._(
            isValid: BuiltValueNullFieldError.checkNotNull(
                isValid, r'SignResponse', 'isValid'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
