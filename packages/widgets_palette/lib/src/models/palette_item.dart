enum PaletteType { table /* later: form, chart, ... */ }

class PaletteItem {
  const PaletteItem({
    required this.type,
    required this.name,
    required this.icon,
  });

  final PaletteType type;
  final String name;
  final dynamic icon; // IconData | Widget – keep loose for now
}
