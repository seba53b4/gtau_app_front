import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/widgets/task_list_item.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  Future<String> _GetBodyPrefValue() async {
    final SharedPreferences prefs = await _prefs;
    return (prefs.getString("bodyFiltered") ?? "");
  }

  void _SetIsLoadingPrefValue(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("is_loading", value);
  }

  Future<int> _GetActualPage() async {
    final SharedPreferences prefs = await _prefs;
    return (prefs.getInt("actual_page") ?? 1);
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

  Future<bool> _GetIsLoadingValue() async {
    final SharedPreferences prefs = await _prefs;
    return (prefs.getBool("is_loading") ?? false);
  }


  Future<double> initScroll() async {
    final SharedPreferences prefs = await _prefs;
    return (prefs.getDouble("position") ?? 0.0);
  }

  @override
  initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
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
  bool isLoadingNow = false;

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
                  [initScroll(), _GetFilteredValue(), _GetBodyPrefValue(), _GetActualPage(), _GetIsLoadingValue()]),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var position = snapshot.data?[0] as double;
                  var isFiltered = snapshot.data?[1] ?? false;
                  var actualPage = snapshot.data?[3] as int;
                  var isLoading= snapshot.data?[4] as bool; 
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
                                    return Visibility(
                                      visible: !isLoading,
                                      child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            vertical: 5, horizontal:15),
                                                    child: Center(
                                                        child:Column(
                                                            children: <Widget>[
                                                              Padding(
                                                                padding:EdgeInsets.symmetric(vertical: 10, horizontal:15),
                                                                child: SvgPicture.asset('lib/assets/taskslists_notfound_small.svg', width: 50, height: 50),
                                                              ),
                                                              isFiltered==true ? Text(AppLocalizations.of(context)!
                                                              .no_tasks_found_filter, textAlign: TextAlign.center,
                                                          style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 15)) : 
                                                          Text(AppLocalizations.of(context)!
                                                              .emptyTaskList,
                                                          style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 15))
                                                          ,
                                                        ]
                                                        )
                                                      )
                                                    ),
                                    );
                                    
                                    ;
                                  } else {
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
                                              if (existNextPage == true) {
                                                return Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            vertical: 5),
                                                    child: Center(
                                                        child:
                                                            Lottie.asset('lib/assets/three_dots_loading_fast.json',
                                                            width: 64,
                                                            height: 64,)));
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
                                    }else{
                                      if(actualPage > 1){
                                        return Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            vertical: 5),
                                                    child: Center(
                                                        child:Column(
                                                            children: <Widget>[
                                                              Padding(
                                                                padding:EdgeInsets.symmetric(vertical: 10),
                                                                child: SvgPicture.asset('lib/assets/taskslist_empty.svg', width: 50, height: 50),
                                                              ),
                                                              Text(AppLocalizations.of(context)!
                                                              .no_more_tasks_found,
                                                          style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 15)),
                                                        ]
                                                        )
                                                      )
                                                    );
                                      }else{
                                        return const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 0),);
                                      }
                                                      
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
