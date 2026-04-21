import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/car.dart';
import '../../state/auth_controller.dart';
import '../../state/cars_controller.dart';

class CarsScreen extends ConsumerWidget {
  const CarsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cars = ref.watch(carsControllerProvider);
    final role = ref.watch(authControllerProvider).value?.permissions;
    final isAdmin = role == 'admin';
    final canManageCars = role == 'admin' || role == 'elevated';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cars'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'My bookings',
            onPressed: () => context.go('/bookings'),
          ),
          IconButton(
            icon: const Icon(Icons.groups),
            tooltip: 'All bookings',
            onPressed: () => context.go('/all-bookings'),
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Manage users',
              onPressed: () => context.go('/admin/users'),
            ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      floatingActionButton: canManageCars
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/cars/new'),
              icon: const Icon(Icons.add),
              label: const Text('Add car'),
            )
          : null,
      body: cars.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.read(carsControllerProvider.notifier).refresh(),
        ),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  canManageCars
                      ? 'No cars yet. Tap "Add car" to create one.'
                      : 'No cars available yet.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(carsControllerProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) =>
                  _CarTile(car: list[i], isAdmin: isAdmin),
            ),
          );
        },
      ),
    );
  }
}

class _CarTile extends ConsumerStatefulWidget {
  const _CarTile({required this.car, required this.isAdmin});
  final Car car;
  final bool isAdmin;

  @override
  ConsumerState<_CarTile> createState() => _CarTileState();
}

class _CarTileState extends ConsumerState<_CarTile> {
  bool _deleting = false;

  Future<void> _confirmDelete() async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${widget.car.company} ${widget.car.model}?'),
        content: const Text(
          'This also removes any bookings for this car.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _deleting = true);
    try {
      await ref.read(carsControllerProvider.notifier).delete(widget.car.id);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.car;
    return ListTile(
      title: Text('${c.company} ${c.model}'),
      subtitle: Text('${c.year}'),
      trailing: widget.isAdmin
          ? (_deleting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _confirmDelete,
                ))
          : const Icon(Icons.chevron_right),
      onTap: () => context.go('/cars/${c.id}'),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
