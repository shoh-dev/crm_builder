import 'package:flutter/material.dart';

class ArrayField extends StatelessWidget {
  final String field;
  final String type;
  final bool isNullable;
  final List<String>? value;
  final Function(List<String>?) onChanged;

  const ArrayField({
    super.key,
    required this.field,
    required this.type,
    required this.isNullable,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...(value ?? []).map((item) => Chip(
                  label: Text(item),
                  onDeleted: () {
                    final newValue = List<String>.from(value ?? []);
                    newValue.remove(item);
                    onChanged(newValue.isEmpty && isNullable ? null : newValue);
                  },
                )),
            ActionChip(
              avatar: const Icon(Icons.add),
              label: const Text('Add Item'),
              onPressed: () async {
                final result = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Add Item'),
                    content: TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter item',
                      ),
                      onSubmitted: (value) => Navigator.pop(context, value),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          final controller = context
                              .findAncestorWidgetOfExactType<TextField>()
                              ?.controller;
                          if (controller != null &&
                              controller.text.isNotEmpty) {
                            Navigator.pop(context, controller.text);
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                );

                if (result != null && result.isNotEmpty) {
                  final newValue = List<String>.from(value ?? []);
                  newValue.add(result);
                  onChanged(newValue);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
