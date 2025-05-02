import 'package:flutter/material.dart';

abstract class FormFieldBase extends StatelessWidget {
  final String field;
  final String type;
  final bool isNullable;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const FormFieldBase({
    super.key,
    required this.field,
    required this.type,
    required this.isNullable,
    required this.value,
    required this.onChanged,
  });

  String? validate(dynamic value) {
    if (!isNullable && (value == null || value.toString().isEmpty)) {
      return 'This field is required';
    }
    return null;
  }

  Widget? buildClearButton() {
    if (!isNullable || value == null || value.toString().isEmpty) {
      return null;
    }
    return IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () => onChanged(null),
    );
  }
}
