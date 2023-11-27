import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/widgets/task_list_item.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/task_filters_provider.dart';
import '../viewmodels/task_list_viewmodel.dart';
import 'loading_component.dart';

class TaskList extends StatefulWidget {
  final String status;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const TaskList({Key? key, required this.status, required this.scaffoldKey})
      : super(key: key);

  @override
  _TaskListComponentState createState() => _TaskListComponentState();
}

class _TaskListComponentState extends State<TaskList> {
  ScrollController controller = ScrollController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  _ScrollPosition() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble("position", controller.position.pixels);
  }

  _SetActualTasksLength(int length) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("tasks_length", length);
  }

  void _checkNextPage(int newTasksLength) async {
    final SharedPreferences prefs = await _prefs;
    int value = prefs.getInt("tasks_length") ?? 0;
    if(newTasksLength == value-1){
      nextPage=false;
    }
  }

  Future<bool> _checkExistNextPage(int newTasksLength) async {
    final SharedPreferences prefs = await _prefs;
    int value = prefs.getInt("tasks_length") ?? 0;
    if(newTasksLength == value-1){
      return false;
    }
    return true;
  }

  Future<double> initScroll() async {
    final SharedPreferences prefs = await _prefs;
    return (prefs.getDouble("position") ?? 0.0);
  }

  @override
  initState() {
    /*initScroll();*/
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool nextPage = true;

  Future updateTaskListState(BuildContext context) async {
    final userName =
        Provider.of<TaskFilterProvider>(context, listen: false).userNameFilter;
    final status =
        Provider.of<TaskFilterProvider>(context, listen: false).lastStatus;
    final taskListViewModel =
        Provider.of<TaskListViewModel>(context, listen: false);
    await taskListViewModel.nextPageListByStatus(context, status!, userName);
  }

  @override
  Widget build(BuildContext context) {
    final taskFilterProvider =
        Provider.of<TaskFilterProvider>(context, listen: false);
    taskFilterProvider.setLastStatus(widget.status);
    return Container(
        margin: const EdgeInsets.only(bottom: 0),
        child: FutureBuilder(
          future: initScroll(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var position = snapshot.data as double;
              return Consumer<TaskListViewModel>(
                builder: (context, taskListViewModel, child) {
                  var tasks = taskListViewModel.tasks[widget.status];
                  var tasks_length = tasks?.length ?? 0;
                  _checkNextPage(tasks_length);
              
                  tasks_length = tasks_length + 1;
                  controller = ScrollController(initialScrollOffset: position);
                  controller.addListener(_ScrollPosition);
                  controller.addListener(() {
                    if ((controller.position.maxScrollExtent ==
                            controller.offset) &&
                        tasks!.length % 10 == 0 && nextPage) {
                      setState(() {
                        updateTaskListState(context);
                      });
                      _SetActualTasksLength(tasks_length);
                    }
                  });
                  
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: controller,
                          padding: const EdgeInsets.all(8),
                          itemCount: tasks_length,
                          itemBuilder: (context, index) {
                            if (index < tasks!.length) {
                              final task = tasks[index];
                              return TaskListItem(
                                  task: task, scaffoldKey: widget.scaffoldKey);
                            } else {
                              if (tasks_length == 1) {
                                return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 32),
                                    child: Center(
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .emptyTaskList)));
                              } else {
                                if (tasks.length % 10 == 0 && nextPage) {
                                  return FutureBuilder(
                                    future: _checkExistNextPage(tasks.length),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        var existNextPage = snapshot.data as bool;
                                        if(existNextPage == true){
                                          return const Padding(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 32),
                                          child: Center(
                                              child: CircularProgressIndicator()));
                                        }else{
                                          return const Padding(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 0));
                                        }
                                      }else{
                                        return const LoadingWidget();
                                      }
                                    }
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            }
            return const LoadingWidget();
          },
        ));
  }
}
