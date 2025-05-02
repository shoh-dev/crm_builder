import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';
import 'package:widgets_palette/widgets_palette.dart';
import 'package:core/src/services/supabase_service.dart';

/// ---------------------------------------------------------------------------
///  A single widget placed on the canvas
/// ---------------------------------------------------------------------------
class PlacedWidget {
  PlacedWidget({required this.id, required this.item, required this.offset})
    : tableProps =
          item.type == PaletteType.table ? TableProps() : null; // default

  final String id;
  final PaletteItem item;
  Offset offset;

  // widget‑specific data (null for non‑table widgets)
  TableProps? tableProps;

  // ---------- JSON <‑‑> Object helpers --------------------------------------

  Map<String, dynamic> toJson() {
    final p = tableProps; // promote once so it's non‑null inside the map
    return {
      'id': id,
      'type': item.type.name,
      'offset': {'dx': offset.dx, 'dy': offset.dy},
      if (p != null)
        'tableProps': {
          'rowsPerPage': p.rowsPerPage,
          'showToolbar': p.showToolbar,
          'boundTable': p.boundTable,
          'columns': p.columns,
        },
    };
  }

  static PlacedWidget fromJson(Map<String, dynamic> j) {
    final type = PaletteType.values.firstWhere(
      (e) => e.name == (j['type'] as String),
    );

    // icon is just a placeholder when recreating from JSON in the builder
    final item = PaletteItem(
      type: type,
      name: type.name,
      icon: Icons.device_hub,
    );

    final w = PlacedWidget(
      id: j['id'] as String,
      item: item,
      offset: Offset(
        (j['offset']['dx'] as num).toDouble(),
        (j['offset']['dy'] as num).toDouble(),
      ),
    );

    if (j['tableProps'] != null) {
      final p = j['tableProps'] as Map<String, dynamic>;
      w.tableProps = TableProps(
        rowsPerPage: p['rowsPerPage'] as int,
        showToolbar: p['showToolbar'] as bool,
        boundTable: p['boundTable'] as String?,
        columns:
            (p['columns'] as List<dynamic>).map((e) => e as String).toList(),
      );
    }
    return w;
  }
}

/// ---------------------------------------------------------------------------
///  View‑model for the builder screen
/// ---------------------------------------------------------------------------
final _uuid = const Uuid();

class BuilderViewModel extends ChangeNotifier {
  final placed = <PlacedWidget>[];

  // selection ---------------------------------------------------------------
  String? _selectedId;
  String? get selectedId => _selectedId;

  PlacedWidget? get selected =>
      placed.firstWhereOrNull((w) => w.id == _selectedId);

  // canvas actions ----------------------------------------------------------
  void addWidget(PaletteItem item, Offset offset) {
    placed.add(PlacedWidget(id: _uuid.v4(), item: item, offset: offset));
    notifyListeners();
  }

  void select(String id) {
    _selectedId = id;
    notifyListeners();
  }

  void updateTableProps(TableProps newProps) {
    final w = selected;
    if (w == null) return;
    w.tableProps = newProps;
    notifyListeners();
  }

  void load(Map<String, dynamic>? layoutJson) {
    placed
      ..clear()
      ..addAll(
        (layoutJson?['widgets'] as List<dynamic>? ?? []).map(
          (e) => PlacedWidget.fromJson(e as Map<String, dynamic>),
        ),
      );
    notifyListeners();
  }

  /// returns the whole canvas JSON without writing to DB
  Map<String, dynamic> serializeLayout() => {
    'widgets': placed.map((w) => w.toJson()).toList(),
  };
}
