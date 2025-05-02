import 'package:flutter/material.dart';
import 'package:core/src/services/supabase_service.dart';
import 'package:widgets_palette/widgets_palette.dart';

class DataBindingDialog<T> extends StatefulWidget {
  const DataBindingDialog({required this.initial, super.key});
  final T initial;

  @override
  State<DataBindingDialog<T>> createState() => _DataBindingDialogState<T>();
}

class _DataBindingDialogState<T> extends State<DataBindingDialog<T>> {
  String? _table;
  final _selectedCols = <String>{};
  bool _loading = true;
  List<String> _tables = [];
  List<({String name, String type})> _cols = [];
  bool _selectAll = true;

  @override
  void initState() {
    super.initState();
    _fetchTables();
  }

  void _handleSelectAll(bool value) {
    setState(() {
      if (value) {
        _selectedCols.addAll(_cols.map((col) => col.name));
      } else {
        _selectedCols.clear();
      }
      _selectAll = value;
    });
  }

  Future<void> _fetchTables() async {
    final resp =
        await SupabaseService.I.client.rpc('list_tables').limit(200).select();
    _tables =
        (resp as List).map<String>((m) => m['table_name'] as String).toList();
    setState(() => _loading = false);
  }

  Future<void> _fetchCols(String table) async {
    setState(() {
      _cols = [];
      _loading = true;
    });
    final resp =
        await SupabaseService.I.client
            .rpc('list_columns', params: {'p_table': table})
            .limit(200)
            .select();
    _cols =
        (resp as List).map<({String name, String type})>((m) {
          return (
            name: m['column_name'] as String,
            type: m['data_type'] as String,
          );
        }).toList();
    // Select all columns by default
    _selectedCols.addAll(_cols.map((col) => col.name));
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bind to Data'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Table'),
              value: _table,
              items:
                  _tables
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
              onChanged: (v) {
                setState(() => _table = v);
                if (v != null) _fetchCols(v);
              },
            ),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_table != null) ...[
              const SizedBox(height: 16),
              const Text('Select columns:'),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Select All'),
                value: _selectAll,
                onChanged: (value) => _handleSelectAll(value ?? false),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _cols.length,
                  itemBuilder: (_, i) {
                    final col = _cols[i];
                    return CheckboxListTile(
                      title: Text(col.name),
                      subtitle: Text(col.type),
                      value: _selectedCols.contains(col.name),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _selectedCols.add(col.name);
                          } else {
                            _selectedCols.remove(col.name);
                          }
                          _selectAll = _selectedCols.length == _cols.length;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (_table != null)
          TextButton(
            onPressed: () {
              if (T == TableProps) {
                final newProps =
                    (widget.initial as TableProps).copy()
                      ..boundTable = _table
                      ..columns = _selectedCols.toList();
                Navigator.pop(context, newProps as T);
              } else if (T == FormProps) {
                final newProps =
                    (widget.initial as FormProps).copy()
                      ..boundTable = _table
                      ..fields = _selectedCols.toList()
                      ..fieldTypes = Map.fromEntries(
                        _cols
                            .where((c) => _selectedCols.contains(c.name))
                            .map((c) => MapEntry(c.name, c.type)),
                      );
                Navigator.pop(context, newProps as T);
              } else {
                throw UnimplementedError('Unsupported type: $T');
              }
            },
            child: const Text('Bind'),
          ),
      ],
    );
  }
}
