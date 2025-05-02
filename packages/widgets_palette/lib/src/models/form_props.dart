class FormProps {
  FormProps({
    this.boundTable,
    this.fields = const [],
    this.fieldTypes = const {},
  });

  String? boundTable;
  List<String> fields;
  Map<String, String> fieldTypes;

  FormProps copy() => FormProps(
    boundTable: boundTable,
    fields: List.of(fields),
    fieldTypes: Map.of(fieldTypes),
  );
}
