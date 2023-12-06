import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  _pickAFile() async {
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

  _removeGeometry() {
    setState(() {
      geoJsonSrc.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomElevatedButton(
                onPressed: _pickAFile,
                text: AppLocalizations.of(context)!.file_upload_btn,
              ),
              const SizedBox(height: 8),
              Visibility(
                visible: geoJsonSrc.isNotEmpty,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 24),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: [
                        InputChip(
                          label: Text(fileName),
                          onDeleted: () => _removeGeometry(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }
}
