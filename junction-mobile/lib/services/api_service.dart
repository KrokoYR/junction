import 'package:dio/dio.dart';
import 'package:fin_zero_id/data/serializers.dart';
import 'package:fin_zero_id/log.dart';

const _tag = 'api_service';

class ApiService {
  ApiService() {
    _init();
  }

  late final Dio dio;

  void _init() {
    Log.d(_tag, '_init');
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://junction2024.onrender.com/api',
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );
  }

  Future<T> post<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool printFullBody = true,
  }) async {
    Log.d(
      _tag,
      'post: path = $path, queryParameters = $queryParameters, data = $data',
    );

    final response = await dio.post(
      path,
      queryParameters: queryParameters,
      data: data,
    );

    final responseStatusCode = response.statusCode;
    final responseData = response.data;
    final realUri = response.realUri;
    final headers = response.requestOptions.headers;

    Log.d(
      _tag,
      'post: realUri = $realUri, headers = $headers, responseStatusCode = $responseStatusCode, responseData = $responseData',
    );

    if (responseStatusCode != 200) {
      throw Exception('Failed to load data');
    }

    // hack for bad server header response
    if (responseData == '') {
      return deserializeSync<T>({})!;
    } else {
      return deserializeSync<T>(responseData)!;
    }
  }

  Future<T> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    bool printFullBody = true,
  }) async {
    Log.d(_tag, 'get: path = $path, queryParameters = $queryParameters');

    final response = await dio.get(path, queryParameters: queryParameters);

    final responseStatusCode = response.statusCode;
    final responseData = response.data;
    final realUri = response.realUri;
    final headers = response.requestOptions.headers;

    Log.d(
      _tag,
      'get: realUri = $realUri, headers = $headers, queryParameters = $queryParameters, responseStatusCode = $responseStatusCode ${printFullBody ? 'responseData = $responseData' : 'responseData skipped'}',
    );

    if (responseStatusCode != 200) {
      throw Exception('Failed to load data');
    }

    return deserializeSync<T>(responseData)!;
  }
}
