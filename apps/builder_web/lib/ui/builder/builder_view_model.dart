import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';
import 'package:widgets_palette/widgets_palette.dart';
import 'package:core/src/services/workspace_service.dart';
import 'package:core/src/services/project_service.dart';
import 'package:core/src/failure.dart';

final _uuid = const Uuid();

/// Represents a widget placed on the canvas, including its properties
class PlacedWidget {
  PlacedWidget({
    required this.id,
    required this.item,
    required this.offset,
    this.size = const Size(220, 140),
    this.locked = false,
  }) : tableProps = item.type == PaletteType.table ? TableProps() : null,
       formProps = item.type == PaletteType.form ? FormProps() : null;

  final String id;
  final PaletteItem item;
  Offset offset;
  Size size;
  bool locked;
  TableProps? tableProps;
  FormProps? formProps;

  /// Serialize to JSON for persistence
  Map<String, dynamic> toJson() {
    final p = tableProps;
    final f = formProps;
    return {
      'id': id,
      'type': item.type.name,
      'offset': {'dx': offset.dx, 'dy': offset.dy},
      'size': {'w': size.width, 'h': size.height},
      'locked': locked,
      if (p != null)
        'tableProps': {
          'rowsPerPage': p.rowsPerPage,
          'showToolbar': p.showToolbar,
          'boundTable': p.boundTable,
          'columns': p.columns,
        },
      if (f != null)
        'formProps': {'boundTable': f.boundTable, 'fields': f.fields},
    };
  }

  /// Reconstruct from JSON
  static PlacedWidget fromJson(Map<String, dynamic> j) {
    final type = PaletteType.values.firstWhere(
      (e) => e.name == (j['type'] as String),
    );
    final item = PaletteItem(
      type: type,
      name: type.name,
      icon: type == PaletteType.table ? Icons.table_chart : Icons.list,
    );
    final w = PlacedWidget(
      id: j['id'] as String,
      item: item,
      offset: Offset(
        (j['offset']['dx'] as num).toDouble(),
        (j['offset']['dy'] as num).toDouble(),
      ),
      size: Size(
        (j['size']?['w'] as num? ?? 220).toDouble(),
        (j['size']?['h'] as num? ?? 140).toDouble(),
      ),
      locked: j['locked'] as bool? ?? false,
    );
    if (j['tableProps'] != null) {
      final p = j['tableProps'] as Map<String, dynamic>;
      w.tableProps = TableProps(
        rowsPerPage: p['rowsPerPage'] as int,
        showToolbar: p['showToolbar'] as bool,
        boundTable: p['boundTable'] as String?,
        columns: (p['columns'] as List).map((e) => e as String).toList(),
      );
    }
    if (j['formProps'] != null) {
      final f = j['formProps'] as Map<String, dynamic>;
      w.formProps = FormProps(
        boundTable: f['boundTable'] as String?,
        fields: (f['fields'] as List).map((e) => e as String).toList(),
      );
    }
    return w;
  }
}

/// ViewModel managing canvas state and persistence
class BuilderViewModel extends ChangeNotifier {
  final placed = <PlacedWidget>[];

  // Selection
  String? _selectedId;
  String? get selectedId => _selectedId;
  PlacedWidget? get selected =>
      placed.firstWhereOrNull((w) => w.id == _selectedId);

  // Undo/Redo stacks
  final _undo = <List<PlacedWidget>>[];
  final _redo = <List<PlacedWidget>>[];

  void _snapshot() {
    _undo.add(placed.map((w) => PlacedWidget.fromJson(w.toJson())).toList());
    _redo.clear();
  }

  void undo() {
    if (_undo.isEmpty) return;
    _redo.add(placed.toList());
    final prev = _undo.removeLast();
    placed
      ..clear()
      ..addAll(prev);
    notifyListeners();
  }

  void redo() {
    if (_redo.isEmpty) return;
    _undo.add(placed.toList());
    final next = _redo.removeLast();
    placed
      ..clear()
      ..addAll(next);
    notifyListeners();
  }

  // Canvas actions
  void addWidget(PaletteItem item, Offset offset) {
    _snapshot();
    placed.add(PlacedWidget(id: _uuid.v4(), item: item, offset: offset));
    notifyListeners();
  }

  void select(String? id) {
    _selectedId = id;
    notifyListeners();
  }

  void move(String id, Offset newPos) {
    _snapshot();
    final w = placed.firstWhere((w) => w.id == id);
    w.offset = newPos;
    notifyListeners();
  }

  void resize(String id, Size newSize) {
    _snapshot();
    final w = placed.firstWhere((w) => w.id == id);
    w.size = newSize;
    notifyListeners();
  }

  /// Remove the currently selected widget
  void removeSelected() {
    if (_selectedId == null) return;
    _snapshot();
    placed.removeWhere((w) => w.id == _selectedId);
    _selectedId = null;
    notifyListeners();
  }

  /// Update TableProps after property edits
  void updateTableProps(TableProps newProps) {
    final w = selected;
    if (w == null) return;
    _snapshot();
    w.tableProps = newProps;
    notifyListeners();
  }

  /// Update FormProps after property edits
  void updateFormProps(FormProps newProps) {
    final w = selected;
    if (w == null) return;
    _snapshot();
    w.formProps = newProps;
    notifyListeners();
  }

  void toggleLock(String id) {
    _snapshot();
    final w = placed.firstWhere((w) => w.id == id);
    w.locked = !w.locked;
    notifyListeners();
  }

  // Persistence using services
  Future<void> saveCurrentLayout() async {
    final layout = serializeLayout();
    final wsRes = await WorkspaceService.I.getOrCreateDemo();
    wsRes.match((l) => throw Exception(l.message), (ws) async {
      final wsId = ws['id'] as String;
      final pjRes = await ProjectService.I.getOrCreateDemo(wsId);
      pjRes.match((l) => throw Exception(l.message), (proj) async {
        await ProjectService.I.upsertLayout(
          projectId: proj['id'] as String,
          layout: layout,
        );
      });
    });
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

  /// Return raw layout JSON for export or save
  Map<String, dynamic> serializeLayout() => {
    'widgets': placed.map((w) => w.toJson()).toList(),
  };
}
