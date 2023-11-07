import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/models/task_status.dart';
import 'package:gtau_app_front/widgets/TaskList.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../providers/task_filters_provider.dart';
import '../viewmodels/task_list_viewmodel.dart';

class TaskStatusDashboard extends StatefulWidget {
  final String? userName;

  const TaskStatusDashboard({super.key, this.userName});

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
    final GlobalKey<ScaffoldState> scaffoldKeyDashboard =
        GlobalKey<ScaffoldState>();

    return SizedBox(
      width: 120,
      child: DefaultTabController(
        length: 4,
        initialIndex: 0,
        child: Scaffold(
          key: scaffoldKeyDashboard,
          appBar: AppBar(
            backgroundColor: primarySwatch[200],
            toolbarHeight: 0,
            bottom: TabBar(
              indicatorColor: lightBackground,
              labelColor: Colors.white,
              labelStyle: const TextStyle(fontSize: kIsWeb ? 18 : 14),
              unselectedLabelColor: Colors.white60,
              tabs: [
                _buildCustomTab(
                  text: AppLocalizations.of(context)!.task_status_pendingTitle,
                  isSelected: _currentIndex == 0,
                ),
                _buildCustomTab(
                  text: AppLocalizations.of(context)!.task_status_doingTitle,
                  isSelected: _currentIndex == 1,
                ),
                _buildCustomTab(
                  text: AppLocalizations.of(context)!.task_status_blockedTitle,
                  isSelected: _currentIndex == 2,
                ),
                _buildCustomTab(
                  text: AppLocalizations.of(context)!.task_status_doneTitle,
                  isSelected: _currentIndex == 3,
                ),
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
              child: _buildTabContent(scaffoldKeyDashboard),
            );
          }),
        ),
      ),
    );
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
        return Text(AppLocalizations.of(context)!.see_more);
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
      child: Center(
        child: TaskList(
          status: status,
          scaffoldKey: _scaffoldKeyDashboard,
        ),
      ),
    );
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
