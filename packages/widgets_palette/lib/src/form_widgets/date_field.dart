import 'package:flutter/material.dart';
import 'form_field_base.dart';

class DateField extends FormFieldBase {
  final bool includeTime;
  final bool isTimeZone;

  const DateField({
    super.key,
    required super.field,
    required super.type,
    required super.isNullable,
    required super.value,
    required super.onChanged,
    this.includeTime = false,
    this.isTimeZone = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value?.toString() ?? '');

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: field,
        border: const OutlineInputBorder(),
        prefixIcon:
            Icon(includeTime ? Icons.access_time : Icons.calendar_today),
        helperText: isTimeZone ? 'Timestamp with timezone' : 'Timestamp',
        suffixIcon: buildClearButton(),
      ),
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate:
              DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          if (includeTime) {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (time != null) {
              final dateTime = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
              final formattedDate = isTimeZone
                  ? dateTime.toUtc().toIso8601String()
                  : dateTime.toIso8601String();
              onChanged(formattedDate);
              controller.text = formattedDate;
            }
          } else {
            final formattedDate = date.toIso8601String().split('T')[0];
            onChanged(formattedDate);
            controller.text = formattedDate;
          }
        }
      },
      validator: super.validate,
    );
  }
}
