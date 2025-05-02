import 'package:flutter/material.dart';

class SelectField extends StatelessWidget {
  final String field;
  final String type;
  final bool isNullable;
  final String? value;
  final List<String> options;
  final Function(String?) onChanged;

  const SelectField({
    super.key,
    required this.field,
    required this.type,
    required this.isNullable,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: field,
        border: const OutlineInputBorder(),
      ),
      items: [
        if (isNullable)
          const DropdownMenuItem<String>(
            value: null,
            child: Text('Select an option'),
          ),
        ...options.map((option) => DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            )),
      ],
      validator: (value) {
        if (!isNullable && value == null) {
          return 'This field is required';
        }
        return null;
      },
      onChanged: onChanged,
    );
  }
}
