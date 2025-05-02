import 'package:flutter/material.dart';
import 'form_field_base.dart';

class BooleanField extends FormFieldBase {
  const BooleanField({
    super.key,
    required super.field,
    required super.type,
    required super.isNullable,
    required super.value,
    required super.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(field),
      value: value as bool? ?? false,
      onChanged: onChanged,
    );
  }
}
