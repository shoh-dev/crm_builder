import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fpdart/src/either.dart';

import 'builder_view_model.dart';
import 'canvas_widget.dart';
import 'palette_drawer.dart';
import 'properties_panel.dart';
import 'package:core/src/services/workspace_service.dart';
import 'package:core/src/services/project_service.dart';
import 'package:core/src/failure.dart';

class UndoIntent extends Intent {
  const UndoIntent();
}

class RedoIntent extends Intent {
  const RedoIntent();
}

class DeleteIntent extends Intent {
  const DeleteIntent();
}

class BuilderScreen extends StatefulWidget {
  const BuilderScreen({super.key});

  @override
  State<BuilderScreen> createState() => _BuilderScreenState();
}

class _BuilderScreenState extends State<BuilderScreen> {
  String? _workspaceId;
  String? _projectId;
  Map<String, dynamic>? _layout;
  bool _loading = true;
  Failure? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // ── Workspace ────────────────────────────────────────────────────
    final wsRes = await WorkspaceService.I.getOrCreateDemo();
    await wsRes.match(
      (l) async {
        setState(() {
          _error = l;
          _loading = false;
        });
      },
      (ws) async {
        _workspaceId = ws!['id'] as String;

        // ── Project ────────────────────────────────────────────────
        final pjRes = await ProjectService.I.getOrCreateDemo(_workspaceId!);
        pjRes.match(
          (l) => setState(() {
            _error = l;
            _loading = false;
          }),
          (pj) => setState(() {
            _projectId = pj['id'] as String;
            _layout = (pj['layout'] ?? const {}) as Map<String, dynamic>;
            _loading = false;
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error.toString())));
    }

    return ChangeNotifierProvider(
      create: (_) => BuilderViewModel()..load(_layout),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CRM Builder'),
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete selected widget',
                  onPressed:
                      () => context.read<BuilderViewModel>().removeSelected(),
                );
              },
            ),
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () async {
                    final json =
                        context.read<BuilderViewModel>().serializeLayout();
                    final res = await ProjectService.I.upsertLayout(
                      projectId: _projectId!,
                      layout: json,
                    );

                    res.fold(
                      (l) => ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(l.message))),
                      (_) => ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Saved'))),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: Shortcuts(
          shortcuts: {
            // ⌘ Z / Ctrl Z
            LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyZ):
                const UndoIntent(),
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ):
                const UndoIntent(),
            // ⇧ ⌘ Z / Ctrl Shift Z
            LogicalKeySet(
                  LogicalKeyboardKey.meta,
                  LogicalKeyboardKey.shift,
                  LogicalKeyboardKey.keyZ,
                ):
                const RedoIntent(),
            LogicalKeySet(
                  LogicalKeyboardKey.control,
                  LogicalKeyboardKey.shift,
                  LogicalKeyboardKey.keyZ,
                ):
                const RedoIntent(),
            // Delete key
            LogicalKeySet(LogicalKeyboardKey.delete): const DeleteIntent(),
          },
          child: Actions(
            actions: {
              UndoIntent: CallbackAction<UndoIntent>(
                onInvoke: (_) => context.read<BuilderViewModel>().undo(),
              ),
              RedoIntent: CallbackAction<RedoIntent>(
                onInvoke: (_) => context.read<BuilderViewModel>().redo(),
              ),
              DeleteIntent: CallbackAction<DeleteIntent>(
                onInvoke:
                    (_) => context.read<BuilderViewModel>().removeSelected(),
              ),
            },
            child: Row(
              children: const [
                SizedBox(width: 260, child: PaletteDrawer()),
                VerticalDivider(width: 1),
                Expanded(child: CanvasWidget()),
                VerticalDivider(width: 1),
                SizedBox(width: 260, child: PropertiesPanel()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
