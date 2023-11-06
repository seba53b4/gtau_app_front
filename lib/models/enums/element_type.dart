enum ElementType {
  catchment(type: "C"),
  register(type: "R"),
  section(type: "T"),
  lot(type: "P");

  const ElementType({
    required this.type,
  });

  final String type;
}
