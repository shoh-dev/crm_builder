import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimeField extends StatelessWidget {
  final String field;
  final String type;
  final bool isNullable;
  final String? value;
  final Function(String?) onChanged;

  const TimeField({
    super.key,
    required this.field,
    required this.type,
    required this.isNullable,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: field,
        hintText: 'HH:MM:SS',
        border: const OutlineInputBorder(),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
      ],
      validator: (value) {
        if (!isNullable && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        if (value != null && value.isNotEmpty) {
          final timeRegex =
              RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$');
          if (!timeRegex.hasMatch(value)) {
            return 'Please enter a valid time (HH:MM:SS)';
          }
        }
        return null;
      },
      onChanged: onChanged,
    );
  }
}
