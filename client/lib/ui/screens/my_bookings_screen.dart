import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/booking.dart';
import '../../models/car.dart';
import '../../state/auth_controller.dart';
import '../../state/bookings_controller.dart';
import '../../state/cars_controller.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingsControllerProvider);
    final carsById = {
      for (final c in ref.watch(carsControllerProvider).value ?? const <Car>[])
        c.id: c,
    };
    final currentUser = ref.watch(authControllerProvider).value;
    final bookerName = currentUser == null
        ? null
        : '${currentUser.firstName} ${currentUser.lastName}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My bookings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/cars'),
        ),
      ),
      body: bookings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No bookings yet.'));
          }
          final sorted = [...list]
            ..sort((a, b) => a.startTime.compareTo(b.startTime));
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(bookingsControllerProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: sorted.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) => _BookingTile(
                booking: sorted[i],
                car: carsById[sorted[i].carId],
                bookerName: bookerName,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BookingTile extends ConsumerStatefulWidget {
  const _BookingTile({
    required this.booking,
    required this.car,
    required this.bookerName,
  });
  final Booking booking;
  final Car? car;
  final String? bookerName;

  @override
  ConsumerState<_BookingTile> createState() => _BookingTileState();
}

class _BookingTileState extends ConsumerState<_BookingTile> {
  bool _cancelling = false;

  Future<void> _cancel() async {
    setState(() => _cancelling = true);
    try {
      await ref
          .read(bookingsControllerProvider.notifier)
          .cancel(widget.booking.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final car = widget.car;
    final title = car != null
        ? '${car.company} ${car.model}'
        : 'Car #${b.carId}';
    final name = widget.bookerName;
    return ListTile(
      isThreeLine: name != null,
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_fmt(b.startTime)} → ${_fmt(b.endTime)}'),
          if (name != null) Text('Booked by $name'),
        ],
      ),
      trailing: _cancelling
          ? const SizedBox(
              width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _cancel,
            ),
    );
  }

  static String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }
}
