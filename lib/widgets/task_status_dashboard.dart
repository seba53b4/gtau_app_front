import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/models/task_status.dart';
import 'package:gtau_app_front/widgets/TaskList.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/task_filters_provider.dart';
import '../viewmodels/task_list_viewmodel.dart';

class TaskStatusDashboard extends StatefulWidget {
  final String? userName;

  const TaskStatusDashboard({Key? key, this.userName});

  @override
  _TaskStatusDashboard createState() => _TaskStatusDashboard();
}

class _TaskStatusDashboard extends State<TaskStatusDashboard> {
  int _currentIndex = 0;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateTaskListState(TaskStatus.Pending.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskFilterProvider =
        Provider.of<TaskFilterProvider>(context, listen: false);
    taskFilterProvider.setUserNameFilter(widget.userName);
    //taskFilterProvider.setLastStatus(TaskStatus.Pending.value);
    final GlobalKey<ScaffoldState> _scaffoldKeyDashboard =
        GlobalKey<ScaffoldState>();

    return DefaultTabController(
      length: 4,
      initialIndex: 0,
      child: Scaffold(
        key: _scaffoldKeyDashboard,
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: TabBar(
            labelColor: Colors.white,
            labelStyle: const TextStyle(fontSize: kIsWeb ? 20 : 14),
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.task_status_pendingTitle),
              Tab(text: AppLocalizations.of(context)!.task_status_doingTitle),
              Tab(text: AppLocalizations.of(context)!.task_status_blockedTitle),
              Tab(text: AppLocalizations.of(context)!.task_status_doneTitle),
            ],
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              String status = getTaskStatusSelected();
              
              updateTaskListState(status);
            },
          ),
        ),
        body: Consumer<TaskListViewModel>(
            builder: (context, taskListViewModel, child) {
          return LoadingOverlay(
              isLoading: taskListViewModel.isLoading,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 10),
                child: _buildTabContent(_scaffoldKeyDashboard),
              ));
        }),
      ),
    );
  }
  Future<void> resetScrollPosition() async{
    final SharedPreferences prefs = await _prefs;
    prefs.clear();
  }
  String getTaskStatusSelected() {
    switch (_currentIndex) {
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

  Widget _buildTabContent(GlobalKey<ScaffoldState> _scaffoldKeyDashboard) {
    /*resetScrollPosition();*/
    switch (_currentIndex) {
      case 0:
        return _buildTaskList(TaskStatus.Pending.value, _scaffoldKeyDashboard);
      case 1:
        return _buildTaskList(TaskStatus.Doing.value, _scaffoldKeyDashboard);
      case 2:
        return _buildTaskList(TaskStatus.Blocked.value, _scaffoldKeyDashboard);
      case 3:
        return _buildTaskList(TaskStatus.Done.value, _scaffoldKeyDashboard);
      default:
        return Container();
    }
  }

  void updateTaskListState(status) async {
    final userName =
        Provider.of<TaskFilterProvider>(context, listen: false).userNameFilter;
    final taskListViewModel =
        Provider.of<TaskListViewModel>(context, listen: false);
    taskListViewModel.clearListByStatus(status);
    await taskListViewModel.initializeTasks(context, status, userName);
  }

  Widget _buildTaskList(
      String status, GlobalKey<ScaffoldState> _scaffoldKeyDashboard) {
    return FadeTransition(
      key: ValueKey<int>(_currentIndex),
      opacity: const AlwaysStoppedAnimation(1.0),
      child: SafeArea(
          child: TaskList(
        status: status,
        scaffoldKey: _scaffoldKeyDashboard,
      )),
    );
  }
}
