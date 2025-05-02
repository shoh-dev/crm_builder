import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:widgets_palette/widgets_palette.dart';
import 'package:core/src/services/supabase_service.dart';

/// Very bare‑bones visual for the builder canvas only.
class TablePreviewWidget extends StatelessWidget {
  const TablePreviewWidget({super.key, required this.props});
  final TableProps props;

  @override
  Widget build(BuildContext context) {
    if (props.boundTable == null) {
      return Container(
        width: 220,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade600),
        ),
        child: const Center(
          child: Text('Table', style: TextStyle(fontSize: 18)),
        ),
      );
    }

    return _DataPreview(props: props);
  }
}

class _DataPreview extends StatefulWidget {
  final TableProps props;
  const _DataPreview({required this.props});

  @override
  State<_DataPreview> createState() => _DataPreviewState();
}

class _DataPreviewState extends State<_DataPreview> {
  late Future<({List<Map<String, dynamic>> data, int count})> _dataFuture;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetch();
  }

  @override
  void didUpdateWidget(_DataPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refetch if data binding or search/sort properties changed
    if (oldWidget.props.boundTable != widget.props.boundTable ||
        oldWidget.props.columns != widget.props.columns ||
        oldWidget.props.rowsPerPage != widget.props.rowsPerPage ||
        oldWidget.props.searchQuery != widget.props.searchQuery ||
        oldWidget.props.sortColumn != widget.props.sortColumn ||
        oldWidget.props.sortAscending != widget.props.sortAscending) {
      _currentPage = 0; // Reset to first page
      _dataFuture = _fetch();
    }
  }

  Future<({List<Map<String, dynamic>> data, int count})> _fetch() async {
    final p = widget.props;
    final cols = p.columns.isEmpty ? '*' : p.columns.join(',');

    PostgrestFilterBuilder<PostgrestList> query = SupabaseService.I.client
        .from(p.boundTable!)
        .select(cols);

    // Apply search if query exists
    if (p.searchQuery.isNotEmpty) {
      query = query.ilike(p.columns.first, '%${p.searchQuery}%');
    }

    // Get total count with search filter
    final countResponse = await query.count();
    final count = countResponse.count;

    // Apply sorting if column is selected
    // if (p.sortColumn != null) {
    //   query = query.order(column).select();
    // }

    // Get paginated data
    final data = await query.range(
      _currentPage * p.rowsPerPage,
      (_currentPage + 1) * p.rowsPerPage - 1,
    );

    return (data: data, count: count);
  }

  void _changePage(int newPage) {
    setState(() {
      _currentPage = newPage;
      _dataFuture = _fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.props;
    return Column(
      children: [
        if (p.showToolbar)
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey.shade200,
            child: Row(
              children: [
                Text('${p.rowsPerPage} rows per page'),
                const Spacer(),
                if (p.sortColumn != null)
                  Text(
                    'Sorted by: ${p.sortColumn} (${p.sortAscending ? "↑" : "↓"})',
                  ),
                if (p.searchQuery.isNotEmpty) Text('Search: ${p.searchQuery}'),
                const Spacer(),
                Text('Bound to: ${p.boundTable}'),
              ],
            ),
          ),
        Expanded(
          child: FutureBuilder<({List<Map<String, dynamic>> data, int count})>(
            future: _dataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                return const Center(child: Text('No data available'));
              }

              final rows = snapshot.data!.data;
              final totalCount = snapshot.data!.count;
              final cols =
                  p.columns.isEmpty ? rows.first.keys.toList() : p.columns;

              final totalPages = (totalCount / p.rowsPerPage).ceil();

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          sortColumnIndex:
                              p.sortColumn == null
                                  ? null
                                  : cols.indexOf(p.sortColumn!),
                          sortAscending: p.sortAscending,
                          columns:
                              cols
                                  .map(
                                    (c) => DataColumn(
                                      label: Text(c),
                                      onSort: (_, __) {
                                        // Sort is handled by Supabase
                                      },
                                    ),
                                  )
                                  .toList(),
                          rows:
                              rows
                                  .map(
                                    (r) => DataRow(
                                      cells:
                                          cols
                                              .map(
                                                (c) =>
                                                    DataCell(Text('${r[c]}')),
                                              )
                                              .toList(),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ),
                  ),
                  if (p.showToolbar)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.first_page),
                            onPressed:
                                _currentPage > 0 ? () => _changePage(0) : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed:
                                _currentPage > 0
                                    ? () => _changePage(_currentPage - 1)
                                    : null,
                          ),
                          Text(
                            'Page ${_currentPage + 1} of $totalPages',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed:
                                _currentPage < totalPages - 1
                                    ? () => _changePage(_currentPage + 1)
                                    : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.last_page),
                            onPressed:
                                _currentPage < totalPages - 1
                                    ? () => _changePage(totalPages - 1)
                                    : null,
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
