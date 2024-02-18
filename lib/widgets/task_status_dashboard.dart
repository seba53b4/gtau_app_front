import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/models/task_status.dart';
import 'package:gtau_app_front/viewmodels/task_list_scheduled_viewmodel.dart';
import 'package:gtau_app_front/widgets/common/background_gradient.dart';
import 'package:gtau_app_front/widgets/common/box_container_white.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:gtau_app_front/widgets/task_list.dart';
import 'package:gtau_app_front/widgets/task_list_scheduled.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/task_filters_provider.dart';
import '../providers/user_provider.dart';
import '../viewmodels/task_list_viewmodel.dart';
import 'common/customMessageDialog.dart';

class TaskStatusDashboard extends StatefulWidget {
  final String? userName;

  const TaskStatusDashboard({super.key, this.userName});

  @override
  _TaskStatusDashboard createState() => _TaskStatusDashboard();
}

class _TaskStatusDashboard extends State<TaskStatusDashboard>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late TabController _tabController;
  late TaskListViewModel taskListViewModel;
  late TaskListScheduledViewModel taskListScheduledViewModel;
  late TaskFilterProvider taskFilterProvider;
  late String token;
  late bool alreadyUpdated;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: 4);
    taskListViewModel = Provider.of<TaskListViewModel>(context, listen: false);
    taskListScheduledViewModel =
        Provider.of<TaskListScheduledViewModel>(context, listen: false);
    taskFilterProvider =
        Provider.of<TaskFilterProvider>(context, listen: false);
    alreadyUpdated = false;
  }

  void _loadFromStorage() {
    if (token.isNotEmpty && !alreadyUpdated) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        updateTaskListState(TaskStatus.Pending.value, false);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _clearPref() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }

  void _SoftClearPref() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("is_loading", false);
    prefs.setInt("actual_page", 1);
  }

  @override
  Widget build(BuildContext context) {
    taskFilterProvider.setUserNameFilter(widget.userName);
    final GlobalKey<ScaffoldState> scaffoldKeyDashboard =
        GlobalKey<ScaffoldState>();
    return Consumer<TaskFilterProvider>(
        builder: (context, taskFilterProvider, child) {
      var newIndex = taskFilterProvider.getCurrentIndex();
      if (_currentIndex != newIndex) {
        _currentIndex = newIndex;
        _tabController.animateTo(_currentIndex);
      }
      bool isScheduled =
          taskFilterProvider.inspectionTypeFilter?.allMatches('SCHEDULED') !=
              null;

      if (kIsWeb) {
        return BoxContainerWhite(
          decoration: kIsWeb
              ? const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                )
              : null,
          child: Padding(
            padding: kIsWeb
                ? const EdgeInsets.only(top: 6.0)
                : const EdgeInsets.only(top: 0.0),
            child: SizedBox(
              width: 120,
              child: Scaffold(
                key: scaffoldKeyDashboard,
                appBar: AppBar(
                  backgroundColor: lightBackground,
                  elevation: kIsWeb ? 0.0 : null,
                  //controla el shadow de los tabs
                  toolbarHeight: 0,
                  bottom: TabBar(
                    controller: _tabController,
                    indicator: ShapeDecoration(
                        shape: const RoundedRectangleBorder(
                            borderRadius: kIsWeb
                                ? BorderRadius.only(
                                    topRight: Radius.circular(20),
                                    topLeft: Radius.circular(20))
                                : BorderRadius.only(
                                    topRight: Radius.circular(0),
                                    topLeft: Radius.circular(0))),
                        color: primarySwatch[600]),
                    labelColor: Colors.white,
                    labelStyle: const TextStyle(fontSize: kIsWeb ? 18 : 14),
                    unselectedLabelColor: Colors.black38,
                    tabs: [
                      _buildCustomTab(
                        text: AppLocalizations.of(context)!
                            .task_status_pendingTitle,
                        isSelected: _currentIndex == 0,
                      ),
                      _buildCustomTab(
                        text: AppLocalizations.of(context)!
                            .task_status_doingTitle,
                        isSelected: _currentIndex == 1,
                      ),
                      _buildCustomTab(
                        text: AppLocalizations.of(context)!
                            .task_status_blockedTitle,
                        isSelected: _currentIndex == 2,
                      ),
                      _buildCustomTab(
                        text:
                            AppLocalizations.of(context)!.task_status_doneTitle,
                        isSelected: _currentIndex == 3,
                      ),
                    ],
                    onTap: (index) {
                      if (_currentIndex != index) {
                        setState(() {
                          _currentIndex = index;
                        });
                        _clearPref();
                        String status = getTaskStatusSelected(index);
                        taskFilterProvider.setLastStatus(status);
                        updateTaskListState(status, isScheduled);
                      }
                    },
                  ),
                ),
                body: BackgroundGradient(
                    decoration: BoxDecoration(
                      borderRadius: kIsWeb
                          ? const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            )
                          : null,
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 2,
                        focalRadius: 2,
                        // begin: Alignment.center,
                        // end: Alignment.centerRight,
                        colors: [
                          dashboardBackground,
                          dashboardBackground
                          //Color.fromRGBO(217, 217, 217, 1)
                        ],
                      ),
                    ),
                    child: Consumer<TaskListViewModel>(
                        builder: (context, taskListViewModel, child) {
                      return LoadingOverlay(
                          isLoading: taskListViewModel.isLoading,
                          child: _buildTabContent(
                              scaffoldKeyDashboard, isScheduled));
                    })),
              ),
            ),
          ),
        );
      } else {
        return SizedBox(
          width: 120,
          child: Scaffold(
            key: scaffoldKeyDashboard,
            appBar: AppBar(
              backgroundColor: lightBackground,
              elevation: kIsWeb ? 0.0 : null,
              //controla el shadow de los tabs
              toolbarHeight: 0,
              bottom: TabBar(
                controller: _tabController,
                indicator: ShapeDecoration(
                    shape: const RoundedRectangleBorder(
                        borderRadius: kIsWeb
                            ? BorderRadius.only(
                                topRight: Radius.circular(20),
                                topLeft: Radius.circular(20))
                            : BorderRadius.only(
                                topRight: Radius.circular(20),
                                topLeft: Radius.circular(20))),
                    color: primarySwatch[600]),
                labelColor: Colors.white,
                labelStyle: const TextStyle(fontSize: kIsWeb ? 18 : 14),
                unselectedLabelColor: Colors.black38,
                tabs: [
                  _buildCustomTab(
                    text:
                        AppLocalizations.of(context)!.task_status_pendingTitle,
                    isSelected: _currentIndex == 0,
                  ),
                  _buildCustomTab(
                    text: AppLocalizations.of(context)!.task_status_doingTitle,
                    isSelected: _currentIndex == 1,
                  ),
                  _buildCustomTab(
                    text:
                        AppLocalizations.of(context)!.task_status_blockedTitle,
                    isSelected: _currentIndex == 2,
                  ),
                  _buildCustomTab(
                    text: AppLocalizations.of(context)!.task_status_doneTitle,
                    isSelected: _currentIndex == 3,
                  ),
                ],
                onTap: (index) {
                  if (_currentIndex != index) {
                    setState(() {
                      _currentIndex = index;
                    });
                    _clearPref();
                    String status = getTaskStatusSelected(index);
                    taskFilterProvider.setLastStatus(status);
                    updateTaskListState(status, isScheduled);
                  }
                },
              ),
            ),
            body: BackgroundGradient(
                decoration: BoxDecoration(
                  borderRadius: kIsWeb
                      ? const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        )
                      : null,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 2,
                    focalRadius: 2,
                    // begin: Alignment.center,
                    // end: Alignment.centerRight,
                    colors: [
                      dashboardBackground,
                      dashboardBackground
                      //Color.fromRGBO(217, 217, 217, 1)
                    ],
                  ),
                ),
                child: Consumer<TaskListViewModel>(
                    builder: (context, taskListViewModel, child) {
                  return LoadingOverlay(
                      isLoading: taskListViewModel.isLoading,
                      child:
                          _buildTabContent(scaffoldKeyDashboard, isScheduled));
                })),
          ),
        );
      }
    });
  }

  Future<void> resetScrollPosition() async {
    final SharedPreferences prefs = await _prefs;
    prefs.clear();
  }

  String getTaskStatusSelected(int index) {
    switch (index) {
      case 0:
        return TaskStatus.Pending.value;
      case 1:
        return TaskStatus.Doing.value;
      case 2:
        return TaskStatus.Blocked.value;
      case 3:
        return TaskStatus.Done.value;
      default:
        return "";
    }
  }

  Widget _buildTabContent(
      GlobalKey<ScaffoldState> _scaffoldKeyDashboard, bool isScheduled) {
    switch (_currentIndex) {
      case 0:
        return _buildTaskList(
            TaskStatus.Pending.value, _scaffoldKeyDashboard, isScheduled);
      case 1:
        return _buildTaskList(
            TaskStatus.Doing.value, _scaffoldKeyDashboard, isScheduled);
      case 2:
        return _buildTaskList(
            TaskStatus.Blocked.value, _scaffoldKeyDashboard, isScheduled);
      case 3:
        return _buildTaskList(
            TaskStatus.Done.value, _scaffoldKeyDashboard, isScheduled);
      default:
        return Text(AppLocalizations.of(context)!.see_more);
    }
  }

  void updateTaskListState(String status, bool isScheduled) async {
    setState(() {
      alreadyUpdated = true;
    });
    if (isScheduled) {
      taskListScheduledViewModel.clearListByStatus(status);
      await taskListScheduledViewModel
          .fetchScheduledTasks(token, status)
          .catchError((error) async {
        // Manejo de error
        await showCustomMessageDialog(
          context: context,
          onAcceptPressed: () {},
          customText: AppLocalizations.of(context)!.error_generic_text,
          messageType: DialogMessageType.error,
        );
        return null;
      });
    } else {
      final userName = Provider.of<TaskFilterProvider>(context, listen: false)
          .userNameFilter;
      final taskListViewModel =
          Provider.of<TaskListViewModel>(context, listen: false);
      taskListViewModel.clearListByStatus(status);
      await taskListViewModel
          .initializeTasks(context, status, userName)
          .catchError((error) async {
        // Manejo de error
        await showCustomMessageDialog(
          context: context,
          onAcceptPressed: () {},
          customText: AppLocalizations.of(context)!.error_generic_text,
          messageType: DialogMessageType.error,
        );
        return null;
      });
    }
  }

  Widget _buildTaskList(String status,
      GlobalKey<ScaffoldState> _scaffoldKeyDashboard, bool isScheduled) {
    return FadeTransition(
        key: ValueKey<int>(_currentIndex),
        opacity: const AlwaysStoppedAnimation(1.0),
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            token = userProvider.getToken ?? '';
            _loadFromStorage();
            return Center(
              child: taskFilterProvider.isScheduled!
                  ? TaskListScheduled(
                      status: status,
                      scaffoldKey: _scaffoldKeyDashboard,
                    )
                  : TaskList(
                      status: status,
                      scaffoldKey: _scaffoldKeyDashboard,
                    ),
            );
          },
        ));
  }

  Widget _buildCustomTab({required String text, required bool isSelected}) {
    return SizedBox(
      height: 44,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: kIsWeb ? 20 : 13,
            color: isSelected ? Colors.white : Colors.black38,
            fontWeight: isSelected
                ? FontWeight.w600
                : (kIsWeb ? FontWeight.w500 : FontWeight.w500),
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
