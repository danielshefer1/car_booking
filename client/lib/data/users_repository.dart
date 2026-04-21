import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_exception.dart';
import '../core/dio_client.dart';
import '../models/user.dart';

class UsersRepository {
  UsersRepository(this._dio);
  final Dio _dio;

  Future<List<User>> list() async {
    try {
      final res = await _dio.get('/users');
      final list = (res.data as List).cast<Map<String, dynamic>>();
      return list.map(User.fromJson).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<User> promote(int userId, String role) async {
    try {
      final res = await _dio.post(
        '/users/$userId/promote',
        data: {'role': role},
      );
      return User.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> delete(int userId) async {
    try {
      await _dio.delete('/users/$userId');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final usersRepositoryProvider = Provider<UsersRepository>(
  (ref) => UsersRepository(ref.watch(dioProvider)),
);
