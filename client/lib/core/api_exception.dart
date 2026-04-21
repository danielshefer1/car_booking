import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  factory ApiException.fromDio(DioException e) {
    final data = e.response?.data;
    final detail = (data is Map && data['detail'] is String)
        ? data['detail'] as String
        : null;

    final fallback = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'Request timed out',
      DioExceptionType.connectionError => 'Could not reach the server',
      DioExceptionType.badCertificate => 'TLS certificate error',
      DioExceptionType.cancel => 'Request cancelled',
      DioExceptionType.unknown => e.message ?? 'Unknown error',
      DioExceptionType.badResponse =>
        'Server error (${e.response?.statusCode})',
    };

    return ApiException(
      detail ?? fallback,
      statusCode: e.response?.statusCode,
    );
  }

  @override
  String toString() => message;
}
