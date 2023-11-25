import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/models/enums/message_type.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:gtau_app_front/screens/LoginScreen.dart';
import 'package:provider/provider.dart';

import '../widgets/common/custom_elevated_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void handleLogOutPress(BuildContext context) {
      final userStateProvider =
          Provider.of<UserProvider>(context, listen: false);
      userStateProvider.logout();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }

    return Scaffold(
      body: SafeArea(
        top: true,
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
              Provider.of<UserProvider>(context).userState?.getUsername ??
                  'OperarioXX',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            Container(
              child: CustomElevatedButton(
                onPressed: () => handleLogOutPress(context),
                messageType: MessageType.error,
                text: AppLocalizations.of(context)!.default_logout_button,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
