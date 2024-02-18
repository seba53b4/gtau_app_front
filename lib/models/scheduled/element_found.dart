enum FoundStatusType {
  NotFound,
  Found,
}

extension FoundStatusTypeExtension on FoundStatusType {
  String toLabel() {
    switch (this) {
      case FoundStatusType.NotFound:
        return 'No Encontrado';
      case FoundStatusType.Found:
        return 'Encontrado';
    }
  }
}

bool isNotFound(String statusFound) {
  return statusFound == FoundStatusType.NotFound.toLabel();
}

String parseElementFoundLabel(bool statusNotFound) {
  return statusNotFound
      ? FoundStatusType.NotFound.toLabel()
      : FoundStatusType.Found.toLabel();
}

bool? isElementNotFound(String statusNotFoundLabel) {
  return !(statusNotFoundLabel == FoundStatusType.Found.toLabel());
}
