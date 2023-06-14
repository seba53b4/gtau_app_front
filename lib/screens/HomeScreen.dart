import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gtau_app_front/widgets/TaskList.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeScreen'),
      ),
      body: TaskList(),
    );
  }
}
