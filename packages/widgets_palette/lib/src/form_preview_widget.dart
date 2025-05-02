import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/form_props.dart';
import 'package:core/src/services/supabase_service.dart';

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
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.props.boundTable == null || widget.props.fields.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response =
          await SupabaseService.I.client
              .from(widget.props.boundTable!)
              .select()
              .limit(1)
              .single();

      setState(() {
        _formData.clear();
        for (final field in widget.props.fields) {
          _formData[field] = response[field];
        }
      });
    } catch (e) {
      print(e);
      // setState(() => _error = e.toString());
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
      await SupabaseService.I.client
          .from(widget.props.boundTable!)
          .upsert(_formData);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data saved successfully')));
    } catch (e) {
      print(e);
      // setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
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
          .match(_formData as Map<String, Object>);

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

    if (_error != null) {
      return Center(
        child: Text(
          'Error: $_error',
          style: const TextStyle(color: Colors.red),
        ),
      );
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
                  const SizedBox(height: 16),
                  ...widget.props.fields.map(
                    (field) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: field,
                          border: const OutlineInputBorder(),
                        ),
                        initialValue: _formData[field]?.toString(),
                        onChanged: (value) => _formData[field] = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a value';
                          }
                          return null;
                        },
                      ),
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
