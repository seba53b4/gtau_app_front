import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/models/enums/message_type.dart';
import 'package:gtau_app_front/models/user_data.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:gtau_app_front/viewmodels/user_list_viewmodel.dart';
import 'package:gtau_app_front/widgets/common/box_container.dart';
import 'package:gtau_app_front/widgets/common/box_container_white.dart';
import 'package:gtau_app_front/widgets/common/customMessageDialog.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../providers/selected_items_provider.dart';
import '../widgets/common/customDialog.dart';
import '../widgets/common/custom_dropdown.dart';
import '../widgets/common/custom_elevated_button.dart';
import '../widgets/common/custom_text_form_field.dart';

class UserCreationScreen extends StatefulWidget {
  bool detail = false;
  String? idUser = '';

  UserCreationScreen({super.key, this.idUser = '', this.detail = false});

  @override
  _UserCreationScreenState createState() => _UserCreationScreenState();
}

class _UserCreationScreenState extends State<UserCreationScreen> {
  late UserData user;

  int selectedIndex = 0;
  static String notAssigned = "Sin Asignar";
  String userRole = notAssigned;

  final roleController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  late UserListViewModel userListViewModel;
  late String token;

  SelectedItemsProvider? selectedItemsProvider;

  void reset() {
    roleController.text = notAssigned;
    usernameController.text = '';
    emailController.text = '';
    firstnameController.text = '';
    lastnameController.text = '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userListViewModel = Provider.of<UserListViewModel>(context, listen: false);
    token = Provider.of<UserProvider>(context, listen: false).getToken!;
  }

  @override
  void dispose() {
    roleController.dispose();
    usernameController.dispose();
    emailController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    _scrollController.dispose();
    selectedItemsProvider?.reset();

    super.dispose();
  }

  Future updateUserListState(BuildContext context) async {
    const status = 'ACTIVE';
    final userListViewModel =
        Provider.of<UserListViewModel>(context, listen: false);
    userListViewModel.clearListByStatus(status!);
    await userListViewModel.initializeUsers(context, "ACTIVE", "");
  }

  @override
  void initState() {
    super.initState();
    Hive.initFlutter().then((value) => null);
    if (widget.idUser == '') {
      roleController.text = notAssigned;
      usernameController.text = '';
      emailController.text = '';
      firstnameController.text = '';
      lastnameController.text = '';
    } else {
      _fetchUser();
    }
  }

  Future<bool> _fetchUser() async {
    final token = Provider.of<UserProvider>(context, listen: false).getToken;
    final userListViewModel =
        Provider.of<UserListViewModel>(context, listen: false);

    try {
      final responseUser =
          await userListViewModel.fetchUser(token, widget.idUser!);
      if (responseUser != null) {
        setState(() {
          user = responseUser;
        });
      }

      if (user.getRol == 'OPERADOR') {
        userRole =
            AppLocalizations.of(context)!.createUserPage_roleValueOperator;
      } else if (user.getRol == 'ADMINISTRADOR') {
        userRole = AppLocalizations.of(context)!.createUserPage_roleValueAdmin;
      }

      usernameController.text = user.getUsername!;
      emailController.text = user.getEmail ?? '';
      firstnameController.text = user.getFirstname ?? '';
      lastnameController.text = user.getLastname ?? '';

      return true;
    } catch (error) {
      //print(error);
      throw Exception('Error al obtener los datos');
    }
  }

