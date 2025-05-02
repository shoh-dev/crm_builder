import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/form_props.dart';
import 'package:core/src/services/supabase_service.dart';
import 'form_widgets/text_field.dart';
import 'form_widgets/number_field.dart';
import 'form_widgets/date_field.dart';
import 'form_widgets/boolean_field.dart';
import 'form_widgets/json_field.dart';
import 'form_widgets/uuid_field.dart';
import 'form_widgets/time_field.dart';
import 'form_widgets/select_field.dart';
import 'form_widgets/array_field.dart';

/// Placeholder for form builder preview
class FormPreviewWidget extends StatefulWidget {
  final FormProps props;
  const FormPreviewWidget({super.key, required this.props});

  @override
  State<FormPreviewWidget> createState() => _FormPreviewWidgetState();
}

class _FormPreviewWidgetState extends State<FormPreviewWidget> {
  final _formKey = GlobalKey<FormState>();
  final _formData = <String, dynamic>{};
  final _nullableFields = <String, bool>{};
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchColumnInfo();
  }

  Future<void> _fetchColumnInfo() async {
    if (widget.props.boundTable == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await SupabaseService.I.client.rpc(
        'list_columns',
        params: {'p_table': widget.props.boundTable!},
      );

      if (response != null) {
        setState(() {
          for (final col in response as List) {
            _nullableFields[col['column_name']] = col['is_nullable'] as bool;
            if (!_formData.containsKey(col['column_name'])) {
              _formData[col['column_name']] = col['is_nullable'] ? null : '';
            }
          }
        });
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final cleanedData = Map<String, dynamic>.from(_formData);
      // Remove nulls for nullable fields
      _nullableFields.forEach((key, isNullable) {
        if (isNullable && cleanedData[key] == null) {
          cleanedData.remove(key);
        }
      });
      await SupabaseService.I.client
          .from(widget.props.boundTable!)
          .upsert(cleanedData);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data saved successfully')));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await SupabaseService.I.client
          .from(widget.props.boundTable!)
          .delete()
          .match(_formData.cast<String, Object>());

      setState(() => _formData.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record deleted successfully')),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildField(String field) {
    final type = widget.props.fieldTypes[field]?.toLowerCase() ?? 'text';
    final isNullable = _nullableFields[field] ?? true;

    // Skip system fields
    if (field == 'id' || field == 'created_at' || field == 'updated_at') {
      return const SizedBox.shrink();
    }

    switch (type) {
      case 'boolean':
        return BooleanField(
          field: field,
          type: type,
          isNullable: isNullable,
          value: _formData[field],
          onChanged: (value) => setState(() => _formData[field] = value),
        );

      case 'integer':
      case 'bigint':
      case 'smallint':
        return NumberField(
          field: field,
          type: type,
          isNullable: isNullable,
          isDecimal: false,
          value: _formData[field],
          onChanged: (value) {
            _formData[field] = value;
            if (value == null) {
              setState(() {});
            }
          },
        );

      case 'double precision':
      case 'real':
      case 'numeric':
      case 'decimal':
        return NumberField(
          field: field,
          type: type,
          isNullable: isNullable,
          isDecimal: true,
          value: _formData[field],
          onChanged: (value) {
            _formData[field] = value;
          },
        );

      case 'date':
        return DateField(
          field: field,
          type: type,
          isNullable: isNullable,
          value: _formData[field],
          onChanged: (value) => setState(() => _formData[field] = value),
        );

      case 'time':
      case 'time without time zone':
        return TimeField(
          field: field,
          type: type,
          isNullable: isNullable,
          value: _formData[field],
          onChanged: (value) => setState(() => _formData[field] = value),
        );

      case 'timestamp':
      case 'timestamp without time zone':
        return DateField(
          field: field,
          type: type,
          isNullable: isNullable,
          includeTime: true,
          isTimeZone: false,
          value: _formData[field],
          onChanged: (value) => setState(() => _formData[field] = value),
        );

      case 'timestamp with time zone':
        return DateField(
          field: field,
          type: type,
          isNullable: isNullable,
          includeTime: true,
          isTimeZone: true,
          value: _formData[field],
          onChanged: (value) => setState(() => _formData[field] = value),
        );

      case 'json':
      case 'jsonb':
        return JsonField(
          field: field,
          type: type,
          isNullable: isNullable,
          value: _formData[field],
          onChanged: (value) {
            _formData[field] = value;
          },
        );

      case 'uuid':
        return UuidField(
          field: field,
          type: type,
          isNullable: isNullable,
          value: _formData[field],
          onChanged: (value) => setState(() => _formData[field] = value),
        );

      case 'array':
        return ArrayField(
          field: field,
          type: type,
          isNullable: isNullable,
          value: _formData[field],
          onChanged: (value) => setState(() => _formData[field] = value),
        );

      case 'select_field':
        return SelectField(
          field: field,
          type: type,
          isNullable: isNullable,
          options: const ['OPTION1', 'OPTION2', 'OPTION3'],
          value: _formData[field],
          onChanged: (value) => setState(() => _formData[field] = value),
        );

      case 'email_field':
        return TextFieldWidget(
          field: field,
          type: type,
          isNullable: isNullable,
          value: _formData[field],
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final emailRegex =
                  RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }
            }
            return null;
          },
          onChanged: (value) {
            _formData[field] = value;
          },
        );

      case 'phone_field':
        return TextFieldWidget(
          field: field,
          type: type,
          isNullable: isNullable,
          value: _formData[field],
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            _formData[field] = value;
          },
        );

      default:
        return TextFieldWidget(
          field: field,
          type: type,
          isNullable: isNullable,
          value: _formData[field],
          onChanged: (value) {
            _formData[field] = value;
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.props.boundTable == null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(child: Text('No form bound')),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Form: ${widget.props.boundTable}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Error: $_error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ...widget.props.fields.map(
                    (field) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _buildField(field),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_formData.isNotEmpty)
                  TextButton.icon(
                    onPressed: _deleteData,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                  ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _saveData,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
