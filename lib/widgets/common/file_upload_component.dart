import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'custom_elevated_button.dart';

class FileUploadComponent extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onFileAdded;

  const FileUploadComponent({Key? key, required this.onFileAdded})
      : super(key: key);

  @override
  _FileUploadComponentState createState() => _FileUploadComponentState();
}

class _FileUploadComponentState extends State<FileUploadComponent> {
  late List<Map<String, dynamic>> geoJsonSrc;
  late String fileName = 'No agregado';

  @override
  void initState() {
    super.initState();
    geoJsonSrc = [];
  }

  _sendFile() {
    print(geoJsonSrc);
    widget.onFileAdded(geoJsonSrc); // Llama al callback aquí
  }

  _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['geojson'],
    );

    if (result != null) {
      String fileContent = utf8.decode(result.files.first.bytes!);

      Map<String, dynamic> geoJsonMap = json.decode(fileContent);

      if (geoJsonMap.containsKey('features') &&
          geoJsonMap['features'] is List) {
        List<dynamic> features = geoJsonMap['features'];

        List<Map<String, dynamic>> geometries = [];

        for (var feature in features) {
          if (feature is Map<String, dynamic> &&
              feature.containsKey('geometry') &&
              feature['geometry'] is Map<String, dynamic>) {
            Map<String, dynamic> geometry = feature['geometry'];
            geometries.add(geometry);
          }
        }

        setState(() {
          geoJsonSrc.addAll(geometries);
          fileName = result.files.first.name;
        });
      } else {
        print('El GeoJSON no contiene la clave "features" o no es una lista.');
      }
    } else {
      print('Selección de archivo cancelada.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomElevatedButton(
          onPressed: _uploadFile,
          text: 'Seleccionar Archivo',
        ),
        const SizedBox(height: 16),
        if (geoJsonSrc.isNotEmpty)
          Column(
            children: [
              Text('Nombre del archivo: $fileName'),
              const SizedBox(height: 16),
              CustomElevatedButton(
                onPressed: _sendFile,
                text: 'Subir Archivo',
              ),
            ],
          ),
      ],
    );
  }
}
