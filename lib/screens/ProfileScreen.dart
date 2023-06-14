import 'package:flutter/material.dart';
import 'package:gtau_app_front/providers/app_context.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void handleLogOutPress() {}

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundImage: NetworkImage(
                  'https://randomuser.me/api/portraits/men/36.jpg'),
            ),
            Text(
              'Operario123',
              style: Theme.of(context).textTheme.headline3,
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              width: 200,
              child: ElevatedButton(
                onPressed: handleLogOutPress,
                style: ElevatedButton.styleFrom(
                  primary: Color.fromRGBO(78, 116, 289, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                child: const Text(
                  'Log out',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
