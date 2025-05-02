import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final String field;
  final String type;
  final bool isNullable;
  final String? value;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Function(String?) onChanged;

  const TextFieldWidget({
    super.key,
    required this.field,
    required this.type,
    required this.isNullable,
    required this.value,
    this.keyboardType,
    this.validator,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: field,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (!isNullable && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        if (validator != null) {
          return validator!(value);
        }
        return null;
      },
      onChanged: onChanged,
    );
  }
}
