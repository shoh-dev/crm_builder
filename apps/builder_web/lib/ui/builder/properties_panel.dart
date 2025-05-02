import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'builder_view_model.dart';
import 'data_binding_dialog.dart';
import 'package:widgets_palette/widgets_palette.dart';
import 'package:widgets_palette/src/models/table_props.dart';

class PropertiesPanel extends StatelessWidget {
  const PropertiesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BuilderViewModel>();
    final w = vm.selected;

    if (w == null) {
      return const Center(child: Text('Select a widget'));
    }

    switch (w.item.type) {
      case PaletteType.table:
        return _TablePropsEditor(
          props: w.tableProps!,
          onChanged: vm.updateTableProps,
        );
      case PaletteType.form:
        return _FormPropsEditor(
          props: w.formProps!,
          onChanged: vm.updateFormProps,
        );
    }
  }
}

class _TablePropsEditor extends StatefulWidget {
  const _TablePropsEditor({required this.props, required this.onChanged});
  final TableProps props;
  final ValueChanged<TableProps> onChanged;

  @override
  State<_TablePropsEditor> createState() => _TablePropsEditorState();
}

class _TablePropsEditorState extends State<_TablePropsEditor> {
  late TableProps _p;

  @override
  void initState() {
    super.initState();
    _p = widget.props.copy();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Table Properties', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 16),
        // Search Query
        TextField(
          decoration: const InputDecoration(
            labelText: 'Search',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (v) {
            setState(() => _p.searchQuery = v);
            widget.onChanged(_p);
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('Rows / page'),
            const Spacer(),
            DropdownButton<int>(
              value: _p.rowsPerPage,
              items:
                  [5, 10, 20, 50]
                      .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                      .toList(),
              onChanged: (v) {
                setState(() => _p.rowsPerPage = v!);
                widget.onChanged(_p);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Sort Column
        if (_p.columns.isNotEmpty) ...[
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Sort by'),
            value: _p.sortColumn,
            items:
                _p.columns
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
            onChanged: (v) {
              setState(() => _p.sortColumn = v);
              widget.onChanged(_p);
            },
          ),
          SwitchListTile(
            title: const Text('Ascending'),
            value: _p.sortAscending,
            onChanged: (v) {
              setState(() => _p.sortAscending = v);
              widget.onChanged(_p);
            },
          ),
        ],
        SwitchListTile(
          title: const Text('Show toolbar'),
          value: _p.showToolbar,
          onChanged: (v) {
            setState(() => _p.showToolbar = v);
            widget.onChanged(_p);
          },
        ),
        const Divider(),
        ListTile(
          title: Text(
            _p.boundTable == null
                ? 'Bind to data'
                : 'Bound: ${_p.boundTable} (${_p.columns.length} cols)',
          ),
          trailing: const Icon(Icons.link),
          onTap: () async {
            final res = await showDialog<TableProps>(
              context: context,
              builder: (_) => DataBindingDialog(initial: _p),
            );
            if (res != null) {
              setState(() => _p = res);
              widget.onChanged(_p);
            }
          },
        ),
      ],
    );
  }
}

class _FormPropsEditor extends StatefulWidget {
  final FormProps props;
  final ValueChanged<FormProps> onChanged;
  const _FormPropsEditor({required this.props, required this.onChanged});

  @override
  State<_FormPropsEditor> createState() => _FormPropsEditorState();
}

class _FormPropsEditorState extends State<_FormPropsEditor> {
  late FormProps _p;

  @override
  void initState() {
    super.initState();
    _p = widget.props.copy();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Form Properties', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 16),
        ListTile(
          title: Text(
            _p.boundTable == null ? 'Bind to data' : 'Bound: ${_p.boundTable}',
          ),
          trailing: const Icon(Icons.link),
          onTap: () async {
            final result = await showDialog<FormProps>(
              context: context,
              builder: (_) => DataBindingDialog<FormProps>(initial: _p),
            );
            if (result != null) {
              setState(() => _p = result);
              widget.onChanged(_p);
            }
          },
        ),
        const Divider(),
        // Field selector stub
        ..._p.fields.map((f) => Text('- $f')),
      ],
    );
  }
}
