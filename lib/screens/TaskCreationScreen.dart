import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import '../models/task.dart';

class TaskCreationScreen extends StatefulWidget {
  var type = 'inspection';
  bool detail = false;
  int? idTask = 0;
  TaskCreationScreen({required this.type, this.detail = false, this.idTask = 0});

  @override
  _TaskCreationScreenState createState() => _TaskCreationScreenState();
}

class _TaskCreationScreenState extends State<TaskCreationScreen> {
  late Task task;
  final inputName = TextEditingController();
  late DateTime startDate;
  late DateTime releasedDate;
  int selectedIndex = 0;
  String userAssigned = "not-assigned";
  final descriptionController = TextEditingController();
  final numWorkController = TextEditingController();
  final locationController = TextEditingController();
  final scheduledNumberController = TextEditingController();
  final contactController = TextEditingController();
  final applicantController = TextEditingController();
  final userAssignedController = TextEditingController();
  final lengthController = TextEditingController();
  final materialController = TextEditingController();
  final observationsController = TextEditingController();
  final conclusionsController = TextEditingController();
  final addDateController = TextEditingController();
  final releasedDateController = TextEditingController();
  final String formatDate = 'dd-MM-yyyy';

  String numOrder = "";


  Future<bool> fetchTask() async {
    final token = Provider.of<UserProvider>(context, listen: false).getToken;
    try {
      final baseUrl = dotenv.get('API_TASKS_URL', fallback: 'NOT_FOUND');
      final url = Uri.parse('$baseUrl/${widget.idTask}');

      final response = await http.get(url,
          headers: {'Content-Type': 'application/json', 'Authorization': "BEARER $token"});

      if (response.statusCode == 200) {
        final taskData = json.decode(response.body);
        setState(() {
          task = Task(
            id: taskData['id'],
            status: taskData['status'],
            inspectionType: taskData['inspectionType'],
            workNumber: taskData['workNumber'],
            addDate: DateTime.parse(taskData['addDate']),
            applicant: taskData['applicant'],
            location: taskData['location'],
            description: taskData['description'],
            releasedDate: taskData['releasedDate'] != null ? DateTime.parse(taskData['releasedDate']) : null,
            user: taskData['user'],
            length: taskData['length'],
            material: taskData['material'],
            observations: taskData['observations'],
            conclusions: taskData['conclusions'],
          );

           numWorkController.text = task.workNumber!;
           inputName.text = "HOlis";
           descriptionController.text = task.description!;
           applicantController.text = task.applicant!;
           locationController.text = task.location!;
           userAssignedController.text = task.user!;
           lengthController.text = task.length!;
           materialController.text = task.material!;
           conclusionsController.text = task.conclusions!;
           observationsController.text = task.observations!;
           startDate = task.addDate!;
           if (task.releasedDate != null) {
             releasedDateController.text = DateFormat(formatDate).format(task.releasedDate!).toString();
           }
           addDateController.text = DateFormat(formatDate).format(task.addDate!).toString();

        });

        return true;
      } else {
        print('No se pudieron traer datos}');
        return false;
      }
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos');
    }
  }

  Future<bool> updateTask(Map<String, dynamic> body)  async {
    final token = Provider.of<UserProvider>(context, listen: false).getToken;


    try {
      final baseUrl = dotenv.get('API_TASKS_URL', fallback: 'NOT_FOUND');
      final url = Uri.parse('$baseUrl/${widget.idTask}');

      final String jsonBody = jsonEncode(body);

      final response = await http.put(
          url,
          headers: {'Content-Type': 'application/json', 'Authorization': "BEARER $token"},
          body: jsonBody
      );

      if (response.statusCode == 200) {
        print('Tarea ha sido actualizada correctamente');
        return true;
      } else {
        print(response.body);
        print('No se pudieron traer datos');
        return false;
      }
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos');
    }
  }

  String formattedDateToUpdate(String dateString){

    DateFormat inputFormat = DateFormat(formatDate);
    DateTime date = inputFormat.parse(dateString);

    String formattedDate = date.toUtc().toIso8601String();

    return formattedDate;
  }




