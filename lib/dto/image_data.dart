import 'dart:core';

import 'package:flutter/widgets.dart';

class ImageDataDTO {
  late final Image image;
  late final String path;

  Image get getImage => image;

  set setImage(Image value) => image = value;

  String get getPath => path;

  set setPath(String value) => path = value;

  ImageDataDTO({required this.image, required this.path});
}
