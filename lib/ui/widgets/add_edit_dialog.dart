import 'package:flutter/material.dart';

Future<String?> showAddEditDialog(BuildContext context, {String? initialText}) async {
  final controller = TextEditingController(text: initialText ?? '');
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(initialText == null ? 'Add Item' : 'Edit Item'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Text',
          hintText: 'Type something to save…',
          border: OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => Navigator.of(ctx).pop(controller.text),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.of(ctx).pop(controller.text), child: const Text('Save')),
      ],
    ),
  );
}
