import 'package:flutter/material.dart';
import 'package:gtau_app_front/models/task.dart';

class TaskListItem extends StatelessWidget {
  final Task task;

  const TaskListItem(
      {super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      tileColor: Colors.white,
      subtitle: Text('${task.inspectionType}'),
      title: Text('${task.getWorkNumber}'),
      leading: const Icon(Icons.check),
    );
  }
}
