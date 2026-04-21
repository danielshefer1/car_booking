import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/cars_repository.dart';
import '../../models/car.dart';
import '../../state/bookings_controller.dart';

class CarDetailScreen extends ConsumerStatefulWidget {
  const CarDetailScreen({super.key, required this.carId});
  final int carId;

  @override
  ConsumerState<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends ConsumerState<CarDetailScreen> {
  DateTime? _start;
  DateTime? _end;
  bool _submitting = false;
  late final Future<Car> _carFuture =
      ref.read(carsRepositoryProvider).get(widget.carId);

  Future<DateTime?> _pickDateTime(DateTime? seed) async {
    final now = DateTime.now();
    final initial = seed ?? now.add(const Duration(hours: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _submit() async {
    if (_start == null || _end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a start and end time')),
      );
      return;
    }
    if (!_end!.isAfter(_start!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End must be after start')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(bookingsControllerProvider.notifier).create(
            carId: widget.carId,
            startTime: _start!,
            endTime: _end!,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booked.')),
      );
      context.go('/bookings');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book car'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/cars'),
        ),
      ),
      body: FutureBuilder<Car>(
        future: _carFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text(snap.error.toString()));
          }
          final car = snap.data!;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${car.company} ${car.model}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text('${car.year}'),
                const SizedBox(height: 24),
                _DateTimeTile(
                  label: 'Start',
                  value: _start,
                  onTap: () async {
                    final dt = await _pickDateTime(_start);
                    if (dt != null) setState(() => _start = dt);
                  },
                ),
                const SizedBox(height: 12),
                _DateTimeTile(
                  label: 'End',
                  value: _end,
                  onTap: () async {
                    final dt = await _pickDateTime(_end ?? _start);
                    if (dt != null) setState(() => _end = dt);
                  },
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: Text(_submitting ? 'Booking…' : 'Book'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DateTimeTile extends StatelessWidget {
  const _DateTimeTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(value == null ? 'Pick' : _format(value!)),
          ],
        ),
      ),
    );
  }

  static String _format(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }
}
