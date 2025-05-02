class TableProps {
  TableProps({
    this.rowsPerPage = 10,
    this.showToolbar = true,
    this.boundTable,
    List<String>? columns,
  }) : columns = columns ?? const [];

  int rowsPerPage;
  bool showToolbar;
  String? boundTable;
  List<String> columns;

  TableProps copy() => TableProps(
    rowsPerPage: rowsPerPage,
    showToolbar: showToolbar,
    boundTable: boundTable,
    columns: List.of(columns),
  );
}
