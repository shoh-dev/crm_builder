class TableProps {
  TableProps({
    this.rowsPerPage = 10,
    this.showToolbar = true,
    this.boundTable,
    List<String>? columns,
    this.sortColumn,
    this.sortAscending = true,
    this.searchQuery = '',
  }) : columns = columns ?? const [];

  int rowsPerPage;
  bool showToolbar;
  String? boundTable;
  List<String> columns;
  String? sortColumn;
  bool sortAscending;
  String searchQuery;

  TableProps copy() => TableProps(
    rowsPerPage: rowsPerPage,
    showToolbar: showToolbar,
    boundTable: boundTable,
    columns: List.of(columns),
    sortColumn: sortColumn,
    sortAscending: sortAscending,
    searchQuery: searchQuery,
  );
}