  Future<void> initializeTask() async {
    await fetchTask();
  }

  @override
  void dispose() {
    inputName.dispose();
    descriptionController.dispose();
    numWorkController.dispose();
    locationController.dispose();
    scheduledNumberController.dispose();
    contactController.dispose();
    applicantController.dispose();
    userAssignedController.dispose();
    lengthController.dispose();
    materialController.dispose();
    observationsController.dispose();
    conclusionsController.dispose();
    addDateController.dispose();
    releasedDateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.detail){
      widget.type == 'inspection' ? selectedIndex = 1 : selectedIndex = 0;
      releasedDate = DateTime.now();
      initializeTask();
    } else {
      startDate = DateTime.now();
    }
  }

  void handleStartDateChange(DateTime date) {
    setState(() {
      startDate = date;
    });
  }

  void handleSubmit() {
    if (selectedIndex == 1) {
      print('Nro Trabajo: ${numWorkController.text}' +
          'Fecha Ingreso: ${DateFormat(formatDate).format(startDate)}' +
          'Ubicacion: ${locationController.text}' +
          'Usuario asignado: $userAssigned' +
          'Orden Servicio: $numOrder ' +
          'Solicitante: ${applicantController.text} ');
    } else {
      print('Programada: ${scheduledNumberController.text} Descripcion: ${descriptionController.text}');
    }
  }

  Map<String, dynamic> createBodyToUpdate(){
    late String addDateUpdated = formattedDateToUpdate(addDateController.text);
     final Map<String, dynamic> requestBody = {
      "status": task.status,
      "inspectionType": task.inspectionType,
      "workNumber": numWorkController.text,
      "addDate": addDateUpdated,
      "applicant": applicantController.text,
      "location": locationController.text,
      "description": descriptionController.text,
      "releasedDate": task.releasedDate == null ? null : formattedDateToUpdate(addDateController.text),
      "user": userAssignedController.text,
      "length": lengthController.text,
      "material": materialController.text,
      "observations": observationsController.text,
      "conclusions": conclusionsController.text
      // "status": "DOING",
      // "inspectionType": "Inspection Type 5",
      // "workNumber": "Work Number 5",
      // "addDate": "2023-06-13T00:00:00.000+00:00",
      // "applicant": "Applicant 13",
      // "location": "Location 13",
      // "description": "Description 13",
      // "releasedDate": null,
      // "user": "gtau-oper",
      // "length": "Length 13",
      // "material": "Material 13",
      // "observations": "Observations 13",
      // "conclusions": "Conclusions 13"
    };
     return requestBody;
  }

  void handleEditTask () async {
    Map<String, dynamic> requestBody = createBodyToUpdate();
    await updateTask(requestBody);
  }

  void handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 36.0),
              Text(
                widget.detail ? "Editar Tarea" : AppLocalizations.of(context)!.createTaskPage_title,
                style: TextStyle(fontSize: 32.0),
              ),
              const SizedBox(height: 20.0),
              if (!widget.detail)
                Column(
                  children: [
                    ToggleButtons(
                      isSelected: [selectedIndex == 0, selectedIndex == 1],
                      onPressed: (int index) {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      children: [
                        Text(AppLocalizations.of(context)!.createTaskPage_scheduled),
                        Text(AppLocalizations.of(context)!.createTaskPage_inspection),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                  ],
                ),
              const SizedBox(height: 20.0),
              if (selectedIndex == 1)
                Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.createTaskPage_numberWorkTitle,
                      style: TextStyle(fontSize: 24.0),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.default_placeHolderInputText,
                        border: OutlineInputBorder(),
                      ),
                      controller: numWorkController,
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      AppLocalizations.of(context)!.createTaskPage_startDateTitle,
                      style: TextStyle(fontSize: 24.0),
                    ),
                    InkWell(
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          handleStartDateChange(pickedDate);
                        }
                      },
                      child: IgnorePointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Select Date and Time',
                          ),
                          //initialValue:  DateFormat('dd-MM-yyyy').format(startDate),
                          controller: addDateController,
                          enabled: false,
                          readOnly: true,
                        ),
                      ),
                    ),
                    if (widget.detail)
                    const SizedBox(height: 10.0),
                    Text(
                      'Fecha de Realización',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    InkWell(
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: releasedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          handleStartDateChange(pickedDate);
                        }
                      },
                      child: IgnorePointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Select Date and Time',
                          ),
                          //initialValue:  DateFormat('dd-MM-yyyy').format(startDate),
                          controller: releasedDateController,
                          enabled: false,
                          readOnly: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      AppLocalizations.of(context)!.createTaskPage_selectUbicationTitle,
                      style: TextStyle(fontSize: 24.0),
                    ),
                    TextFormField(
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.default_placeHolderInputText,
                          border: OutlineInputBorder(),
                        ),
                        controller: locationController,
                      ),
                    const SizedBox(height: 10.0),
                    Text(
                      AppLocalizations.of(context)!.createTaskPage_assignedUserTitle,
                      style: TextStyle(fontSize: 24.0),
                    ),
                    if (!widget.detail)
                    DropdownButton<String>(
                      value: userAssigned,
                      onChanged: (String? value) {
                        setState(() {
                          userAssigned = value!;
                        });
                      },
                      items: const [
                        DropdownMenuItem<String>(
                          value: 'not-assigned',
                          child: Text('Elija una opción'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'operario1',
                          child: Text('Operario A'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'operario2',
                          child: Text('Operario B'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'operario3',
                          child: Text('Operario C'),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    if (widget.detail)
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.default_placeHolderInputText,
                        border: OutlineInputBorder(),
                      ),
                      controller: userAssignedController,
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      AppLocalizations.of(context)!.createTaskPage_solicitantTitle,
                      style: TextStyle(fontSize: 24.0),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.default_placeHolderInputText,
                        border: OutlineInputBorder(),
                      ),
                      controller: applicantController,
                    ),
                    const SizedBox(height: 10.0)

                  ],
                ),
              if (selectedIndex == 0)
                Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.createTaskPage_scheduled,
                      style: TextStyle(fontSize: 24.0),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.default_placeHolderInputText,
                        border: OutlineInputBorder(),
                      ),
                      controller: scheduledNumberController,
                    ),
                  ],
                ),
              const SizedBox(height: 10.0),
              Text(
                AppLocalizations.of(context)!.default_descriptionTitle,
                style: TextStyle(fontSize: 24.0),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.default_descriptionPlaceholder,
                  border: const OutlineInputBorder(),
                ),
                controller: descriptionController,
              ),
              if (widget.detail)
                Container(
                  child:Column(
                    children: [
                      const SizedBox(height: 10.0),
                      Text(
                        'Longitud',
                        style: TextStyle(fontSize: 24.0),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.default_descriptionPlaceholder,
                          border: const OutlineInputBorder(),
                        ),
                        controller: lengthController,
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        'Material',
                        style: TextStyle(fontSize: 24.0),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.default_descriptionPlaceholder,
                          border: const OutlineInputBorder(),
                        ),
                        controller: materialController,
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        'Observaciones',
                        style: TextStyle(fontSize: 24.0),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.default_descriptionPlaceholder,
                          border: const OutlineInputBorder(),
                        ),
                        controller: observationsController,
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        'Conclusiones',
                        style: TextStyle(fontSize: 24.0),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.default_descriptionPlaceholder,
                          border: const OutlineInputBorder(),
                        ),
                        controller: conclusionsController,
                      ),
                    ],
                  ),
                ),
              Container(
                height: 50.0,
                margin: EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.detail)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: handleCancel,
                        child: const Text('Cancelar'),
                      ),
                    const SizedBox(width: 10.0),
                    ElevatedButton(
                      onPressed: widget.detail ? handleEditTask : handleSubmit,
                      child: Text(AppLocalizations.of(context)!.createTaskPage_submitButton),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
