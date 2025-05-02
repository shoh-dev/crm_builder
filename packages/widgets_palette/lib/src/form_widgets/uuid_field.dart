import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'form_field_base.dart';

class UuidField extends FormFieldBase {
  const UuidField({
    super.key,
    required super.field,
    required super.type,
    required super.isNullable,
    required super.value,
    required super.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value?.toString() ?? '');

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: field,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.fingerprint),
        helperText: 'Auto-generated unique identifier',
        suffixIcon: buildClearButton(),
      ),
      readOnly: true,
      onTap: () {
        // Generate UUID on tap if empty
        if (value == null || value.toString().isEmpty) {
          final newUuid = const Uuid().v4();
          onChanged(newUuid);
          controller.text = newUuid;
        }
      },
      validator: super.validate,
    );
  }
}
