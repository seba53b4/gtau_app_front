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

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: 600,
      child: Center(
        widthFactor: 0.5,
        child: Consumer<TaskListViewModel>(
          builder: (context, taskListViewModel, child) {
            final tasks = taskListViewModel.tasks[widget.status];

            return (tasks!.isEmpty)
                ? const Text("No se encontraron inspecciones.")
                : CustomScrollView(
                    scrollDirection: Axis.vertical,
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            final task = tasks[index];
                            return TaskListItem(
                                task: task, scaffoldKey: widget.scaffoldKey);
                          },
                          childCount: tasks.length ?? 0,
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }
}
