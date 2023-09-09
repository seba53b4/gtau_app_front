import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/providers/selected_items_provider.dart';
import 'package:gtau_app_front/providers/task_filters_provider.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:gtau_app_front/screens/LoginScreen.dart';
import 'package:gtau_app_front/viewmodels/auth_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/catchment_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/section_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/task_list_viewmodel.dart';
import 'package:provider/provider.dart';
import "package:universal_html/html.dart" as html;

Future<void> main() async {
  await dotenv.load(
    fileName: kIsWeb ? '.env.web' : '.env.mobile',
  );
  if (kIsWeb) {
    html.document.dispatchEvent(html.CustomEvent("google-maps-api-key-loaded",
        detail: {"GOOGLE_API_KEY": dotenv.env['GOOGLE_API_KEY']}));
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SelectedItemsProvider>(
          create: (context) => SelectedItemsProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider<TaskFilterProvider>(
          create: (context) => TaskFilterProvider(),
        ),
        ChangeNotifierProvider<TaskListViewModel>(
          create: (context) => TaskListViewModel(),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(),
        ),
        ChangeNotifierProvider<SectionViewModel>(
          create: (context) => SectionViewModel(),
        ),
        ChangeNotifierProvider<CatchmentViewModel>(
          create: (context) => CatchmentViewModel(),
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
        home: LoginScreen(),
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green)));
  }
}
