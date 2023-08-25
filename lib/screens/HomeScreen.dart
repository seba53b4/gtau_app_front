import 'package:flutter/material.dart';
import 'package:gtau_app_front/widgets/task_status_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  void updateSearch(String search) {
    // Lógica de filtrado según la búsqueda
  }

  @override
  Widget build(BuildContext context) {
    return const TaskStatusDashboard();
    // return SizedBox(
    //   width: 500,
    //   height: 300,
    //   child: Column(
    //     children: [
    //       TextField(
    //         decoration: const InputDecoration(
    //           hintText: 'Ingrese un nombre de usuario',
    //         ),
    //         onChanged: updateSearch,
    //         controller: _searchController,
    //       ),
    //       const TaskStatusDashboard(),
    //     ],
    //   ),
    // );
  }
}

