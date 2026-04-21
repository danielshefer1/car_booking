import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/user.dart';
import '../../state/auth_controller.dart';
import '../../state/users_controller.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) ref.invalidate(usersControllerProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersControllerProvider);
    final me = ref.watch(authControllerProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/cars'),
        ),
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No users yet.'));
          }
          final sorted = [...users]..sort((a, b) => a.id.compareTo(b.id));
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(usersControllerProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: sorted.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) => _UserTile(
                user: sorted[i],
                isSelf: me?.id == sorted[i].id,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UserTile extends ConsumerStatefulWidget {
  const _UserTile({required this.user, required this.isSelf});
  final User user;
  final bool isSelf;

  @override
  ConsumerState<_UserTile> createState() => _UserTileState();
}

class _UserTileState extends ConsumerState<_UserTile> {
  bool _busy = false;

  List<String> _availablePromotions() {
    switch (widget.user.permissions) {
      case 'user':
        return ['elevated', 'admin'];
      case 'elevated':
        return ['admin'];
      default:
        return const [];
    }
  }

  Future<void> _onSelected(String action) async {
    if (action == 'delete') {
      await _delete();
    } else {
      await _promoteTo(action);
    }
  }

  Future<void> _promoteTo(String role) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Promote ${widget.user.firstName} ${widget.user.lastName} to $role?',
        ),
        content: Text(_promotionBlurb(role)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Promote'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(usersControllerProvider.notifier)
          .promote(widget.user.id, role);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${widget.user.firstName} ${widget.user.lastName} is now $role',
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Delete ${widget.user.firstName} ${widget.user.lastName}?',
        ),
        content: const Text(
          'This permanently removes the account and all of their bookings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(usersControllerProvider.notifier)
          .delete(widget.user.id);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${widget.user.firstName} ${widget.user.lastName} deleted',
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _promotionBlurb(String role) {
    if (role == 'admin') {
      return 'Admins can manage cars, bookings, and promote other users.';
    }
    return 'Elevated users can create cars in addition to making bookings.';
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final theme = Theme.of(context);
    final promotions = _availablePromotions();
    final canDelete = !widget.isSelf;
    final canPromote = !widget.isSelf && promotions.isNotEmpty;
    final hasMenu = canPromote || canDelete;

    return ListTile(
      isThreeLine: true,
      title: Row(
        children: [
          Expanded(child: Text('${u.firstName} ${u.lastName}')),
          _RoleBadge(role: u.permissions),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(u.email),
          Text('Phone: ${u.phoneNumber}'),
        ],
      ),
      trailing: _busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : hasMenu
              ? PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'Actions',
                  onSelected: _onSelected,
                  itemBuilder: (_) => [
                    for (final role in promotions)
                      PopupMenuItem(
                        value: role,
                        child: Text('Promote to $role'),
                      ),
                    if (canPromote && canDelete)
                      const PopupMenuDivider(),
                    if (canDelete)
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete user',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                  ],
                )
              : null,
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (role) {
      'admin' => (scheme.primary, scheme.onPrimary),
      'elevated' => (scheme.secondary, scheme.onSecondary),
      _ => (scheme.surfaceContainerHighest, scheme.onSurface),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(role, style: TextStyle(color: fg, fontSize: 12)),
    );
  }
}
