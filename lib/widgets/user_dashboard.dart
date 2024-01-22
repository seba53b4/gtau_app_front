import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/models/task_status.dart';
import 'package:gtau_app_front/viewmodels/task_list_scheduled_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/user_list_viewmodel.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:gtau_app_front/widgets/task_list.dart';
import 'package:gtau_app_front/widgets/task_list_scheduled.dart';
import 'package:gtau_app_front/widgets/user_list.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/task_filters_provider.dart';
import '../providers/user_provider.dart';
import '../viewmodels/task_list_viewmodel.dart';
import 'common/customMessageDialog.dart';

class UserDashboard extends StatefulWidget {
  final String? userName;

  const UserDashboard({super.key, this.userName});

  @override
  _UserDashboard createState() => _UserDashboard();
}

class _UserDashboard extends State<UserDashboard>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late TabController _tabController;
  late TaskListViewModel taskListViewModel;
  late TaskListScheduledViewModel taskListScheduledViewModel;
  late TaskFilterProvider taskFilterProvider;
  late String token;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateUserListState('ACTIVE');
    });
    _tabController = TabController(vsync: this, length: 4);
    taskListViewModel = Provider.of<TaskListViewModel>(context, listen: false);
    taskListScheduledViewModel =
        Provider.of<TaskListScheduledViewModel>(context, listen: false);
    taskFilterProvider =
        Provider.of<TaskFilterProvider>(context, listen: false);
    token = context.read<UserProvider>().getToken!;
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
    return SizedBox(
        width: 120,
        child: Scaffold(
            key: scaffoldKeyDashboard,
            body: Consumer<TaskListViewModel>(
                builder: (context, taskListViewModel, child) {
              return LoadingOverlay(
                  isLoading: taskListViewModel.isLoading,
                  child: _buildTabContent(scaffoldKeyDashboard));
              // taskFilterProvider.inspectionTypeFilter
              //         ?.allMatches('Programada') !=
              //     null));
            })),
      );
    
  }

  Future<void> resetScrollPosition() async {
    final SharedPreferences prefs = await _prefs;
    prefs.clear();
  }

  String getTaskStatusSelected(int index) {
    switch (index) {
      case 0:
        return 'ACTIVE';
      default:
        return "";
    }
  }

  Widget _buildTabContent(
      GlobalKey<ScaffoldState> _scaffoldKeyDashboard) {
    switch (_currentIndex) {
      case 0:
        return _buildTaskList(
            'ACTIVE', _scaffoldKeyDashboard);
      default:
        return Text(AppLocalizations.of(context)!.see_more);
    }
  }

  void updateUserListState(String status) async {
      final userName = Provider.of<TaskFilterProvider>(context, listen: false)
          .userNameFilter;
      final userListViewModel =
          Provider.of<UserListViewModel>(context, listen: false);
      userListViewModel.clearListByStatus(status);
      await userListViewModel
          .initializeUsers(context, status, userName)
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

  Widget _buildTaskList(String status,
      GlobalKey<ScaffoldState> _scaffoldKeyDashboard) {
    return FadeTransition(
      key: ValueKey<int>(_currentIndex),
      opacity: const AlwaysStoppedAnimation(1.0),
      child: Center(
        child: UserList(
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
