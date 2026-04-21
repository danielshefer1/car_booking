import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_exception.dart';
import '../core/dio_client.dart';
import '../models/car.dart';

class CarsRepository {
  CarsRepository(this._dio);
  final Dio _dio;

  Future<List<Car>> list() async {
    try {
      final res = await _dio.get('/cars');
      final list = (res.data as List).cast<Map<String, dynamic>>();
      return list.map(Car.fromJson).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Car> get(int id) async {
    try {
      final res = await _dio.get('/cars/$id');
      return Car.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Car> create({
    required String company,
    required String model,
    required int year,
  }) async {
    try {
      final res = await _dio.post(
        '/cars',
        data: {'company': company, 'model': model, 'year': year},
      );
      return Car.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete('/cars/$id');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final carsRepositoryProvider = Provider<CarsRepository>(
  (ref) => CarsRepository(ref.watch(dioProvider)),
);
