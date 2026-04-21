import 'package:dio/dio.dart';
import 'storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.storage, required this.onUnauthorized});

  final TokenStorage storage;
  final Future<void> Function() onUnauthorized;

  static const _unauthenticatedPaths = {'/users/login', '/users/register'};

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_unauthenticatedPaths.contains(options.path)) {
      final token = await storage.read();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 &&
        !_unauthenticatedPaths.contains(err.requestOptions.path)) {
      await onUnauthorized();
    }
    handler.next(err);
  }
}
