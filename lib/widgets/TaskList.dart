import 'package:flutter/material.dart';
import 'package:gtau_app_front/widgets/tas_list_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class TaskList extends StatefulWidget {
  @override
  _TaskListComponentState createState() => _TaskListComponentState();
}

class _TaskListComponentState extends State<TaskList> {
  List<Map<String, String>> tasks = [];
  TextEditingController _searchController = TextEditingController();
 

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  String search = '';
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/tasks'));
      final data = json.decode(response.body);
      setState(() {
        tasks = List<Map<String, String>>.from(data);
      });
    } catch (error) {
      // Handle error
      setState(() {
        tasks = [
          {
            'taskID': '1',
            'type': 'Programada',
            'title': 'Programada Zona 1',
          },
          {
            'taskID': '2',
            'type': 'Programada',
            'title': 'Programada Zona 2',
          },
          {
            'taskID': '3',
            'type': 'Puntual',
            'title': 'Puntual Padron 2312',
          },
          // Add more sample tasks as needed
        ];
      });
    }
  }

  void updateSearch(String search) {
    setState(() {
      this.search = search;
    });
  }

  @override
  Widget build(BuildContext context) {


    return Container(
      margin: EdgeInsets.only(bottom: 132),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
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
                return TaskListItem(
                  id: task['taskID']!,
                  type: task['type']!,
                  title: task['title']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
