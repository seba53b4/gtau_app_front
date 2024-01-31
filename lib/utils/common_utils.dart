import 'package:flutter/foundation.dart';

void printOnDebug(Object? message) {
  if (kDebugMode) {
    print(message);
  }
}
