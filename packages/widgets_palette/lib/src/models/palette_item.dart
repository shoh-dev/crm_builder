import 'package:flutter/material.dart';
import '../form_preview_widget.dart';

enum PaletteType { table, form }

class PaletteItem {
  const PaletteItem({
    required this.type,
    required this.name,
    required this.icon,
  });

  final PaletteType type;
  final String name;
  final dynamic icon; // IconData | Widget – keep loose for now
}

final items = const [
  PaletteItem(type: PaletteType.table, name: 'Table', icon: Icons.table_chart),
  PaletteItem(type: PaletteType.form, name: 'Form', icon: Icons.list),
];
