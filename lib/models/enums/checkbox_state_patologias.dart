enum CheckboxStatePathology {
  Danio,
  Raiz,
  PiedrasOEscombros,
}

class CheckboxHelper {
  static CheckboxStatePathology parse(String value) {
    switch (value) {
      case 'Daño':
        return CheckboxStatePathology.Danio;
      case 'Raiz':
        return CheckboxStatePathology.Raiz;
      case 'Piedras o escombros':
        return CheckboxStatePathology.PiedrasOEscombros;
      default:
        throw ArgumentError('Valor desconocido: $value');
    }
  }
}

CheckboxStatePathology parseStringToCheckboxStatePathology(String value) {
  switch (value) {
    case 'Danio':
      return CheckboxStatePathology.Danio;
    case 'Raiz':
      return CheckboxStatePathology.Raiz;
    case 'PiedrasOEscombros':
      return CheckboxStatePathology.PiedrasOEscombros;
    default:
      throw ArgumentError('Valor desconocido: $value');
  }
}

List<CheckboxStatePathology> parseListPathologies(List<String> values) {
  return values
      .map((value) => parseStringToCheckboxStatePathology(value))
      .toList();
}

List<String> getPathologiesValues() {
  return CheckboxStatePathology.values
      .map((value) => value.toString().split('.').last)
      .toList();
}
