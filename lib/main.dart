import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/providers/selected_items_provider.dart';
import 'package:gtau_app_front/providers/task_filters_provider.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:gtau_app_front/screens/AuthCheckScreen.dart';
import 'package:gtau_app_front/viewmodels/auth_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/catchment_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/images_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/lot_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/register_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/scheduled_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/section_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/task_list_scheduled_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/task_list_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/zone_load_viewmodel.dart';
import 'package:provider/provider.dart';
import "package:universal_html/html.dart" as html;

import 'constants/theme_constants.dart';

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
        ChangeNotifierProvider<TaskListScheduledViewModel>(
          create: (context) => TaskListScheduledViewModel(),
        ),
        ChangeNotifierProvider<ImagesViewModel>(
          create: (context) => ImagesViewModel(),
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
        ChangeNotifierProvider<RegisterViewModel>(
          create: (context) => RegisterViewModel(),
        ),
        ChangeNotifierProvider<LotViewModel>(
          create: (context) => LotViewModel(),
        ),
        ChangeNotifierProvider<ScheduledViewModel>(
          create: (context) => ScheduledViewModel(),
        ),
        ChangeNotifierProvider<ZoneLoadViewModel>(
          create: (context) => ZoneLoadViewModel(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AuthCheck(),
        theme: defaultTheme);
  }
}
