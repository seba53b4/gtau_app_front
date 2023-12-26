enum CheckboxState {
  Bien,
  Faltante,
  Hundida,
  Provisoria,
  SoldadaAlMarco,
  Rota,
  MarcoDescalzado,
  SD,
}

class CheckboxHelper {
  static CheckboxState parse(String value) {
    switch (value) {
      case 'Bien':
        return CheckboxState.Bien;
      case 'Faltante':
        return CheckboxState.Faltante;
      case 'Hundida':
        return CheckboxState.Hundida;
      case 'Provisoria':
        return CheckboxState.Provisoria;
      case 'Soldada al marco':
        return CheckboxState.SoldadaAlMarco;
      case 'Rota':
        return CheckboxState.Rota;
      case 'Marco descalzado':
        return CheckboxState.MarcoDescalzado;
      case 'S/D':
        return CheckboxState.SD;
      default:
        throw ArgumentError('Valor desconocido: $value');
    }
  }
}

List<String> checkboxValuesTapa = [
  "Bien",
  "Faltante",
  "Hundida",
  "Provisoria",
  "Soldada al marco",
  "Rota",
  "Marco descalzado",
  "S/D",
];

Map<CheckboxState, bool> parseCheckboxTapa(
    List<String> valoresDesdeElServicio) {
  Map<CheckboxState, bool> estadoDeCheckbox = {};

  List<CheckboxState> estadosDeCheckbox = checkboxValuesTapa.map((valor) {
    return CheckboxHelper.parse(valor);
  }).toList();

  for (CheckboxState valor in estadosDeCheckbox) {
    estadoDeCheckbox[valor] = valoresDesdeElServicio.contains(valor.toString());
  }

  return estadoDeCheckbox;
}
