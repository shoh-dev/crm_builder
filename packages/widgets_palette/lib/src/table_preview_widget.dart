import 'package:flutter/material.dart';

/// Very bare‑bones visual for the builder canvas only.
class TablePreviewWidget extends StatelessWidget {
  const TablePreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade600),
      ),
      child: const Center(child: Text('Table', style: TextStyle(fontSize: 18))),
    );
  }
}
