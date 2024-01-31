import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/assets/font/gtauicons.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/models/user_data.dart';
import 'package:gtau_app_front/screens/UserCreationScreen.dart';
import 'package:gtau_app_front/viewmodels/user_list_viewmodel.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../utils/common_utils.dart';
import 'common/customDialog.dart';
import 'common/customMessageDialog.dart';

class UserListItem extends StatelessWidget {
  final UserData? user;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const UserListItem({Key? key, required this.user, required this.scaffoldKey})
      : super(key: key);

  Future<void> _goToUserCreationPage(BuildContext context) async {
    var userListViewModel =
        Provider.of<UserListViewModel>(context, listen: false);
    final token = context.read<UserProvider>().getToken;
    var response = await userListViewModel.fetchUser(token, user!.getId!);
    var username = response!.getUsername;

    _showAddUserModal(context, user!.getId);
  }

  void _showAddUserModal(BuildContext context, String? isUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(50.0))),
          child: SizedBox(
            width: 700,
            height: 516,
            child: UserCreationScreen(
              detail: true,
              idUser: user!.getId,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.read<UserProvider>().isAdmin;
    double fontSize = kIsWeb ? 15 : 12;
    double fontSizeInfo = kIsWeb ? 12 : 9;
    double titleSpace = kIsWeb ? 200 : 120;
    double dividerHeight = kIsWeb ? 32 : 24;
    double taskInfoSpace = kIsWeb ? 150 : 115;
    double iconSize = kIsWeb ? 26 : 24;
    final appLocalizations = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () {
        _goToUserCreationPage(context);
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: lightBackground,
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(200, 217, 184, 0.5),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: primarySwatch[900],
                radius: 20,
                child: Stack(children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 18,
                      child: (user!.getRol == 'ADMINISTRADOR')
                          ? const Icon(GtauIcons.roleAdmin,
                              size: 20, color: Colors.white)
                          : const Icon(GtauIcons.roleOper,
                              size: 20, color: Colors.white),
                    ),
                  ),
                ]),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                      width: titleSpace,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 8),
                        child: Text(
                          '${user!.getUsername}',
                          style: TextStyle(fontSize: fontSize),
                        ),
                      )),
                  const SizedBox(width: kIsWeb ? 20 : 12),
                  Container(
                    height: dividerHeight,
                    width: 1,
                    color: Colors.black,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Wrap(
                      spacing: 8.0, // gap between adjacent chips
                      runSpacing: 4.0, // gap between lines
                      direction: Axis.vertical,
                      children: [
                        SizedBox(
                          width: taskInfoSpace,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appLocalizations.list_item_firstname +
                                    user!.getFirstname!,
                                style: TextStyle(fontSize: fontSizeInfo),
                              ),
                              Text(
                                appLocalizations.list_item_lastname +
                                    user!.getLastname!,
                                style: TextStyle(fontSize: fontSizeInfo),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: kIsWeb ? 24 : 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Visibility(
                  visible: isAdmin != null && !isAdmin,
                  child: SizedBox(
                    width: iconSize * 1,
                    height: iconSize * 1,
                  ),
                ),
                Visibility(
                  visible: isAdmin != null && isAdmin,
                  child: IconButton(
                    padding:
                        const EdgeInsetsDirectional.symmetric(horizontal: 12),
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    iconSize: iconSize,
                    onPressed: () async {
                      await _showDeleteConfirmationDialog(context);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final showDialogContext = scaffoldKey.currentContext!;

    await showCustomDialog(
      context: showDialogContext,
      title: AppLocalizations.of(showDialogContext)!.dialogWarning,
      content: AppLocalizations.of(showDialogContext)!.dialogContent,
      onDisablePressed: () {
        Navigator.of(showDialogContext).pop();
      },
      onEnablePressed: () async {
        Navigator.of(showDialogContext).pop();
        bool result = await _deleteUser(context, user!.id!);

        if (result) {
          printOnDebug('Usuario ha sido eliminado correctamente');
          await showCustomMessageDialog(
            context: showDialogContext,
            messageType: DialogMessageType.success,
            onAcceptPressed: () {},
          );
        } else {
          printOnDebug('No se pudo eliminar el usuario');
          await showCustomMessageDialog(
            context: showDialogContext,
            messageType: DialogMessageType.error,
            onAcceptPressed: () {},
          );
        }
        await updateUserListState(showDialogContext);
      },
      acceptButtonLabel: AppLocalizations.of(context)!.dialogAcceptButton,
      cancelbuttonLabel: AppLocalizations.of(context)!.dialogCancelButton,
    );
  }

  Future updateUserListState(BuildContext context) async {
    final status = 'ACTIVE';
    final userListViewModel =
        Provider.of<UserListViewModel>(context, listen: false);
    userListViewModel.clearListByStatus(status!);
    await userListViewModel.initializeUsers(context, "ACTIVE", "");
  }

  Future<bool> _deleteUser(BuildContext context, String id) async {
    final token = context.read<UserProvider>().getToken;
    final userListViewModel =
        Provider.of<UserListViewModel>(context, listen: false);
    bool result = await userListViewModel.deleteUser(token!, id);
    return result;
  }
}
