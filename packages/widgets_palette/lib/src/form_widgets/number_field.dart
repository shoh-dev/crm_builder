import 'package:flutter/material.dart';
import 'form_field_base.dart';

class NumberField extends FormFieldBase {
  final bool isDecimal;

  const NumberField({
    super.key,
    required super.field,
    required super.type,
    required super.isNullable,
    required super.value,
    required super.onChanged,
    this.isDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value?.toString() ?? '');

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: field,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.numbers),
        suffixIcon: buildClearButton(),
      ),
      keyboardType: isDecimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      onChanged: (value) {
        if (isDecimal) {
          onChanged(double.tryParse(value) ?? 0.0);
        } else {
          onChanged(int.tryParse(value) ?? 0);
        }
      },
      validator: (value) {
        final baseValidation = super.validate(value);
        if (baseValidation != null) return baseValidation;

        if (value != null && value.isNotEmpty) {
          if (isDecimal) {
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
          } else {
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
          }
        }
        return null;
      },
    );
  }
}
