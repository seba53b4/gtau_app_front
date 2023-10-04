import 'dart:core';

import 'package:flutter/widgets.dart';

class ImageDataDTO {
  late final Image image;
  late final String path;
  late final bool fromBlob;

  Image get getImage => image;

  set setImage(Image value) => image = value;

  String get getPath => path;

  set setPath(String value) => path = value;

  bool get getFromBlob => fromBlob;

  set setFromBlob(bool value) => fromBlob = value;

  ImageDataDTO(
      {required this.image, required this.path, required this.fromBlob});
}
