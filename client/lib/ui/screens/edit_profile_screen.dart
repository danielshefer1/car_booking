import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/auth_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  final _password = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final u = ref.read(authControllerProvider).value;
    _firstName = TextEditingController(text: u?.firstName ?? '');
    _lastName = TextEditingController(text: u?.lastName ?? '');
    _phone = TextEditingController(text: u?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    final firstName = _firstName.text.trim();
    final lastName = _lastName.text.trim();
    final phone = _phone.text.trim();
    final password = _password.text;

    if (firstName.isEmpty || lastName.isEmpty || phone.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Name and phone cannot be empty.')),
      );
      return;
    }

    final updates = <String, String?>{
      if (firstName != user.firstName) 'first_name': firstName,
      if (lastName != user.lastName) 'last_name': lastName,
      if (phone != user.phoneNumber) 'phone_number': phone,
      if (password.isNotEmpty) 'password': password,
    };

    if (updates.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Nothing to update.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(authControllerProvider.notifier).updateMe(
            firstName: updates['first_name'],
            lastName: updates['last_name'],
            phoneNumber: updates['phone_number'],
            password: updates['password'],
          );
      messenger.showSnackBar(
        const SnackBar(content: Text('Profile updated.')),
      );
      if (mounted) context.go('/profile');
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _firstName,
                    decoration: const InputDecoration(labelText: 'First name'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _lastName,
                    decoration: const InputDecoration(labelText: 'Last name'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone number'),
            ),
            const SizedBox(height: 20),
            Text(
              'Email',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 2),
            Text(
              'Email cannot be changed.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            Text('Change password', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New password (leave blank to keep current)',
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _submitting ? null : _save,
              child: Text(_submitting ? 'Saving…' : 'Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}
