import 'package:flutter/material.dart';
import 'package:gtau_app_front/screens/HomeScreen.dart';
import 'package:gtau_app_front/screens/LoginScreen.dart';
import 'package:flutter/widgets.dart';

class NavigationWeb extends StatelessWidget {
  final bool isLoggedIn;

  NavigationWeb({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        if (isLoggedIn) ...[
          MaterialPage(child: HomeScreen(), key: ValueKey('home')),
          //MaterialPage(child: TaskCreationPage(), key: ValueKey('create-task')),
          // Otras rutas aquí
          RedirectPage(path: '*', redirectTo: '/home'),
        ] else ...[
          RedirectPage(path: '*', redirectTo: '/login'),
        ],
        MaterialPage(child: LoginScreen(), key: ValueKey('login')),
        MaterialPage(child: NotFoundPage(), key: ValueKey('not-found')),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        // Handle pop logic here

        return true;
      },
    );
  }
}

class RedirectPage extends Page {
  final String redirectTo;

  RedirectPage({required String path, required this.redirectTo})
      : super(key: ValueKey(path));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => Container(),
    );
  }
}

class NotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('NOT FOUND'),
      ),
    );
  }
}
