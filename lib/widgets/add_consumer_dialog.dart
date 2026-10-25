import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/saved_consumer.dart';

class AddConsumerDialog extends StatefulWidget {
  const AddConsumerDialog({super.key, required this.existing});

  final Set<String> existing;

  @override
  State<AddConsumerDialog> createState() => _AddConsumerDialogState();
}

class _AddConsumerDialogState extends State<AddConsumerDialog> {
  final _form = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _label = TextEditingController();

  @override
  void dispose() {
    _number.dispose();
    _label.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_form.currentState?.validate() ?? false)) return;
    final label = _label.text.trim();
    Navigator.of(context).pop(
      SavedConsumer(
        number: _number.text.trim(),
        label: label.isEmpty ? null : label,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add consumer'),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _number,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Consumer number'),
              validator: (v) {
                final t = (v ?? '').trim();
                if (t.length < 8) return 'Enter the full consumer number';
                if (widget.existing.contains(t)) return 'This number is already saved';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _label,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Label (optional)',
                hintText: 'Home, Shop, Rental',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
