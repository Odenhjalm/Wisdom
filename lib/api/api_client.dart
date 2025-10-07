import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:wisdom/core/auth/token_storage.dart';

class ApiClient {
  ApiClient({required String baseUrl, required TokenStorage tokenStorage})
    : _tokenStorage = tokenStorage,
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          contentType: 'application/json',
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.extra['skipAuth'] == true) {
            handler.next(options);
            return;
          }
          final token = await _tokenStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final response = error.response;
          final requestOptions = error.requestOptions;
          final alreadyRetried = requestOptions.extra['retried'] == true;
          final skipAuth = requestOptions.extra['skipAuth'] == true;

          if (response?.statusCode == 401 && !alreadyRetried && !skipAuth) {
            final refreshToken = await _tokenStorage.readRefreshToken();
            if (refreshToken != null && refreshToken.isNotEmpty) {
              try {
                final refreshResponse = await _dio.post<Map<String, dynamic>>(
                  '/auth/refresh',
                  data: {'refresh_token': refreshToken},
                  options: Options(extra: {'skipAuth': true}),
                );
                final data = refreshResponse.data ?? <String, dynamic>{};
                final newAccess = data['access_token'] as String?;
                final newRefresh = data['refresh_token'] as String?;
                if (newAccess != null && newRefresh != null) {
                  await _tokenStorage.saveTokens(
                    accessToken: newAccess,
                    refreshToken: newRefresh,
                  );
                  requestOptions.headers['Authorization'] = 'Bearer $newAccess';
                  requestOptions.extra['retried'] = true;
                  final retryResponse = await _dio.fetch(requestOptions);
                  handler.resolve(retryResponse);
                  return;
                }
              } catch (_) {
                await _tokenStorage.clear();
              }
            } else {
              await _tokenStorage.clear();
            }
          }

          if (response?.statusCode == 401) {
            await _tokenStorage.clear();
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic> data)? parser,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
    );
    if (parser != null && response.data != null) {
      return parser(response.data!);
    }
    return (response.data as T);
  }

  Future<T> post<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic> data)? parser,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(path, data: body);
    if (parser != null && response.data != null) {
      return parser(response.data!);
    }
    return (response.data as T);
  }

  Future<T?> patch<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic> data)? parser,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(path, data: body);
    if (parser != null && response.data != null) {
      return parser(response.data!);
    }
    return response.data as T?;
  }

  Future<T?> postForm<T>(
    String path,
    FormData formData, {
    T Function(Map<String, dynamic> data)? parser,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
    if (parser != null && response.data != null) {
      return parser(response.data!);
    }
    return response.data as T?;
  }

  Future<T?> delete<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic> data)? parser,
  }) async {
    final response = await _dio.delete<Map<String, dynamic>>(path, data: body);
    if (parser != null && response.data != null) {
      return parser(response.data!);
    }
    return response.data as T?;
  }

  Future<Uint8List> getBytes(String path) async {
    final response = await _dio.get<List<int>>(
      path,
      options: Options(responseType: ResponseType.bytes),
    );
    final data = response.data ?? <int>[];
    return Uint8List.fromList(data);
  }

  Dio get raw => _dio;
}
