import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';

import '../../utils/common_utils.dart';
import 'custom_elevated_button.dart';

class FileUploadComponent extends StatefulWidget {
  final Function(Map<String, dynamic>) onFileAdded;
  final Function? onDeleteSelection;
  final bool? errorVisible;
  final String? errorMessage;

  const FileUploadComponent(
      {Key? key,
      required this.onFileAdded,
      required this.errorVisible,
      this.errorMessage,
      this.onDeleteSelection})
      : super(key: key);

  @override
  _FileUploadComponentState createState() => _FileUploadComponentState();
}

class _FileUploadComponentState extends State<FileUploadComponent> {
  late Map<String, dynamic> geoJsonSrc;
  late String fileName = 'No agregado';

  @override
  void initState() {
    super.initState();
    geoJsonSrc = {};
  }

  _pickAFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['geojson'],
    );

    if (result != null) {
      String fileContent = utf8.decode(result.files.first.bytes!);

      Map<String, dynamic> geoJsonMap = json.decode(fileContent);

      setState(() {
        geoJsonSrc.addAll(geoJsonMap);
        fileName = result.files.first.name;
      });
      widget.onFileAdded(geoJsonMap);
    } else {
      printOnDebug('Selección de archivo cancelada.');
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
          Visibility(
            visible: geoJsonSrc.isNotEmpty,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    InputChip(
                      label: Text(fileName),
                      onDeleted: () {
                        if (widget.onDeleteSelection != null) {
                          widget.onDeleteSelection!();
                        }
                        _removeGeometry();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          CustomElevatedButton(
            onPressed: _pickAFile,
            text: geoJsonSrc.isEmpty
                ? AppLocalizations.of(context)!.file_upload_btn
                : AppLocalizations.of(context)!.file_upload_btn_change,
          ),
          if (widget.errorVisible != null && !(widget.errorVisible!))
            const SizedBox(height: 8),
          Visibility(
            visible: widget.errorVisible ?? false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  widget.errorMessage ?? 'Se ha producido un error',
                  style: TextStyle(color: redColor, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
