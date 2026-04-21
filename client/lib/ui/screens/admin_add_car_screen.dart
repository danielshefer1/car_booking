import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/cars_controller.dart';

class AdminAddCarScreen extends ConsumerStatefulWidget {
  const AdminAddCarScreen({super.key});

  @override
  ConsumerState<AdminAddCarScreen> createState() => _AdminAddCarScreenState();
}

class _AdminAddCarScreenState extends ConsumerState<AdminAddCarScreen> {
  final _company = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _company.dispose();
    _model.dispose();
    _year.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final year = int.tryParse(_year.text.trim());
    final messenger = ScaffoldMessenger.of(context);
    if (_company.text.trim().isEmpty ||
        _model.text.trim().isEmpty ||
        year == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Fill in company, model, and year')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(carsControllerProvider.notifier).create(
            company: _company.text.trim(),
            model: _model.text.trim(),
            year: year,
          );
      if (!mounted) return;
      context.go('/cars');
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add car'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/cars'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _company,
              decoration: const InputDecoration(labelText: 'Company'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _model,
              decoration: const InputDecoration(labelText: 'Model'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _year,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Year'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? 'Saving…' : 'Add car'),
            ),
          ],
        ),
      ),
    );
  }
}
