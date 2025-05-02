import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'builder_view_model.dart';
import 'data_binding_dialog.dart';
import 'package:widgets_palette/widgets_palette.dart';

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
              onChanged: (v) => setState(() => _p.rowsPerPage = v!),
            ),
          ],
        ),
        SwitchListTile(
          title: const Text('Show toolbar'),
          value: _p.showToolbar,
          onChanged: (v) => setState(() => _p.showToolbar = v),
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
