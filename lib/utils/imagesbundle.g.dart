// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imagesbundle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ImageBundleAdapter extends TypeAdapter<ImageBundle> {
  @override
  final int typeId = 1;

  @override
  ImageBundle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImageBundle(
      idtask: fields[0] as String,
      files: (fields[1] as List).cast<File>(),
    );
  }

  @override
  void write(BinaryWriter writer, ImageBundle obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.idtask)
      ..writeByte(1)
      ..write(obj.files);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageBundleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
