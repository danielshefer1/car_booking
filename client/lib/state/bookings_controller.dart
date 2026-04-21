import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/bookings_repository.dart';
import '../models/booking.dart';

class BookingsController extends AsyncNotifier<List<Booking>> {
  @override
  Future<List<Booking>> build() =>
      ref.read(bookingsRepositoryProvider).listMine();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(bookingsRepositoryProvider).listMine(),
    );
  }

  Future<Booking> create({
    required int carId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final booking = await ref.read(bookingsRepositoryProvider).create(
          carId: carId,
          startTime: startTime,
          endTime: endTime,
        );
    state = AsyncValue.data([...(state.value ?? const []), booking]);
    return booking;
  }

  Future<void> cancel(int id) async {
    await ref.read(bookingsRepositoryProvider).cancel(id);
    state = AsyncValue.data(
      (state.value ?? const []).where((b) => b.id != id).toList(),
    );
  }
}

final bookingsControllerProvider =
    AsyncNotifierProvider<BookingsController, List<Booking>>(
  BookingsController.new,
);
