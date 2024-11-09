class Table {
  final String name;
  final List<String> columns;
  final List<List<String>> rows = [];

  Table({
    required this.name,
    required this.columns,
  });
}
