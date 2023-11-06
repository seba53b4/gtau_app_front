import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/models/task_status.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:gtau_app_front/widgets/task_list.dart';
import 'package:provider/provider.dart';

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

  String getTaskStatusSelected() {
    return switch (_currentIndex) {
      0 => TaskStatus.Pending.value,
      1 => TaskStatus.Doing.value,
      2 => TaskStatus.Blocked.value,
      3 => TaskStatus.Done.value,
      _ => ""
    };
  }

  Widget _buildTabContent(GlobalKey<ScaffoldState> _scaffoldKeyDashboard) {
    return switch (_currentIndex) {
      0 => _buildTaskList(TaskStatus.Pending.value, _scaffoldKeyDashboard),
      1 => _buildTaskList(TaskStatus.Doing.value, _scaffoldKeyDashboard),
      2 => _buildTaskList(TaskStatus.Blocked.value, _scaffoldKeyDashboard),
      3 => _buildTaskList(TaskStatus.Done.value, _scaffoldKeyDashboard),
      _ => Container()
    };
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
