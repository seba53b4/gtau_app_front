import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/providers/task_filters_provider.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:gtau_app_front/viewmodels/task_list_scheduled_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/task_list_viewmodel.dart';
import 'package:gtau_app_front/widgets/task_status_dashboard.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/filter_tasks.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _enteredUsername = '';
  Timer? _debounce;
  bool isSwitched = false;
  late TaskListViewModel taskListViewModel;
  late TaskListScheduledViewModel taskListScheduledViewModel;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _updateSearch(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      setState(() {
        _enteredUsername = value;
      });
    });
  }

  void _updateSearchByEnter(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    setState(() {
      _enteredUsername = value;
    });
  }

  Future<bool> _clearPref() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
  

  @override
  Widget build(BuildContext context) {
    _clearPref();
    
    
    return Scaffold(
      body: Container(
        color: lightBackground,
        child: Center(
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: kIsWeb
                  ? MediaQuery.of(context).size.height * 0.78
                  : MediaQuery.of(context).size.height - 72,
              color: lightBackground,
              child: _constraintBoxTaskDashboard(context, _enteredUsername)
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFilterModal(context);
        },
        foregroundColor: null,
        backgroundColor: null,
        shape: null,
        child: const Icon(Icons.filter_alt_rounded),
      ),
    );
  }
}

void _showFilterModal(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(50.0))),
        child: SizedBox(
          width: kIsWeb ? 640 : MediaQuery.of(context).size.width,
          child: const FilterTasks(),
        ),
      );
    },
  );
}

Widget _constraintBoxTaskDashboard(BuildContext context, String userName) {
  double widthDashboard = 980;
  double paddingDashboard =
      (MediaQuery.of(context).size.width - widthDashboard) > 0 && kIsWeb
          ? (MediaQuery.of(context).size.width - widthDashboard) / 2
          : 0;
  return Container(
    margin: kIsWeb
        ? EdgeInsets.symmetric(horizontal: paddingDashboard)
        : const EdgeInsets.symmetric(horizontal: 0),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: kIsWeb
            ? MediaQuery.of(context).size.height * 0.78
            : MediaQuery.of(context).size.height - 164,
      ),
      child: TaskStatusDashboard(userName: userName),
    ),
  );
}
