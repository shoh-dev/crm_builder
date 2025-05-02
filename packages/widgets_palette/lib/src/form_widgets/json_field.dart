import 'package:flutter/material.dart';
import 'dart:convert';
import 'form_field_base.dart';

class JsonField extends FormFieldBase {
  const JsonField({
    super.key,
    required super.field,
    required super.type,
    required super.isNullable,
    required super.value,
    required super.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(
      text: value is Map || value is List
          ? const JsonEncoder.withIndent('  ').convert(value)
          : value?.toString() ?? '',
    );

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: field,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.data_object),
        helperText: 'JSON field',
        suffixIcon: buildClearButton(),
      ),
      maxLines: 5,
      onChanged: (value) {
        try {
          onChanged(jsonDecode(value));
        } catch (e) {
          onChanged(value);
        }
      },
      validator: (value) {
        final baseValidation = super.validate(value);
        if (baseValidation != null) return baseValidation;

        if (value != null && value.isNotEmpty) {
          try {
            jsonDecode(value);
          } catch (e) {
            return 'Please enter valid JSON';
          }
        }
        return null;
      },
    );
  }
}
