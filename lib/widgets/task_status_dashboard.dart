import 'package:flutter/material.dart';
import 'package:gtau_app_front/models/task_status.dart';
import 'package:gtau_app_front/widgets/TaskList.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskStatusDashboard extends StatefulWidget {
  const TaskStatusDashboard({Key? key});

  @override
  _TaskStatusDashboard createState() => _TaskStatusDashboard();
}

class _TaskStatusDashboard extends State<TaskStatusDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
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
          duration: const Duration(milliseconds: 250),
          child: _buildTabContent(),
        ),
      ),);

  }

  Widget _buildTabContent() {
    switch (_currentIndex) {
      case 0:
        return FadeTransition(
          key: const ValueKey<int>(0),
          opacity: const AlwaysStoppedAnimation(1.0),
          child: SafeArea(child: TaskList(status: TaskStatus.Pending.value)),
        );
      case 1:
        return FadeTransition(
          key: const ValueKey<int>(1),
          opacity: const AlwaysStoppedAnimation(1.0),
          child: SafeArea(child: TaskList(status: TaskStatus.Doing.value)),
        );
      case 2:
        return FadeTransition(
          key: const ValueKey<int>(2),
          opacity: const AlwaysStoppedAnimation(1.0),
          child: SafeArea(child: TaskList(status: TaskStatus.Blocked.value)),
        );
      case 3:
        return FadeTransition(
          key: const ValueKey<int>(3),
          opacity: const AlwaysStoppedAnimation(1.0),
          child: SafeArea(child: TaskList(status: TaskStatus.Done.value)),
        );
      default:
        return Container();
    }
  }
}

