import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/booking_with_user.dart';
import '../../models/car.dart';
import '../../state/all_bookings_controller.dart';
import '../../state/cars_controller.dart';

class AllBookingsScreen extends ConsumerStatefulWidget {
  const AllBookingsScreen({super.key});

  @override
  ConsumerState<AllBookingsScreen> createState() => _AllBookingsScreenState();
}

class _AllBookingsScreenState extends ConsumerState<AllBookingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) ref.invalidate(allBookingsControllerProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(allBookingsControllerProvider);
    final cars = ref.watch(carsControllerProvider).value ?? const <Car>[];
    final carsById = {for (final c in cars) c.id: c};

    return Scaffold(
      appBar: AppBar(
        title: const Text('All bookings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/cars'),
        ),
      ),
      body: all.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No bookings yet.'));
          }
          final grouped = <int, List<BookingWithUser>>{};
          for (final b in list) {
            grouped.putIfAbsent(b.carId, () => []).add(b);
          }
          for (final entries in grouped.values) {
            entries.sort((a, b) => a.startTime.compareTo(b.startTime));
          }
          final carIds = grouped.keys.toList()
            ..sort((a, b) {
              final ca = carsById[a];
              final cb = carsById[b];
              final la = ca == null ? 'Car #$a' : '${ca.company} ${ca.model}';
              final lb = cb == null ? 'Car #$b' : '${cb.company} ${cb.model}';
              return la.toLowerCase().compareTo(lb.toLowerCase());
            });

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(allBookingsControllerProvider.notifier).refresh(),
            child: ListView.builder(
              itemCount: carIds.length,
              itemBuilder: (_, i) {
                final carId = carIds[i];
                final car = carsById[carId];
                final title = car != null
                    ? '${car.company} ${car.model}'
                    : 'Car #$carId';
                final bookings = grouped[carId]!;
                return _CarBookingsSection(
                  title: title,
                  bookings: bookings,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CarBookingsSection extends StatelessWidget {
  const _CarBookingsSection({required this.title, required this.bookings});
  final String title;
  final List<BookingWithUser> bookings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          color: theme.colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '$title  (${bookings.length})',
            style: theme.textTheme.titleSmall,
          ),
        ),
        for (final b in bookings) ...[
          ListTile(
            isThreeLine: true,
            title: Text('${b.user.firstName} ${b.user.lastName}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_fmt(b.startTime)} → ${_fmt(b.endTime)}'),
                Text('Phone: ${b.user.phoneNumber}'),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
      ],
    );
  }

  static String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }
}
