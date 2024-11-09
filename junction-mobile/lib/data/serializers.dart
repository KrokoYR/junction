import 'package:built_collection/built_collection.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:fin_zero_id/data/qr_payload.dart';
import 'package:fin_zero_id/data/sign_response.dart';
import 'package:fin_zero_id/data/verify_response.dart';

part 'serializers.g.dart';

@SerializersFor([
  VerifyResponse,
  SignResponse,
  QrPayload,
])
final Serializers serializers = (_$serializers.toBuilder()
      ..addPlugin(StandardJsonPlugin())
      ..add(Iso8601DateTimeSerializer()))
    .build();

T? deserializeSync<T>(dynamic value) {
  final serializer = serializers.serializerForType(T);
  if (serializer == null) {
    throw ArgumentError("Cant find deserializer for ${value.runtimeType}");
  }
  return serializers.deserializeWith<T>(serializer as Serializer<T>, value);
}

BuiltList<T?> deserializeListOfSync<T>(Iterable value) {
  return BuiltList.from(
    value
        .map((dynamic value) => deserializeSync<T>(value))
        .toList(growable: false),
  );
}

Object? serializeSync<T>(T? value) {
  final serializer = serializers.serializerForType(T);
  if (serializer == null) {
    throw ArgumentError("Cant find serializer for ${value.runtimeType}");
  }
  return serializers.serializeWith(
    serializer as Serializer<T>,
    value,
  );
}

dynamic serializeIterableSync<T>(Iterable<T?> value) {
  return value.map<dynamic>((T? value) => serializeSync<T>(value)).toList();
}
