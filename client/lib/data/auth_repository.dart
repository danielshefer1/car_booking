import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_exception.dart';
import '../core/dio_client.dart';
import '../models/token.dart';
import '../models/user.dart';

class AuthRepository {
  AuthRepository(this._dio);
  final Dio _dio;

  Future<Token> login({required String email, required String password}) async {
    try {
      final res = await _dio.post(
        '/users/login',
        data: FormData.fromMap({'username': email, 'password': password}),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return Token.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<User> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        '/users/register',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone_number': phoneNumber,
          'password': password,
        },
      );
      return User.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<User> me() async {
    try {
      final res = await _dio.get('/users/me');
      return User.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<User> updateMe({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? password,
  }) async {
    final body = <String, dynamic>{
      'first_name': ?firstName,
      'last_name': ?lastName,
      'phone_number': ?phoneNumber,
      'password': ?password,
    };
    try {
      final res = await _dio.patch('/users/me', data: body);
      return User.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> deleteMe() async {
    try {
      await _dio.delete('/users/me');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(dioProvider)),
);
