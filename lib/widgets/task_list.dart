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
  TaskFilterProvider? taskFilterProvider;
  TaskListViewModel? taskListViewModel;

  _ScrollPosition() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble("position", controller.position.pixels);
  }

  void _SetBodyPrefValue(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("bodyFiltered", value);
  }

  Future<String> _GetBodyPrefValue() async {
    final SharedPreferences prefs = await _prefs;
    return (prefs.getString("bodyFiltered") ?? "");
  }

  _SetActualTasksLength(int length) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("tasks_length", length);
  }

  void _checkNextPage(int newTasksLength) async {
    final SharedPreferences prefs = await _prefs;
    int value = prefs.getInt("tasks_length") ?? 0;
    int actualPage = prefs.getInt("actual_page") ?? 0;
    if (newTasksLength == (value * actualPage) - 1) {
      nextPage = false;
    }
  }

  Future<bool> _checkExistNextPage(int newTasksLength) async {
    final SharedPreferences prefs = await _prefs;
    int value = prefs.getInt("tasks_length") ?? 0;
    if (newTasksLength == value - 1) {
      return false;
    }
    return true;
  }

  void _SetFilteredValue(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isFiltered", value);
  }

  Future<bool> _GetFilteredValue() async {
    final SharedPreferences prefs = await _prefs;
    return (prefs.getBool("isFiltered") ?? false);
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
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    taskFilterProvider =
        Provider.of<TaskFilterProvider>(context, listen: false);
    taskListViewModel = Provider.of<TaskListViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool nextPage = true;

  Future updateTaskListState(BuildContext context) async {
    final userName = taskFilterProvider?.userNameFilter;
    final status = taskFilterProvider?.lastStatus;
    await taskListViewModel?.nextPageListByStatus(context, status!, userName);
  }

  Future updateTaskListFilteredState(
      BuildContext context, String encodedBody) async {
    final userName = taskFilterProvider?.userNameFilter;
    final status = taskFilterProvider?.lastStatus;
    await taskListViewModel?.nextPageFilteredListByStatus(
        context, status!, userName, encodedBody);
  }

  @override
  Widget build(BuildContext context) {
    taskFilterProvider?.setLastStatus(widget.status);
    final taskListSize = taskListViewModel?.size;
    return SizedBox(
        width: 600,
        child: Center(
            widthFactor: 0.5,
            child: FutureBuilder(
              future: Future.wait(
                  [initScroll(), _GetFilteredValue(), _GetBodyPrefValue()]),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var position = snapshot.data?[0] as double;
                  var isFiltered = snapshot.data?[1] ?? false;
                  return Consumer<TaskListViewModel>(
                    builder: (context, taskListViewModel, child) {
                      var tasks = taskListViewModel.tasks[widget.status];
                      var tasksLength = tasks?.length ?? 0;
                      _checkNextPage(tasksLength);

                      tasksLength = tasksLength + 1;
                      controller =
                          ScrollController(initialScrollOffset: position);
                      controller.addListener(_ScrollPosition);
                      controller.addListener(() {
                        if ((controller.position.maxScrollExtent ==
                                controller.offset) &&
                            tasks!.length % taskListSize! == 0 &&
                            nextPage) {
                          if (isFiltered == true) {
                            setState(() {
                              final encodedBodyFiltered =
                                  snapshot.data?[2] as String;
                              updateTaskListFilteredState(
                                  context, encodedBodyFiltered);
                            });
                          } else {
                            setState(() {
                              updateTaskListState(context);
                            });
                          }

                          _SetActualTasksLength(tasksLength);
                        }
                      });

                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              controller: controller,
                              padding: const EdgeInsets.all(8),
                              itemCount: tasksLength,
                              itemBuilder: (context, index) {
                                if (index < tasks!.length) {
                                  final task = tasks[index];
                                  return TaskListItem(
                                      task: task,
                                      scaffoldKey: widget.scaffoldKey);
                                } else {
                                  if (tasksLength == 1) {
                                    return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 32),
                                        child: Center(
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .emptyTaskList)));
                                  } else {
                                    var comp =
                                        tasks.length % taskListSize! == 0;
                                    if (tasks.length % taskListSize! == 0 &&
                                        nextPage) {
                                      return FutureBuilder(
                                          future: Future.wait([
                                            _checkExistNextPage(tasks.length),
                                            _GetFilteredValue()
                                          ]),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              var existNextPage =
                                                  snapshot.data?[0] ?? true;
                                              var isFiltered =
                                                  snapshot.data?[1] ?? false;
                                              if (existNextPage == true) {
                                                return const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 32),
                                                    child: Center(
                                                        child:
                                                            CircularProgressIndicator()));
                                              } else {
                                                _SetFilteredValue(false);
                                                return const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 0));
                                              }
                                            } else {
                                              return const LoadingWidget();
                                            }
                                          });
                                    }
                                  }
                                }
                                return null;
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
            )));
  }
}
