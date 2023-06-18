import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:gtau_app_front/screens/LoginScreen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import "package:universal_html/html.dart" as html;

Future<void> main() async {
  await dotenv.load();
  if (kIsWeb){
    html.document.dispatchEvent(html.CustomEvent("google-maps-api-key-loaded", detail: {"GOOGLE_API_KEY": dotenv.env['GOOGLE_API_KEY'] }));
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      return MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LoginScreen()
      );
    }
}


