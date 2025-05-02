import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:widgets_palette/widgets_palette.dart';

final _uuid = const Uuid();

class PlacedWidget {
  PlacedWidget({required this.id, required this.item, required this.offset});

  final String id;
  final PaletteItem item;
  Offset offset;
}

class BuilderViewModel extends ChangeNotifier {
  final placed = <PlacedWidget>[];

  void addWidget(PaletteItem item, Offset offset) {
    placed.add(PlacedWidget(id: _uuid.v4(), item: item, offset: offset));
    notifyListeners();
  }
}
