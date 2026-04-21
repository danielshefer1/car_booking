import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/bookings_repository.dart';
import '../models/booking_with_user.dart';

class AllBookingsController extends AsyncNotifier<List<BookingWithUser>> {
  @override
  Future<List<BookingWithUser>> build() =>
      ref.read(bookingsRepositoryProvider).listAll();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(bookingsRepositoryProvider).listAll(),
    );
  }
}

final allBookingsControllerProvider =
    AsyncNotifierProvider<AllBookingsController, List<BookingWithUser>>(
  AllBookingsController.new,
);
