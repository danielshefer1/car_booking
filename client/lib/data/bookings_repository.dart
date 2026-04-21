import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_exception.dart';
import '../core/dio_client.dart';
import '../models/booking.dart';
import '../models/booking_with_user.dart';

class BookingsRepository {
  BookingsRepository(this._dio);
  final Dio _dio;

  Future<Booking> create({
    required int carId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final res = await _dio.post(
        '/bookings',
        data: {
          'car_id': carId,
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
        },
      );
      return Booking.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<Booking>> listMine() async {
    try {
      final res = await _dio.get('/bookings');
      final list = (res.data as List).cast<Map<String, dynamic>>();
      return list.map(Booking.fromJson).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<BookingWithUser>> listAll() async {
    try {
      final res = await _dio.get('/bookings/all');
      final list = (res.data as List).cast<Map<String, dynamic>>();
      return list.map(BookingWithUser.fromJson).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> cancel(int id) async {
    try {
      await _dio.delete('/bookings/$id');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final bookingsRepositoryProvider = Provider<BookingsRepository>(
  (ref) => BookingsRepository(ref.watch(dioProvider)),
);
