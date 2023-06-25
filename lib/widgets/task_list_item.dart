import 'package:flutter/material.dart';
import 'package:gtau_app_front/models/task.dart';
import 'package:gtau_app_front/screens/TaskCreationScreen.dart';

class TaskListItem extends StatelessWidget {
  final Task task;

  const TaskListItem({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      tileColor: Colors.white,
      subtitle: Text('${task.inspectionType}'),
      title: Text('${task.getWorkNumber}'),
      leading: const Icon(Icons.check),
      trailing: ElevatedButton(
        onPressed: () {
          // Navegar a TaskCreationScreen a través del Navigator
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskCreationScreen(detail: true, idTask: task!.getId, type: 'inspection',)),
          );
        },
        child: const Text('Editar'),
      ),
    );
  }
}
