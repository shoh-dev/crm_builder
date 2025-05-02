import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';
import 'package:widgets_palette/widgets_palette.dart';
import 'package:core/src/services/supabase_service.dart';

/// ---------------------------------------------------------------------------
///  A single widget placed on the canvas
/// ---------------------------------------------------------------------------
class PlacedWidget {
  PlacedWidget({
    required this.id,
    required this.item,
    required this.offset,
    this.size = const Size(220, 140),
  }) : tableProps = item.type == PaletteType.table ? TableProps() : null;

  final String id;
  final PaletteItem item;
  Offset offset;
  Size size;

  // widget‑specific data (null for non‑table widgets)
  TableProps? tableProps;

  // ---------- JSON <‑‑> Object helpers --------------------------------------

  Map<String, dynamic> toJson() {
    final p = tableProps; // promote once so it's non‑null inside the map
    return {
      'id': id,
      'type': item.type.name,
      'offset': {'dx': offset.dx, 'dy': offset.dy},
      'size': {'w': size.width, 'h': size.height},
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
      size: Size(
        (j['size']?['w'] ?? 220) as double,
        (j['size']?['h'] ?? 140) as double,
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
  final _undo = <List<PlacedWidget>>[];
  final _redo = <List<PlacedWidget>>[];

  void _snapshot() => _undo.add(
    List<PlacedWidget>.from(
      placed.map((e) => PlacedWidget.fromJson(e.toJson())),
    ),
  );

  void undo() {
    if (_undo.isEmpty) return;
    _redo.add(List.of(placed));
    placed
      ..clear()
      ..addAll(_undo.removeLast());
    notifyListeners();
  }

  void redo() {
    if (_redo.isEmpty) return;
    _undo.add(List.of(placed));
    placed
      ..clear()
      ..addAll(_redo.removeLast());
    notifyListeners();
  }

  // selection ---------------------------------------------------------------
  String? _selectedId;
  String? get selectedId => _selectedId;

  PlacedWidget? get selected =>
      placed.firstWhereOrNull((w) => w.id == _selectedId);

  // canvas actions ----------------------------------------------------------
  void addWidget(PaletteItem item, Offset offset) {
    _snapshot();
    placed.add(PlacedWidget(id: _uuid.v4(), item: item, offset: offset));
    notifyListeners();
  }

  void move(String id, Offset newPos) {
    _snapshot();
    placed.firstWhere((w) => w.id == id).offset = newPos;
    notifyListeners();
  }

  void resize(String id, Size newSize) {
    _snapshot();
    placed.firstWhere((w) => w.id == id).size = newSize;
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
