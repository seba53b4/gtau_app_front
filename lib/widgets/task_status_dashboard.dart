import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/models/task_status.dart';
import 'package:gtau_app_front/viewmodels/task_list_scheduled_viewmodel.dart';
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
    // context.read<UserProvider>().addListener(_onUserProviderChange);
  }

  void _onUserProviderChange() {
    final newToken = context.read<UserProvider>().getToken;

    if (newToken != null) {
      setState(() {
        token = newToken;
      });

      _loadFromStorage();
      //   context.read<UserProvider>().removeListener(_onUserProviderChange);
    }
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
    context.read<UserProvider>().addListener(_onUserProviderChange);
    _onUserProviderChange();
  }

  @override
  void dispose() {
    context.read<UserProvider>().removeListener(_onUserProviderChange);
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

      return SizedBox(
        width: 120,
        child: Scaffold(
            key: scaffoldKeyDashboard,
            appBar: AppBar(
              backgroundColor: primarySwatch[200],
              toolbarHeight: 0,
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: lightBackground,
                labelColor: Colors.white,
                labelStyle: const TextStyle(fontSize: kIsWeb ? 18 : 14),
                unselectedLabelColor: Colors.white60,
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
            body: Consumer<TaskListViewModel>(
                builder: (context, taskListViewModel, child) {
              return LoadingOverlay(
                  isLoading: taskListViewModel.isLoading,
                  child: _buildTabContent(scaffoldKeyDashboard, isScheduled));
              // taskFilterProvider.inspectionTypeFilter
              //         ?.allMatches('Programada') !=
              //     null));
            })),
      );
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
              child: isScheduled
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
            color: isSelected ? Colors.white : Colors.white60,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
