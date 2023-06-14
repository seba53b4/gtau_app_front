import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gtau_app_front/widgets/map_component.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class TaskCreationScreen extends StatefulWidget {
  var type = 'inspection';

  TaskCreationScreen({required this.type});

  @override
  _TaskCreationScreenState createState() => _TaskCreationScreenState();
}

class _TaskCreationScreenState extends State<TaskCreationScreen> {
  final inputName = TextEditingController();
  DateTime startDate = DateTime.now();
  int selectedIndex = 0;
  Map<String, double>? markerCoordinate;
  String userAssigned = "not-assigned";
  String description = "";
  String numWork = "";
  String scheduledNumber = "";
  String contact = "";
  String solicitant = "";
  String numOrder = "";

  @override
  void dispose() {
    inputName.dispose();
    super.dispose();
  }

  void handleStartDateChange(DateTime date) {
    setState(() {
      startDate = date;
    });
  }

  void handleMarkerCoordinateChange(Map<String, double> coordinate) {
    setState(() {
      markerCoordinate = coordinate;
    });
  }

  void handleSubmit() {
    if (selectedIndex == 1) {
      print('Nro Trabajo: $numWork' +
          'Fecha Ingreso: ${DateFormat('yyyy-MM-dd').format(startDate)}' +
          'Ubicacion: ${markerCoordinate?['lng']} ${markerCoordinate?['lat']}\n' +
          'Usuario asignado: $userAssigned' +
          'Orden Servicio: $numOrder ' +
          'Solicitante: $solicitant ' +
          'Contacto: $contact Descripcion: $description');
    } else {
      print('Programada: $scheduledNumber Descripcion: $description');
    }
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
                AppLocalizations.of(context)!.createTaskPage_title,
                style: TextStyle(fontSize: 32.0),
              ),
              const SizedBox(height: 20.0),
              ToggleButtons(
                isSelected: [selectedIndex == 0, selectedIndex == 1],
                onPressed: (int index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                children: const [
                  Text('CreateTaskPage_scheduled'),
                  Text('CreateTaskPage_inspection'),
                ],
              ),
              const SizedBox(height: 20.0),
              if (selectedIndex == 1)
                Column(
                  children: [
                    const Text(
                      'CreateTaskPage_numberWorkTitle',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    TextFormField(
                      controller: inputName,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'CreateTaskPage_startDateTitle',
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
                          initialValue:
                              DateFormat('yyyy-MM-dd').format(startDate),
                          enabled: false,
                          readOnly: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'CreateTaskPage_selectUbicationTitle',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    SizedBox(
                      height: 400.0,
                      child:
                          MapComponent(), // Aquí puedes agregar el componente de mapa de Flutter que desees utilizar
                    ),
                    if (markerCoordinate != null &&
                        markerCoordinate!.isNotEmpty)
                      Column(
                        children: [
                          Text(
                            'Latitud: ${markerCoordinate?['lat']}',
                            style: const TextStyle(fontSize: 18.0),
                          ),
                          Text(
                            'Longitud: ${markerCoordinate?['lng']}',
                            style: const TextStyle(fontSize: 18.0),
                          ),
                        ],
                      ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'CreateTaskPage_assignedUserTitle',
                      style: TextStyle(fontSize: 24.0),
                    ),
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
                    Text(
                      'CreateTaskPage_orderServiceNumberTitle',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        setState(() {
                          numOrder = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'CreateTaskPage_solicitantTitle',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'default_placeHolderInputText',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          solicitant = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'CreateTaskPage_contactTitle',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'default_placeHolderInputText',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          contact = value;
                        });
                      },
                    ),
                  ],
                ),
              if (selectedIndex == 0)
                Column(
                  children: [
                    const Text(
                      'CreateTaskPage_scheduled',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'default_placeHolderInputText',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          scheduledNumber = value;
                        });
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 10.0),
              const Text(
                'default_descriptionTitle',
                style: TextStyle(fontSize: 24.0),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'default_descriptionPlaceholder',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: handleSubmit,
                child: const Text('CreateTaskPage_submitButton'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
