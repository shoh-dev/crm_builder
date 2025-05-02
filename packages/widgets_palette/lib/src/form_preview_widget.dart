import 'package:flutter/material.dart';
import 'models/form_props.dart';

/// Placeholder for form builder preview
class FormPreviewWidget extends StatelessWidget {
  final FormProps props;
  const FormPreviewWidget({super.key, required this.props});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child:
          props.boundTable == null
              ? const Center(child: Text('No form bound'))
              : Center(
                child: Text(
                  'Form: ${props.boundTable} (fields: ${props.fields.length})',
                ),
              ),
    );
  }
}
