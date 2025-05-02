class FormProps {
  FormProps({this.boundTable, this.fields = const []});

  String? boundTable;
  List<String> fields;

  FormProps copy() =>
      FormProps(boundTable: boundTable, fields: List.of(fields));
}
