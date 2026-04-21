import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/users_repository.dart';
import '../models/user.dart';

class UsersController extends AsyncNotifier<List<User>> {
  @override
  Future<List<User>> build() => ref.read(usersRepositoryProvider).list();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(usersRepositoryProvider).list(),
    );
  }

  Future<User> promote(int userId, String role) async {
    final updated =
        await ref.read(usersRepositoryProvider).promote(userId, role);
    state = AsyncValue.data([
      for (final u in state.value ?? const <User>[])
        if (u.id == updated.id) updated else u,
    ]);
    return updated;
  }

  Future<void> delete(int userId) async {
    await ref.read(usersRepositoryProvider).delete(userId);
    state = AsyncValue.data(
      (state.value ?? const []).where((u) => u.id != userId).toList(),
    );
  }
}

final usersControllerProvider =
    AsyncNotifierProvider<UsersController, List<User>>(UsersController.new);
