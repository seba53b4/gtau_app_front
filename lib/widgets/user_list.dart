import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:gtau_app_front/viewmodels/user_list_viewmodel.dart';
import 'package:gtau_app_front/widgets/task_list_item.dart';
import 'package:gtau_app_front/widgets/user_list_item.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/task_filters_provider.dart';
import '../viewmodels/task_list_viewmodel.dart';
import 'loading_component.dart';

class UserList extends StatefulWidget {
  final String status;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const UserList({Key? key, required this.status, required this.scaffoldKey})
      : super(key: key);

  @override
  _UserListComponentState createState() => _UserListComponentState();
}

class _UserListComponentState extends State<UserList> {
  ScrollController controller = ScrollController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  UserProvider? userFilterProvider;
  UserListViewModel? userListViewModel;

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

  /* checks if there's a next page based on the current page size. If its below the maximum size, change the nextPage flag to false. */
  void _checkNextPage(int newTasksLength) async {
    final SharedPreferences prefs = await _prefs;
    int value = prefs.getInt("tasks_length") ?? 0;
    int actualPage = prefs.getInt("actual_page") ?? 0;
    if (newTasksLength == (value * actualPage) - 1) {
      nextPage = false;
    }
  }

  /* checks if there's a next page based on the current page size. If its below the maximum size, returns false. Otherwise, it returns true. */
  Future<bool> _checkExistNextPage(int newTasksLength) async {
    final SharedPreferences prefs = await _prefs;
    int value = prefs.getInt("tasks_length") ?? 0;
    int actualPage = prefs.getInt("actual_page") ?? 0;
    
    if (newTasksLength == (value * actualPage) - actualPage) {
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
    userFilterProvider =
        Provider.of<UserProvider>(context, listen: false);
    userListViewModel = Provider.of<UserListViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool nextPage = true;
  bool isLoadingNow = false;

  Future updateUserListState(BuildContext context) async {
    /*final userName = userFilterProvider?.userNameFilter;
    final status = userFilterProvider?.lastStatus;*/
    await userListViewModel?.initializeUsers(context, 'ACTIVE', '');
  }

  /*Future updateTaskListFilteredState(BuildContext context,
      String encodedBody) async {
    final userName = userFilterProvider?.userNameFilter;
    final status = userFilterProvider?.lastStatus;
    await userListViewModel?.nextPageFilteredListByStatus(
        context, status!, userName, encodedBody);
  }*/

  @override
  Widget build(BuildContext context) {
    final userListSize = userListViewModel?.size;
    return SizedBox(
        width: 600,
        child: Center(
            widthFactor: 0.5,
            child: FutureBuilder(
              future: Future.wait(
                  [
                    initScroll(),
                    _GetFilteredValue(),
                    _GetBodyPrefValue(),
                    _GetActualPage(),
                    _GetIsLoadingValue()
                  ]),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var position = snapshot.data?[0] as double;
                  var isFiltered = snapshot.data?[1] ?? false;
                  var actualPage = snapshot.data?[3] as int;
                  var isLoading = snapshot.data?[4] as bool;
                  return Consumer<UserListViewModel>(
                    builder: (context, userListViewModel, child) {
                      var users = userListViewModel.users['ACTIVE'];
                      var usersLength = users?.length ?? 0;

                      //usersLength = usersLength + 1;
                      controller =
                          ScrollController(initialScrollOffset: position);
                      controller.addListener(_ScrollPosition);
                      controller.addListener(() {
                        
                      });

                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              controller: controller,
                              padding: const EdgeInsets.all(8),
                              itemCount: usersLength,
                              itemBuilder: (context, index) {
                                if (index < users!.length) {
                                  final user = users[index];
                                  return UserListItem(
                                      user: user,
                                      scaffoldKey: widget.scaffoldKey);
                                } else {
                                  
                                }
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
