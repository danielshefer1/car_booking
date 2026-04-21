import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dio_client.dart';
import '../core/messenger.dart';
import '../data/auth_repository.dart';
import '../models/user.dart';

class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final storage = ref.read(tokenStorageProvider);
    final token = await storage.read();
    if (token == null) return null;
    try {
      return await ref.read(authRepositoryProvider).me();
    } catch (_) {
      await storage.clear();
      return null;
    }
  }

  Future<void> login({required String email, required String password}) async {
    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(tokenStorageProvider);
    state = const AsyncValue.loading();
    try {
      final token = await repo.login(email: email, password: password);
      await storage.write(token.accessToken);
      final user = await repo.me();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(tokenStorageProvider);
    state = const AsyncValue.loading();
    try {
      await repo.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
      final token = await repo.login(email: email, password: password);
      await storage.write(token.accessToken);
      final user = await repo.me();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateMe({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? password,
  }) async {
    final updated = await ref.read(authRepositoryProvider).updateMe(
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          password: password,
        );
    state = AsyncValue.data(updated);
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clear();
    state = const AsyncValue.data(null);
  }

  Future<void> deleteAccount() async {
    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(tokenStorageProvider);
    state = const AsyncValue.loading();
    try {
      await repo.deleteMe();
      await storage.clear();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> handleUnauthorized() async {
    final hadSession = state.value != null;
    await ref.read(tokenStorageProvider).clear();
    state = const AsyncValue.data(null);
    if (hadSession) {
      final messenger = ref.read(scaffoldMessengerKeyProvider).currentState;
      messenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Your session has expired. Please sign in again.'),
          ),
        );
    }
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(
  AuthController.new,
);
