enum ElementType {
  catchment(type: "C"),
  register(type: "R"),
  section(type: "T"),
  lot(type: "L");

  const ElementType({
    required this.type,
  });

  final String type;
}
