import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'builder_view_model.dart';
import 'package:widgets_palette/widgets_palette.dart';

class CanvasWidget extends StatelessWidget {
  const CanvasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BuilderViewModel>();

    return Stack(
      children: [
        // grid
        Positioned.fill(
          child: GestureDetector(
            onTap: () => vm.select(null),
            child: CustomPaint(painter: _GridPainter()),
          ),
        ),

        // drop target
        Positioned.fill(
          child: DragTarget<PaletteItem>(
            onAcceptWithDetails: (d) {
              final box = context.findRenderObject() as RenderBox?;
              final pos = box?.globalToLocal(d.offset) ?? Offset.zero;
              vm.addWidget(d.data, pos);
            },
            builder: (_, __, ___) => const SizedBox.expand(),
          ),
        ),
        // placed widgets
        for (final w in vm.placed)
          _RawInteractive(w: w, selected: vm.selectedId == w.id),
      ],
    );
  }
}

class _RawInteractive extends StatefulWidget {
  const _RawInteractive({required this.w, required this.selected});
  final PlacedWidget w;
  final bool selected;

  @override
  State<_RawInteractive> createState() => _RawInteractiveState();
}

class _RawInteractiveState extends State<_RawInteractive> {
  static const _grid = 20.0;
  static const _minSize = Size(80, 60);

  late Offset _pointerStart;
  late Offset _widgetStart;
  late Size _sizeStart;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<BuilderViewModel>();
    final w = widget.w;

    return Positioned(
      left: w.offset.dx,
      top: w.offset.dy,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border:
              widget.selected
                  ? Border.all(color: Colors.blueAccent, width: 2)
                  : null,
        ),
        child: Stack(
          children: [
            // entire area listens to pointer events for move
            Listener(
              onPointerDown: (e) {
                if (widget.selected || w.locked)
                  return; // let resize handle those
                _pointerStart = e.position;
                _widgetStart = w.offset;
                vm.select(w.id);
              },
              onPointerMove: (e) {
                if (!widget.selected || w.locked) return;
                final delta = e.position - _pointerStart;
                final raw = _widgetStart + delta;
                final snapped = Offset(
                  (raw.dx / _grid).round() * _grid,
                  (raw.dy / _grid).round() * _grid,
                );
                vm.move(w.id, snapped);
              },
              child: SizedBox(
                width: w.size.width,
                height: w.size.height,
                child:
                    w.item.type == PaletteType.table
                        ? TablePreviewWidget(props: w.tableProps!)
                        : FormPreviewWidget(props: w.formProps!),
              ),
            ),

            // resize handle (now larger)
            if (widget.selected && !w.locked)
              Positioned(
                right: 0,
                bottom: 0,
                child: MouseRegion(
                  cursor: SystemMouseCursors.move,
                  child: GestureDetector(
                    onPanStart: (e) {
                      _pointerStart = e.globalPosition;
                      _widgetStart = w.offset;
                      _sizeStart = w.size;
                    },
                    onPanUpdate: (e) {
                      final delta = e.globalPosition - _pointerStart;
                      final raw = Size(
                        _sizeStart.width + delta.dx,
                        _sizeStart.height + delta.dy,
                      );
                      final snapped = Size(
                        (raw.width / _grid).round() * _grid,
                        (raw.height / _grid).round() * _grid,
                      );
                      if (snapped.width >= _minSize.width &&
                          snapped.height >= _minSize.height) {
                        vm.resize(w.id, snapped);
                      }
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // lock/unlock button
            if (widget.selected)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(
                    w.locked ? Icons.lock : Icons.lock_open,
                    color: w.locked ? Colors.orange : Colors.grey,
                  ),
                  onPressed: () => vm.toggleLock(w.id),
                  tooltip: w.locked ? 'Unlock widget' : 'Lock widget',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size size) {
    const step = 20.0;
    final paint =
        Paint()
          ..color = Colors.grey.shade200
          ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += step) {
      c.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      c.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
