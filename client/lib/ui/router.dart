import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/auth_controller.dart';
import 'screens/admin_add_car_screen.dart';
import 'screens/admin_users_screen.dart';
import 'screens/all_bookings_screen.dart';
import 'screens/car_detail_screen.dart';
import 'screens/cars_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/my_bookings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/cars',
    refreshListenable: _AuthRefresh(ref),
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      if (auth.isLoading) return '/splash';

      final user = auth.value;
      final loc = state.matchedLocation;
      final onSplash = loc == '/splash';
      final onAuthScreens = loc == '/login' || loc == '/register';

      if (user == null) {
        return onAuthScreens ? null : '/login';
      }
      if (onAuthScreens || onSplash) return '/cars';

      final adminOnly = loc.startsWith('/admin');
      if (adminOnly && user.permissions != 'admin') return '/cars';
      final elevatedOrAdminOnly = loc == '/cars/new';
      if (elevatedOrAdminOnly &&
          user.permissions != 'admin' &&
          user.permissions != 'elevated') {
        return '/cars';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/cars', builder: (_, _) => const CarsScreen()),
      GoRoute(
        path: '/cars/new',
        builder: (_, _) => const AdminAddCarScreen(),
      ),
      GoRoute(
        path: '/cars/:id',
        builder: (_, state) =>
            CarDetailScreen(carId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/bookings',
        builder: (_, _) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: '/all-bookings',
        builder: (_, _) => const AllBookingsScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (_, _) => const AdminUsersScreen(),
      ),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      GoRoute(
        path: '/profile/edit',
        builder: (_, _) => const EditProfileScreen(),
      ),
    ],
  );
});

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(this._ref) {
    _ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
  final Ref _ref;
}
