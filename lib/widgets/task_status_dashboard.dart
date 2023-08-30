import 'package:flutter/material.dart';
import 'package:gtau_app_front/models/task_status.dart';
import 'package:gtau_app_front/widgets/TaskList.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  Widget build(BuildContext context) {

    final taskFilterProvider = Provider.of<TaskFilterProvider>(context, listen: false);
    taskFilterProvider.setUserNameFilter(widget.userName);

    return DefaultTabController(
      length: 4,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: TabBar(
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
            },
          ),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 10),
          child: _buildTabContent(),
        ),
      ),);

  }

  Widget _buildTabContent() {
    switch (_currentIndex) {
      case 0:
        return _buildTaskList(TaskStatus.Pending.value);
      case 1:
        return _buildTaskList(TaskStatus.Doing.value);
      case 2:
        return _buildTaskList(TaskStatus.Blocked.value);
      case 3:
        return _buildTaskList(TaskStatus.Done.value);
      default:
        return Container();
    }
  }

  void updateTaskListState(status) async {
    final userName = Provider.of<TaskFilterProvider>(context, listen: false).userNameFilter;
    final taskListViewModel = Provider.of<TaskListViewModel>(context, listen: false);
    await taskListViewModel.initializeTasks(context, status, userName);
  }

  Widget _buildTaskList(String status) {
    updateTaskListState(status);

    return FadeTransition(
      key: ValueKey<int>(_currentIndex),
      opacity: const AlwaysStoppedAnimation(1.0),
      child: SafeArea(child: TaskList(status: status)),
    );
  }
}

