import 'package:flutter/material.dart';
import 'package:gtau_app_front/widgets/task_list_item.dart';
import 'package:provider/provider.dart';
import '../viewmodels/task_list_viewmodel.dart';

class TaskList extends StatefulWidget {
  final String status;
  const TaskList({Key? key, required this.status}) : super(key: key);

  @override
  _TaskListComponentState createState() => _TaskListComponentState();
}

class _TaskListComponentState extends State<TaskList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final taskListViewModel = Provider.of<TaskListViewModel>(context, listen: false);
    taskListViewModel.initializeTasks(context, widget.status);
  }

  void updateSearch(String search) {
    // Lógica de filtrado según la búsqueda
  }

  @override
  Widget build(BuildContext context) {
    final taskListViewModel = Provider.of<TaskListViewModel>(context);
    final tasks = taskListViewModel.tasks;

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
