import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'builder_view_model.dart';
import 'canvas_widget.dart';
import 'palette_drawer.dart';

class BuilderScreen extends StatelessWidget {
  const BuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BuilderViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text('CRM Builder')),
        body: Row(
          children: const [
            // permanent palette column
            SizedBox(
              width: 260, // drawer‑like width
              child: PaletteDrawer(),
            ),
            VerticalDivider(width: 1),
            // expandable canvas area
            Expanded(child: CanvasWidget()),
          ],
        ),
      ),
    );
  }
}
