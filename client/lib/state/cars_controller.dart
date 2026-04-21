import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cars_repository.dart';
import '../models/car.dart';

class CarsController extends AsyncNotifier<List<Car>> {
  @override
  Future<List<Car>> build() => ref.read(carsRepositoryProvider).list();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(carsRepositoryProvider).list(),
    );
  }

  Future<Car> create({
    required String company,
    required String model,
    required int year,
  }) async {
    final car = await ref
        .read(carsRepositoryProvider)
        .create(company: company, model: model, year: year);
    state = AsyncValue.data([car, ...(state.value ?? const [])]);
    return car;
  }

  Future<void> delete(int id) async {
    await ref.read(carsRepositoryProvider).delete(id);
    state = AsyncValue.data(
      (state.value ?? const []).where((c) => c.id != id).toList(),
    );
  }
}

final carsControllerProvider =
    AsyncNotifierProvider<CarsController, List<Car>>(CarsController.new);