  Future<bool> _createUser(Map<String, dynamic> body) async {
    try {
      final response = await userListViewModel.createUser(token!, body);
      if (response) {
        if (kDebugMode) {
          print('Usuario ha sido creado correctamente');
        }
        await showMessageDialog(DialogMessageType.success);
        return true;
      } else {
        await showCustomMessageDialog(
        context: context,
        customText: AppLocalizations.of(context)!.createuser_error_message,
        onAcceptPressed: () {},
        messageType: DialogMessageType.error,
        );
        if (kDebugMode) {
          print('No se pudieron traer datos');
        }
        return false;
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      throw Exception('Error al obtener los datos');
    }
  }

  Future<bool> _updateUser(Map<String, dynamic> body) async {
    final token = Provider.of<UserProvider>(context, listen: false).getToken;

    final userListViewModel =
        Provider.of<UserListViewModel>(context, listen: false);

    try {
      final response =
          await userListViewModel.updateUser(token!, widget.idUser!, body);

      if (response) {
        if (kDebugMode) {
          print('Usuario ha sido actualizado correctamente');
        }
        await showMessageDialog(DialogMessageType.success);
        return true;
      } else {
        if (kDebugMode) {
          print('No se pudieron traer datos');
        }
        await showCustomMessageDialog(
        context: context,
        customText: AppLocalizations.of(context)!.createuser_error_message,
        onAcceptPressed: () {},
        messageType: DialogMessageType.error,
        );
        return false;
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      throw Exception('Error al obtener los datos');
    }
  }

  Future<void> showMessageDialog(DialogMessageType type) async {
    // bool isAdmin =
    //     Provider.of<UserProvider>(context, listen: false).isAdmin ?? false;
    await showCustomMessageDialog(
        context: context,
        messageType: type,
        onAcceptPressed: () {
          Navigator.pop(context);
        });
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<bool> _ResetPrefs() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.clear();
  }

  void _SoftClearPref() async {
    final prefs = await SharedPreferences.getInstance();
    //prefs.setBool("is_loading", false);
    prefs.setInt("actual_page", 1);
    prefs.setInt("tasks_length", 0);
  }

  void handleSubmit() {
    String bodyMsg = '';
    final bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(emailController.text);
    final bool isRoleValid = roleController.text != notAssigned;
    if (emailValid == false)
      bodyMsg = bodyMsg +
          AppLocalizations.of(context)!.createUserPage_emailWarning +
          '\n';
    if (isRoleValid == false)
      bodyMsg =
          bodyMsg + AppLocalizations.of(context)!.createUserPage_roleWarning;
    if (emailValid == false || isRoleValid == false) {
      showCustomMessageDialog(
        context: context,
        customText: bodyMsg,
        onAcceptPressed: () {},
        messageType: DialogMessageType.error,
      );
    } else {
      showCustomDialog(
        context: context,
        title: AppLocalizations.of(context)!.dialogWarning,
        content: AppLocalizations.of(context)!.dialogContent,
        onDisablePressed: () {
          Navigator.of(context).pop();
        },
        onEnablePressed: () async {
          Navigator.of(context).pop();
          await handleAcceptOnShowDialogCreateUser();
          await updateUserListState(context);
        },
        acceptButtonLabel: AppLocalizations.of(context)!.dialogAcceptButton,
        cancelbuttonLabel: AppLocalizations.of(context)!.dialogCancelButton,
      );
    }
  }

  Map<String, dynamic> createBodyToCreate() {
    var roleFinal = '';
    if (roleController.text ==
        AppLocalizations.of(context)!.createUserPage_roleValueOperator) {
      roleFinal = 'OPERADOR';
    } else if (roleController.text ==
        AppLocalizations.of(context)!.createUserPage_roleValueAdmin) {
      roleFinal = 'ADMINISTRADOR';
    }
    final Map<String, dynamic> requestBody = {
      "email": emailController.text,
      "firstName": firstnameController.text,
      "lastName": lastnameController.text,
      "username": usernameController.text,
      "rol": roleFinal
    };
    return requestBody;
  }

  Map<String, dynamic> createBodyToUpdate() {
    var roleFinal = '';
    var contr = roleController.text;
    if (roleController.text ==
        AppLocalizations.of(context)!.createUserPage_roleValueOperator) {
      roleFinal = 'OPERADOR';
    } else if (roleController.text ==
        AppLocalizations.of(context)!.createUserPage_roleValueAdmin) {
      roleFinal = 'ADMINISTRADOR';
    }
    final Map<String, dynamic> requestBody = {
      "email": emailController.text,
      "firstName": firstnameController.text,
      "lastName": lastnameController.text,
      "username": usernameController.text,
      "rol": roleFinal
    };
    return requestBody;
  }

  Future handleAcceptOnShowDialogEditUser() async {
    Map<String, dynamic> requestBody = createBodyToUpdate();
    bool isUpdated = await _updateUser(requestBody);
    if (isUpdated == true) {
      reset();
    }
    _ResetPrefs();
  }

  Future handleAcceptOnShowDialogCreateUser() async {
    Map<String, dynamic> requestBody = createBodyToCreate();
    bool isUpdated = await _createUser(requestBody);
    if (isUpdated == true) {
      reset();
    }
    _ResetPrefs();
  }

  void handleEditTask() {
    String bodyMsg = '';
    final bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(emailController.text);
    final bool isRoleValid = roleController.text != notAssigned;
    if (emailValid == false)
      bodyMsg = bodyMsg +
          AppLocalizations.of(context)!.createUserPage_emailWarning +
          '\n';
    if (isRoleValid == false)
      bodyMsg =
          bodyMsg + AppLocalizations.of(context)!.createUserPage_roleWarning;
    if (emailValid == false || isRoleValid == false) {
      showCustomMessageDialog(
        context: context,
        customText: bodyMsg,
        onAcceptPressed: () {},
        messageType: DialogMessageType.error,
      );
    } else {
      showCustomDialog(
      context: context,
      title: AppLocalizations.of(context)!.dialogWarning,
      content: AppLocalizations.of(context)!.dialogContent,
      onDisablePressed: () {
        Navigator.of(context).pop();
      },
      onEnablePressed: () async {
        Navigator.of(context).pop();
        await handleAcceptOnShowDialogEditUser();
        await updateUserListState(context);
      },
      acceptButtonLabel: AppLocalizations.of(context)!.dialogAcceptButton,
      cancelbuttonLabel: AppLocalizations.of(context)!.dialogCancelButton,
      );
    }
  }

  void resetSelectionOnMap() {
    selectedItemsProvider?.restoreInitialValues();
  }

  void handleCancel() {
    resetSelectionOnMap();
    Navigator.of(context).pop();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  void scrollToTopScrollView() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    double widthRow = 640;
    double heightRow = 128;

    notAssigned = AppLocalizations.of(context)!.createUserPage_rolePlaceholder;

    return Consumer<UserListViewModel>(
        builder: (context, userListViewModel, child) {
      return LoadingOverlay(
        isLoading: userListViewModel.isLoading,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            color: Colors.transparent,
            margin:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Column(
              children: [
                const SizedBox(height: 12.0),
                Center(
                  child: Visibility(
                    visible: true,
                    child: Form(
                      key: _formKey,
                      child: Container(
                        width: widthRow * 1.15,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              widget.detail
                                  ? AppLocalizations.of(context)!
                                      .createuser_editor_title
                                  : AppLocalizations.of(context)!
                                      .createuser_main_title,
                              style: const TextStyle(fontSize: 32.0),
                            ),
                            const SizedBox(height: 24.0),
                            // Primera fila
                            SizedBox(
                              height: heightRow,
                              width: widthRow,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      const SizedBox(
                                          width: AppConstants.taskRowSpace),
                                      Column(
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .createUserPage_roleTitle,
                                            style:
                                                const TextStyle(fontSize: 16.0),
                                          ),
                                          const SizedBox(height: 12.0),
                                          CustomDropdown(
                                            value: userRole,
                                            width: AppConstants.textFieldWidth,
                                            items: [
                                              notAssigned,
                                              AppLocalizations.of(context)!
                                                  .createUserPage_roleValueOperator,
                                              AppLocalizations.of(context)!
                                                  .createUserPage_roleValueAdmin
                                            ],
                                            onChanged: (String? value) {
                                              setState(() {
                                                roleController.text = value!;
                                              });
                                            },
                                          ),
                                          const SizedBox(
                                              height:
                                                  AppConstants.taskColumnSpace),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                      width: AppConstants.taskRowSpace),
                                  Column(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .createUserPage_emailTitle,
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                      const SizedBox(
                                          height: AppConstants.taskColumnSpace),
                                      CustomTextFormField(
                                        width: AppConstants.textFieldWidth * 2 +
                                            AppConstants.taskRowSpace +
                                            16,
                                        hintText: AppLocalizations.of(context)!
                                            .createUserPage_emailPlaceholder,
                                        controller: emailController,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            // Segunda fila
                            SizedBox(
                              height: heightRow,
                              width: widthRow,
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .createUserPage_usernameTitle,
                                          style:
                                              const TextStyle(fontSize: 16.0),
                                        ),
                                        const SizedBox(height: 12.0),
                                        CustomTextFormField(
                                          hintText: AppLocalizations.of(
                                                  context)!
                                              .createUserPage_usernamePlaceholder,
                                          controller: usernameController,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .createUserPage_firstnameTitle,
                                          style:
                                              const TextStyle(fontSize: 16.0),
                                        ),
                                        const SizedBox(
                                            height:
                                                AppConstants.taskColumnSpace),
                                        CustomTextFormField(
                                          hintText: AppLocalizations.of(
                                                  context)!
                                              .createUserPage_firstnamePlaceholder,
                                          controller: firstnameController,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .createUserPage_lastnameTitle,
                                          style:
                                              const TextStyle(fontSize: 16.0),
                                        ),
                                        const SizedBox(
                                            height:
                                                AppConstants.taskColumnSpace),
                                        CustomTextFormField(
                                          hintText: AppLocalizations.of(
                                                  context)!
                                              .createUserPage_lastnamePlaceholder,
                                          controller: lastnameController,
                                        ),
                                      ],
                                    ),
                                  ]),
                            ),
                            // Tercera fila
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 50.0,
                  margin: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomElevatedButton(
                        messageType: MessageType.error,
                        onPressed: handleCancel,
                        text: AppLocalizations.of(context)!.buttonCancelLabel,
                      ),
                      const SizedBox(width: 12.0),
                      CustomElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (widget.idUser == '') {
                              handleSubmit();
                            } else {
                              // Se quita acción de creación en Programada
                              handleEditTask();
                            }
                          } else {
                            scrollToTopScrollView();
                          }
                        },
                        text: widget.idUser != ''
                            ? AppLocalizations.of(context)!.buttonAcceptLabel
                            : AppLocalizations.of(context)!
                                .createTaskPage_submitButton,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
