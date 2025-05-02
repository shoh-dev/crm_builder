import 'package:flutter/material.dart';
import 'package:widgets_palette/widgets_palette.dart';

class PaletteDrawer extends StatelessWidget {
  const PaletteDrawer({super.key});

  final items = const [
    PaletteItem(
      type: PaletteType.table,
      name: 'Table',
      icon: Icons.table_chart,
    ),
    PaletteItem(type: PaletteType.form, name: 'Form', icon: Icons.list),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Widgets', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          for (final it in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Draggable<PaletteItem>(
                data: it,
                feedback: Opacity(opacity: 0.7, child: _tile(it)),
                childWhenDragging: Opacity(opacity: 0.3, child: _tile(it)),
                child: _tile(it),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tile(PaletteItem it) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade400),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(it.icon as IconData, size: 20),
        const SizedBox(width: 8),
        Text(it.name),
      ],
    ),
  );
}
