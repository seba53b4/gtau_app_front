import 'package:flutter/material.dart';
import 'package:gtau_app_front/widgets/task_list_item.dart';
import 'package:provider/provider.dart';

import '../providers/task_filters_provider.dart';
import '../viewmodels/task_list_viewmodel.dart';

class TaskList extends StatefulWidget {
  final String status;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const TaskList({Key? key, required this.status, required this.scaffoldKey})
      : super(key: key);

  @override
  _TaskListComponentState createState() => _TaskListComponentState();
}

class _TaskListComponentState extends State<TaskList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final taskFilterProvider =
        Provider.of<TaskFilterProvider>(context, listen: false);
    taskFilterProvider.setLastStatus(widget.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 132),
      child: Consumer<TaskListViewModel>(
        builder: (context, taskListViewModel, child) {
          final tasks = taskListViewModel.tasks[widget.status];

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: tasks?.length ?? 0,
                  itemBuilder: (context, index) {
                    final task = tasks?[index];
                    return TaskListItem(
                        task: task!, scaffoldKey: widget.scaffoldKey);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
