import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gtau_app_front/widgets/TaskList.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('HomeScreen'),
      ),
      body: Container(
        child: TaskList(),
      ),
    );
  }
}