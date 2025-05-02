import 'package:flutter/material.dart';
import 'package:core/src/services/supabase_service.dart';
import 'package:widgets_palette/widgets_palette.dart';

class DataBindingDialog extends StatefulWidget {
  const DataBindingDialog({required this.initial, super.key});
  final TableProps initial;

  @override
  State<DataBindingDialog> createState() => _DataBindingDialogState();
}

class _DataBindingDialogState extends State<DataBindingDialog> {
  String? _table;
  final _selectedCols = <String>{};
  bool _loading = true;
  List<String> _tables = [];
  List<String> _cols = [];

  @override
  void initState() {
    super.initState();
    _fetchTables();
  }

  Future<void> _fetchTables() async {
    final resp =
        await SupabaseService.I.client
            .rpc('list_tables') // <- NEW
            .limit(200)
            .select(); // <- receive as List<Map>
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
            .rpc('list_columns', params: {'p_table': table}) // <- NEW
            .limit(200)
            .select();
    _cols =
        (resp as List).map<String>((m) => m['column_name'] as String).toList();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bind Table'),
      content: SizedBox(
        width: 320,
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _table == null
                ? ListView(
                  children:
                      _tables
                          .map(
                            (t) => ListTile(
                              title: Text(t),
                              onTap: () {
                                _table = t;
                                _fetchCols(t);
                              },
                            ),
                          )
                          .toList(),
                )
                : ListView(
                  children:
                      _cols
                          .map(
                            (c) => CheckboxListTile(
                              title: Text(c),
                              value: _selectedCols.contains(c),
                              onChanged: (v) {
                                setState(
                                  () =>
                                      v!
                                          ? _selectedCols.add(c)
                                          : _selectedCols.remove(c),
                                );
                              },
                            ),
                          )
                          .toList(),
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
              final newProps =
                  widget.initial.copy()
                    ..boundTable = _table
                    ..columns = _selectedCols.toList();
              Navigator.pop(context, newProps);
            },
            child: const Text('Bind'),
          ),
      ],
    );
  }
}
