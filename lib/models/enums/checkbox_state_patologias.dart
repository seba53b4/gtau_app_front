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

List<String> checkboxValuesPathologies = [
  "Daño",
  "Raiz",
  "Piedras o escombros",
];

Map<CheckboxStatePathology, bool> parseCheckboxPathologies(
    List<String> listChecks) {
  Map<CheckboxStatePathology, bool> estadoDeCheckbox = {};

  List<CheckboxStatePathology> estadosDeCheckbox =
      checkboxValuesPathologies.map((valor) {
    return CheckboxHelper.parse(valor);
  }).toList();

  for (CheckboxStatePathology valor in estadosDeCheckbox) {
    estadoDeCheckbox[valor] = listChecks.contains(valor.toString());
  }

  return estadoDeCheckbox;
}
