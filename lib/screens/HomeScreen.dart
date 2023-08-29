import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gtau_app_front/widgets/task_status_dashboard.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';


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

    return isAdmin!
        ? Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _searchController,
              onChanged: _updateSearch,
              onFieldSubmitted: _updateSearchByEnter,
              decoration: InputDecoration(
                labelText: 'Ingrese un nombre de usuario',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: Future.delayed(const Duration(microseconds: 2)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 6,
                      ),
                    ),
                  );
                } else {
                  return TaskStatusDashboard(userName: _enteredUsername);
                }
              },
            ),
          ),
        ],
      ),
    )
        : TaskStatusDashboard();
  }
}