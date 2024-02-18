enum ElementType {
  catchment(type: "C", name: 'CAPTACION', pluralName: 'CAPTACIONES'),
  register(type: "R", name: 'REGISTRO', pluralName: 'REGISTROS'),
  section(type: "T", name: 'TRAMO', pluralName: 'TRAMOS'),
  lot(type: "P", name: 'PARCELA', pluralName: 'PARCELAS');

  const ElementType(
      {required this.type, required this.name, required this.pluralName});

  final String type;
  final String name;
  final String pluralName;
}
