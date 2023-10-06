enum ElementType {
  catchment(type: "C"),
  register(type: "R"),
  section(type: "S");

  const ElementType({
    required this.type,
  });

  final String type;
}
