import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gtau_app_front/constants/app_constants.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/models/enums/message_type.dart';
import 'package:gtau_app_front/models/user_data.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:gtau_app_front/widgets/common/background_gradient.dart';
import 'package:gtau_app_front/widgets/common/custom_elevated_button_length.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../assets/font/gtauicons.dart';
import '../utils/messagesUtils.dart';
import '../viewmodels/user_list_viewmodel.dart';
import '../widgets/common/custom_elevated_button.dart';
import 'LoginScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String username;
  bool isAdmin = false;
  late UserData? userData = null;

  @override
  void initState() {
    super.initState();
    username = context.read<UserProvider>().userName!;
    isAdmin = context.read<UserProvider>().isAdmin!;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getUser();
    });
  }

  void getUser() async {
    final userListViewModel =
        Provider.of<UserListViewModel>(context, listen: false);
    final token = context.read<UserProvider>().getToken!;

    final resp = await userListViewModel
        .fetchUserByUsername(token, username)
        .catchError((error) async {
      showGenericModalError(context: context);
      return null;
    });

    setState(() {
      userData = resp;
    });
  }

  void handleLogOutPress(BuildContext context) async {
    final userStateProvider = Provider.of<UserProvider>(context, listen: false);
    userStateProvider.logout();
    const FlutterSecureStorage storage = FlutterSecureStorage();
    await storage.deleteAll();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double rowHeigthSpace = 12;
    double heightCard = MediaQuery.of(context).size.height;
    double widthCard = MediaQuery.of(context).size.width;
    final appLocalizations = AppLocalizations.of(context)!;

    return Consumer<UserListViewModel>(
      builder: (context, userListViewModel, child) {
        return LoadingOverlay(
          isLoading: userListViewModel.isLoading,
          child: Scaffold(
            body: BackgroundGradient(
              decoration: kIsWeb ? null : BoxDecoration(
                  color: lightGrayBackground,      
              ),   
              child: Center(
                child: SizedBox(
                  width: kIsWeb ? 520 : widthCard,
                  height: kIsWeb ? heightCard * 0.85 : heightCard,
                  child: Card(
                    color: kIsWeb ? null : lightGrayBackground,
                    elevation: kIsWeb ? null : 0.0,
                    shape: kIsWeb ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ) : null,
                    child: Visibility(
                      visible: !userListViewModel.isLoading,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: kIsWeb ? 250 : heightCard * 0.25,
                            width: kIsWeb ? 520 : widthCard,
                            padding: const EdgeInsets.only(top: 24, bottom: 24),
                            decoration: kIsWeb ? BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: const BorderRadius.all(Radius.circular(20),
                              ),
                            ) : null,
                            child: Container(
                              width: 60,
                              height: 60,
                              margin: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(128, 128, 128, 0.49),
                                    spreadRadius: 3,
                                    blurRadius: 7,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                color: primarySwatch[700],
                                shape: BoxShape.circle,
                              ),
                              child: Align(
                                alignment: kIsWeb ? Alignment.topCenter : Alignment.center,
                                child: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  radius: kIsWeb ? 70 : 60,
                                  child: Icon(
                                    isAdmin
                                        ? GtauIcons.roleAdmin
                                        : GtauIcons.roleOper,
                                    size: kIsWeb ? 78 : 60,
                                    color: lightBackground,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: rowHeigthSpace),
                          const Divider(
                            color: Colors.grey,
                            thickness: 1,
                            indent: 20,
                            endIndent: 20,
                          ),
                          const SizedBox(height: kIsWeb ? 48 : 12),
                          CustomProfileRow(
                            label: appLocalizations.name,
                            value:
                                '${userData?.getFirstname} ${userData?.getLastname}',
                          ),
                          const SizedBox(height: rowHeigthSpace),
                          CustomProfileRow(
                            label: appLocalizations.user,
                            value: '${userData?.getUsername}',
                          ),
                          const SizedBox(height: rowHeigthSpace),
                          CustomProfileRow(
                            label: appLocalizations.email,
                            value: '${userData?.getEmail}',
                          ),
                          const SizedBox(height: rowHeigthSpace),
                          CustomProfileRow(
                            label: appLocalizations.role,
                            value: isAdmin ? 'Administrador' : 'Operario',
                          ),
                          const Spacer(),
                          Container(
                            margin: const EdgeInsets.only(left: 20, right:20, bottom:20),
                            child: CustomElevatedButtonLength(
                              onPressed: () => handleLogOutPress(context),
                              messageType: MessageType.error,
                              text: AppLocalizations.of(context)!
                                  .default_logout_button,
                            ),
                          ),
                          Text(
                            '${appLocalizations.version} ${AppConstants.appVersion}',
                            style:
                                const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: rowHeigthSpace),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CustomProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const CustomProfileRow({Key? key, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              value.contains('null')
                  ? appLocalizations.component_detail_no_data
                  : value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
