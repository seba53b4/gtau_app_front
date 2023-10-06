import 'dart:io';

import 'package:hive/hive.dart';

part 'imagesbundle.g.dart';

@HiveType(typeId: 1)
class ImageBundle {
  ImageBundle({
    required this.idtask,
    required this.files,
  });
  @HiveField(0)
  String idtask;

  @HiveField(1)
  List<File> files;
}