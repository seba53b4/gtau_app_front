import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/models/enums/message_type.dart';
import 'package:gtau_app_front/models/user_data.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../assets/font/gtauicons.dart';
import '../constants/app_constants.dart';
import '../viewmodels/user_list_viewmodel.dart';
import '../widgets/common/customMessageDialog.dart';
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
    // TODO: implement initState
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
      // Manejo de error
      showGenericModalError();
      return null;
    });

    setState(() {
      userData = resp;
    });
  }

  void showGenericModalError({Function? onAcceptPressed}) async {
    await showCustomMessageDialog(
      context: context,
      onAcceptPressed: () {
        if (onAcceptPressed != null) {
          onAcceptPressed();
        }
      },
      customText: AppLocalizations.of(context)!.error_generic_text,
      messageType: DialogMessageType.error,
    );
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
    return Consumer<UserListViewModel>(
      builder: (context, userListViewModel, child) {
        return LoadingOverlay(
          isLoading: userListViewModel.isLoading,
          child: Scaffold(
            backgroundColor: lightBackground,
            body: Center(
              child: SizedBox(
                width: 400,
                height: 600,
                child: Card(
                  child: Visibility(
                    visible: !userListViewModel.isLoading,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: primarySwatch[200]!, width: 2),
                                ),
                                child: Center(
                                  child: Icon(
                                    isAdmin
                                        ? GtauIcons.roleAdmin
                                        : GtauIcons.roleOper,
                                    size: 70,
                                    color: primarySwatch,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 36),
                              const Divider(
                                color: Colors.grey,
                                thickness: 1,
                                indent: 20,
                                endIndent: 20,
                              ),
                              const SizedBox(height: 24),
                              CustomProfileRow(
                                label: 'Nombre',
                                value:
                                    '${userData?.getFirstname} ${userData?.getLastname}',
                              ),
                              const SizedBox(height: 12),
                              CustomProfileRow(
                                label: 'Usuario',
                                value: '${userData?.getUsername}',
                              ),
                              const SizedBox(height: 12),
                              CustomProfileRow(
                                label: 'Email',
                                value: '${userData?.getEmail}',
                              ),
                              const SizedBox(height: 12),
                              CustomProfileRow(
                                label: 'Rol',
                                value: '${userData?.getRol}',
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                          CustomElevatedButton(
                            onPressed: () => handleLogOutPress(context),
                            messageType: MessageType.error,
                            text: AppLocalizations.of(context)!
                                .default_logout_button,
                          ),
                          Text(
                            'Versión: ' + AppConstants.appVersion,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ]),
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
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
