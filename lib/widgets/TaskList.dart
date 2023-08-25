import 'package:flutter/material.dart';
import 'package:gtau_app_front/widgets/task_list_item.dart';
import 'package:provider/provider.dart';
import '../viewmodels/task_list_viewmodel.dart';

class TaskList extends StatefulWidget {
  final String status;
  final String? userName;
  const TaskList({Key? key, required this.status, this.userName}) : super(key: key);

  @override
  _TaskListComponentState createState() => _TaskListComponentState();
}

class _TaskListComponentState extends State<TaskList> {

  @override
  void initState() {
    super.initState();
    clearLists(); // Limpia las listas antes de cargar los datos
    final taskListViewModel = Provider.of<TaskListViewModel>(context, listen: false);
    taskListViewModel.initializeTasks(context, widget.status, widget.userName);
  }

  void clearLists() {
    final taskListViewModel = Provider.of<TaskListViewModel>(context, listen: false);
    taskListViewModel.clearLists();
  }


  @override
  Widget build(BuildContext context) {
    final taskListViewModel = Provider.of<TaskListViewModel>(context);
    final tasks = taskListViewModel.tasks[widget.status];

    return Container(
      margin: const EdgeInsets.only(bottom: 132),
      child: Column(

        children: [
          // Sin campo de búsqueda
          Expanded(
            child: ListView.builder(
              itemCount: tasks?.length,
              itemBuilder: (context, index) {
                final task = tasks?[index];
                return TaskListItem(task: task);
              },
            ),
          ),
        ],
      ),
    );
  }
}
