import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gtau_app_front/models/task.dart';
import 'package:gtau_app_front/widgets/task_list_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class TaskList extends StatefulWidget {

  final String status;
  const TaskList({Key? key, required this.status}) : super(key: key);

  @override
  _TaskListComponentState createState() => _TaskListComponentState();
}

class _TaskListComponentState extends State<TaskList> {
  List<Task> tasks = [];
  int page = 0;
  int size = 2;

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String search = '';

  @override
  void initState() {
    super.initState();
    initializeTasks();
  }

  void changeValue() {
    setState(() {
      page += 1; // Cambiar el valor de la variable
    });
  }

  Future<void> initializeTasks() async {
    await fetchTasksFromUser();
  }

  Future<bool> fetchTasksFromUser() async {
    final token = Provider.of<UserProvider>(context, listen: false).getToken;
    final user = Provider.of<UserProvider>(context, listen: false).userName;
    try {
      final baseUrl = dotenv.get('API_TASKS_BY_USER_N_TYPE_URL', fallback: 'NOT_FOUND');
      final url = Uri.parse('$baseUrl?page=$page&size=$size&user=$user&status=${widget.status}');

      final response = await http.get(url,
          headers: {'Content-Type': 'application/json', 'Authorization': "BEARER $token"});

      if (response.statusCode == 200) {
        print('Se obtuvieron tareas ${widget.status}');
        final data = json.decode(response.body);
        final content = data['content'];

        tasks = content.map<Task>((taskData) {
          return Task(
            id: taskData['id'],
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
        }).toList();

        setState(() {
          tasks = tasks;
        });

        return true;
      } else {
        print('No se pudieron traer datos ${widget.status}');
        Fluttertoast.showToast(
          msg: "Usuario y/o contraseña incorrectos",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
        );
        return false;
      }
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos');
    }
  }

  void updateSearch(String search) {
    setState(() {
      this.search = search;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    int paginated = 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 132),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'PlaceHolder',
            ),
            onChanged: updateSearch,
            controller: _searchController,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskListItem(task: task);
              },
            ),
          ),
        ],
      ),
    );
  }
}
