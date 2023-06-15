import 'package:flutter/material.dart';

class TaskListItem extends StatelessWidget {
  final String id;
  final String type;
  final String title;

  const TaskListItem(
      {super.key, required this.id, required this.type, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      tileColor: Colors.white,
      subtitle: Text('$title Example'),
      title: Text(title),
      leading: const Icon(Icons.check),
    );
  }
}
