import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'builder_view_model.dart';
import 'package:widgets_palette/widgets_palette.dart';

class CanvasWidget extends StatelessWidget {
  const CanvasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BuilderViewModel>();
    debugPrint('Canvas rebuild: ${vm.placed.length} widgets');

    return DragTarget<PaletteItem>(
      onAcceptWithDetails: (details) {
        final renderBox = context.findRenderObject() as RenderBox?;
        final local = renderBox?.globalToLocal(details.offset) ?? Offset.zero;
        vm.addWidget(details.data, local);
      },
      builder: (_, __, ___) {
        if (vm.placed.isEmpty) {
          return const Center(child: Text('No widgets on canvas'));
        }
        return CustomPaint(
          painter: _GridPainter(),
          child: Stack(
            children: [
              for (final w in vm.placed)
                Positioned(
                  left: w.offset.dx,
                  top: w.offset.dy,
                  child: GestureDetector(
                    onTap: () => vm.select(w.id),
                    child: _SelectableFrame(
                      selected: vm.selectedId == w.id,
                      child: SizedBox(
                        width: w.size.width,
                        height: w.size.height,
                        child: TablePreviewWidget(props: w.tableProps!),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SelectableFrame extends StatelessWidget {
  const _SelectableFrame({required this.selected, required this.child});
  final bool selected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          selected
              ? BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2),
              )
              : null,
      child: child,
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size size) {
    const step = 20.0;
    final p =
        Paint()
          ..color = Colors.grey.shade200
          ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += step) {
      c.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      c.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
