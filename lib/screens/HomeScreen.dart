import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/widgets/task_status_dashboard.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../widgets/filter_tasks.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _enteredUsername = '';
  Timer? _debounce;

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

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.read<UserProvider>().isAdmin;

    return Scaffold(
      body: isAdmin!
          ? Container(
              color: lightBackground,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _searchController,
                      onChanged: _updateSearch,
                      onFieldSubmitted: _updateSearchByEnter,
                      decoration: const InputDecoration(
                        labelText: 'Ingrese un nombre de usuario',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  _constraintBoxTaskDashboard(context, _enteredUsername),
                ],
              ),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              height: kIsWeb
                  ? MediaQuery.of(context).size.height * 0.78
                  : MediaQuery.of(context).size.height - 72,
              color: lightBackground,
              child: _constraintBoxTaskDashboard(context, _enteredUsername)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (kIsWeb) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => FilterTasks()));
          } else {
            showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) => FilterTasks(),
            );
          }
        },
        foregroundColor: null,
        backgroundColor: null,
        shape: null,
        child: const Icon(Icons.filter_alt_rounded),
      ),
    );
  }
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
