import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/models/enums/message_type.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:gtau_app_front/viewmodels/informe_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'custom_elevated_button.dart';

class InformeUploadComponent extends StatefulWidget {
  // final Function(List<Map<String, dynamic>>) onFileAdded;
  final int? idTask; 

  const InformeUploadComponent({Key? key, this.idTask/*, required this.onFileAdded*/})
      : super(key: key);

  @override
  _InformeUploadComponentState createState() => _InformeUploadComponentState();
}

class _InformeUploadComponentState extends State<InformeUploadComponent> {
  late List<Map<String, dynamic>> informeBase64;
  InformeViewModel? informeViewModel;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _initializeData();
    informeViewModel = Provider.of<InformeViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    informeViewModel?.reset();
    super.dispose();
  }

  void _initializeData() async {
    List<Map<String, dynamic>> informeBase64Received = await _fetchTaskInformes(context, widget.idTask!);
    setState(() {
      informeBase64 = informeBase64Received;
    });
  }

  @override
  void initState() {
    super.initState();
    informeBase64 = [];
  }

  _pickAFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      String base64 = base64Encode(result.files.first.bytes!);
      setState(() {
        informeBase64.add({
          "base64": base64,
          "fileName": result.files.first.name
        });
      });
      String url = await _uploadTaskInformes(context, widget.idTask!, informeBase64.elementAt(0));
      informeBase64.elementAt(0)['url'] = url;
    } else {
      print('Selección de archivo cancelada.');
    }
  }

  _removeInforme() async{
    bool canRemove = await _removeTaskInformes(context, widget.idTask!, informeBase64.elementAt(0)['url']);
    if(canRemove){
      setState(() {
        informeBase64 = [];
      });
    }
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
              Visibility(
                visible: informeBase64.isEmpty,
                child: CustomElevatedButton(
                    onPressed: _pickAFile,
                    text: AppLocalizations.of(context)!.file_upload_btn,
                ),
              ),
              const SizedBox(height: 8),
              Visibility(
                visible: informeBase64.isNotEmpty,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 24),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: [
                          CustomElevatedButton(
                            onPressed: () => downloadInforme(informeBase64.elementAt(0)['url']),
                            text: AppLocalizations.of(context)!.download_informe_btn,
                          ),
                          CustomElevatedButton(
                            messageType: MessageType.error,
                            onPressed: _removeInforme,
                            text: AppLocalizations.of(context)!.delete_informe_btn,
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

Future<List<Map<String, dynamic>>> _fetchTaskInformes(BuildContext context, int idTask) async {
  final token = Provider.of<UserProvider>(context, listen: false).getToken;
  final informeViewModel = Provider.of<InformeViewModel>(context, listen: false);
  try {
    return await informeViewModel.fetchTaskInformes(token!, idTask);
  } catch (error) {
    print(error);
    throw Exception('Error al obtener los datos');
  }
}

Future<String> _uploadTaskInformes(BuildContext context, int idTask, Map<String, dynamic> informe) async {
  final token = Provider.of<UserProvider>(context, listen: false).getToken;
  final informeViewModel = Provider.of<InformeViewModel>(context, listen: false);
  try {
    return await informeViewModel.uploadInforme(token!, idTask, informe);
  } catch (error) {
    print(error);
    throw Exception('Error al subir el informe}');
  }
}

Future<bool> _removeTaskInformes(BuildContext context, int idTask, String url) async {
  final token = Provider.of<UserProvider>(context, listen: false).getToken;
  final informeViewModel = Provider.of<InformeViewModel>(context, listen: false);
  try {
    return await informeViewModel.deleteInforme(token!, idTask, url);
  } catch (error) {
    print(error);
    throw Exception('Error al subir el informe}');
  }
}

Future<void> downloadInforme(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}

