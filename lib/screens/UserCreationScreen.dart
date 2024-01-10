import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/models/enums/message_type.dart';
import 'package:gtau_app_front/models/task_status.dart';
import 'package:gtau_app_front/navigation/navigation_web.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:gtau_app_front/viewmodels/user_list_viewmodel.dart';
import 'package:gtau_app_front/widgets/common/box_container.dart';
import 'package:gtau_app_front/widgets/common/customMessageDialog.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../dto/image_data.dart';
import '../models/task.dart';
import '../navigation/navigation.dart';
import '../providers/selected_items_provider.dart';
import '../providers/task_filters_provider.dart';
import '../utils/date_utils.dart';
import '../utils/imagesbundle.dart';
import '../viewmodels/images_viewmodel.dart';
import '../viewmodels/task_list_viewmodel.dart';
import '../widgets/common/customDialog.dart';
import '../widgets/common/custom_dropdown.dart';
import '../widgets/common/custom_elevated_button.dart';
import '../widgets/common/custom_text_form_field.dart';
import '../widgets/common/custom_toggle_buttons.dart';
import '../widgets/common/inspection_location_select.dart';
import '../widgets/common/task_creation/create_scheduled.dart';
import '../widgets/common/task_creation/element_selected.dart';
import '../widgets/image_gallery_modal.dart';
import '../widgets/user_image.dart';

class UserCreationScreen extends StatefulWidget {
  var type = 'inspection';
  bool detail = false;
  int? idTask = 0;

  UserCreationScreen(
      {super.key, required this.type, this.detail = false, this.idTask = 0});

  @override
  _UserCreationScreenState createState() => _UserCreationScreenState();
}

class _UserCreationScreenState extends State<UserCreationScreen> {
  late Task task;
  late DateTime? startDate;
  late DateTime? releasedDate;
  int selectedIndex = 0;
  static const String notAssigned = "Sin asignar";
  String userRole = notAssigned;
  late String taskStatus = 'PENDING';
  late String initStatus = 'PENDING';
  final roleController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final passwordController = TextEditingController();
  final passconfirmController = TextEditingController();

  SelectedItemsProvider? selectedItemsProvider;

  String numOrder = "";

  void reset() {
    roleController.text = notAssigned;
    usernameController.text = '';
    emailController.text = '';
    firstnameController.text = '';
    lastnameController.text = '';
    passwordController.text = '';
    passconfirmController.text = '';
    /*setState(() {
      userAssigned = notAssigned;
    });*/
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedItemsProvider = context.read<SelectedItemsProvider>();
  }

  @override
  void dispose() {
    roleController.dispose();
    usernameController.dispose();
    emailController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    passwordController.dispose();
    passconfirmController.dispose();
    _scrollController.dispose();
    selectedItemsProvider?.reset();

    super.dispose();
  }

  @override
  void initState() {
    Hive.initFlutter().then((value) => null);
    roleController.text = notAssigned;
    usernameController.text = '';
    emailController.text = '';
    firstnameController.text = '';
    lastnameController.text = '';
    passwordController.text = '';
    passconfirmController.text = '';
  }

  

  Future<bool> _createUser(Map<String, dynamic> body) async {
    final token = Provider.of<UserProvider>(context, listen: false).getToken;
    final userListViewModel =
        Provider.of<UserListViewModel>(context, listen: false);
    try {
      final response = await userListViewModel.createUser(token!, body);
      if (response) {
        print('Usuario ha sido creada correctamente');
        await showMessageDialog(DialogMessageType.success);
        return true;
      } else {
        await showMessageDialog(DialogMessageType.error);
        print('No se pudieron traer datos');
        return false;
      }
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos');
    }
  }

  Future<bool> _updateTask(Map<String, dynamic> body) async {
    if (Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ImageBundleAdapter());
    }
    final token = Provider.of<UserProvider>(context, listen: false).getToken;

    final taskListViewModel =
        Provider.of<TaskListViewModel>(context, listen: false);

    try {
      final response =
          await taskListViewModel.updateTask(token!, widget.idTask!, body);

      if (response) {
        print('Tarea ha sido actualizada correctamente');
        await showMessageDialog(DialogMessageType.success);
        return true;
      } else {
        print('No se pudieron traer datos');
        await showMessageDialog(DialogMessageType.error);
        return false;
      }
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos');
    }
  }

  Future<void> showMessageDialog(DialogMessageType type) async {
    await showCustomMessageDialog(
        context: context,
        messageType: type,
        onAcceptPressed: () {
          if (type == DialogMessageType.success && !widget.detail) {
            Widget nav =
                kIsWeb ? const NavigationWeb() : const BottomNavigation();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => nav),
            );
          }
        });
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<bool> _ResetPrefs() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.clear();
  }

  void handleSubmit() {
    String bodyMsg = '';
    final bool emailValid = 
    RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
    .hasMatch(emailController.text);
    final bool isPassValid = passwordController.text == passconfirmController.text;
    final bool isRoleValid = roleController.text != notAssigned;
    if(emailValid == false) bodyMsg = bodyMsg + AppLocalizations.of(context)!.createUserPage_emailWarning + '\n';
    if(isPassValid == false) bodyMsg = bodyMsg + AppLocalizations.of(context)!.createUserPage_passwordWarning + '\n';
    if(isRoleValid == false) bodyMsg = bodyMsg + AppLocalizations.of(context)!.createUserPage_roleWarning;
    if(emailValid == false || isPassValid == false || isRoleValid == false){
      showCustomMessageDialog(
        context: context,
        customText: bodyMsg,
        onAcceptPressed: () {
        }, 
        messageType: DialogMessageType.error,
      );
    }else{
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
        },
        acceptButtonLabel: AppLocalizations.of(context)!.dialogAcceptButton,
        cancelbuttonLabel: AppLocalizations.of(context)!.dialogCancelButton,
      );
    }      
  }

  Map<String, dynamic> createBodyToCreate() {
    final Map<String, dynamic> requestBody = {
      "email": emailController.text,
      "firstName": firstnameController.text,
      "lastName": lastnameController.text,
      "username": usernameController.text,
      "rol": roleController.text
    };
    return requestBody;
  }

  Map<String, dynamic> createBodyToUpdate() {
    
    final Map<String, dynamic> requestBody = {
      "email": emailController.text,
      "firstName": firstnameController.text,
      "lastName": lastnameController.text,
      "username": usernameController.text,
      "rol": roleController.text
    };
    return requestBody;
  }

  Future handleAcceptOnShowDialogEditUser() async {
    Map<String, dynamic> requestBody = createBodyToUpdate();
    bool isUpdated = await _updateTask(requestBody);
    if (isUpdated) {
      reset();
    }
    _ResetPrefs();
  }

  Future handleAcceptOnShowDialogCreateUser() async {
    Map<String, dynamic> requestBody = createBodyToCreate();
    bool isUpdated = await _createUser(requestBody);
    if (isUpdated) {
      reset();
    }
    _ResetPrefs();
  }

  void handleEditTask() {
    showCustomDialog(
      context: context,
      title: AppLocalizations.of(context)!.dialogWarning,
      content: AppLocalizations.of(context)!.dialogContent,
      onDisablePressed: () {
        Navigator.of(context).pop();
      },
      onEnablePressed: () async {
        Navigator.of(context).pop();
        /*await handleAcceptOnShowDialogEditTask();*/
      },
      acceptButtonLabel: AppLocalizations.of(context)!.dialogAcceptButton,
      cancelbuttonLabel: AppLocalizations.of(context)!.dialogCancelButton,
    );
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

    return Consumer<TaskListViewModel>(
        builder: (context, taskListViewModel, child) {
      return LoadingOverlay(
        isLoading: taskListViewModel.isLoading,
        child: Scaffold(
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: Column(
                children: [
                  const SizedBox(height: 12.0),
                  Center(
                    child:
                    Visibility(
                      visible: true,
                      child: Form(
                        key: _formKey,
                        child: BoxContainer(
                          width: widthRow * 1.15,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                                .createuser_main_title,
                                style: const TextStyle(fontSize: 32.0),
                              ),
                              const SizedBox(height: 24.0),
                              // Primera fila
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
                                          const SizedBox(
                                              width: AppConstants.taskRowSpace),
                                          Column(
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)!
                                      .createUserPage_roleTitle,
                                                style: const TextStyle(
                                                    fontSize: 16.0),
                                              ),
                                              const SizedBox(height: 12.0),
                                              CustomDropdown(
                                                value: userRole,
                                                items: const [
                                                  notAssigned,
                                                  'OPERADOR',
                                                  'ADMINISTRADOR'
                                                ],
                                                onChanged: (String? value) {
                                                  setState(() {
                                                    roleController.text = value!;
                                                  });
                                                },
                                              ),
                                              const SizedBox(
                                                  height: AppConstants
                                                      .taskColumnSpace),
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
                                      .createUserPage_usernameTitle,
                                          style: const TextStyle(fontSize: 16.0),
                                        ),
                                        const SizedBox(height: 12.0),
                                        CustomTextFormField(
                                          width: AppConstants.textFieldWidth * 2 +
                                              AppConstants.taskRowSpace,
                                          hintText: AppLocalizations.of(context)!
                                              .createUserPage_usernamePlaceholder,
                                          controller: usernameController,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              //const SizedBox(height: 20.0),
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
                                      .createUserPage_emailTitle,
                                            style:
                                                const TextStyle(fontSize: 16.0),
                                          ),
                                          const SizedBox(
                                              height:
                                                  AppConstants.taskColumnSpace),
                                          CustomTextFormField(
                                            hintText: AppLocalizations.of(
                                                    context)!
                                                .createUserPage_emailPlaceholder,
                                            controller: emailController,
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
                                      .createUserPage_passwordTitle,
                                          style: const TextStyle(fontSize: 16.0),
                                        ),
                                        const SizedBox(height: 12.0),
                                        CustomTextFormField(
                                          width: (widthRow / 2) - (AppConstants.taskRowSpace / 2),
                                          hintText: AppLocalizations.of(context)!
                                              .createUserPage_passwordPlaceholder,
                                          controller: passwordController,
                                          obscureText: true
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                        width: AppConstants.taskRowSpace),
                                    Column(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                      .createUserPage_passconfirmTitle,
                                          style: const TextStyle(fontSize: 16.0),
                                        ),
                                        const SizedBox(height: 12.0),
                                        CustomTextFormField(
                                          width: (widthRow / 2) - (AppConstants.taskRowSpace / 2),
                                          hintText: AppLocalizations.of(context)!
                                              .createUserPage_passconfirmPlaceholder,
                                          controller: passconfirmController,
                                          obscureText: true,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
                          if (widget.detail)
                            CustomElevatedButton(
                              messageType: MessageType.error,
                              onPressed: handleCancel,
                              text: AppLocalizations.of(context)!
                                  .buttonCancelLabel,
                            ),
                          const SizedBox(width: 12.0),
                          CustomElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                handleSubmit();
                                
                                /*if (widget.detail) {
                                  handleEditTask();
                                } else {
                                  // Se quita acción de creación en Programada
                                  if (selectedIndex == 1) {
                                    handleSubmit();
                                  }
                                }*/
                              } else {
                                scrollToTopScrollView();
                              }
                            },
                            text: widget.detail
                                ? AppLocalizations.of(context)!
                                    .buttonAcceptLabel
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
        ),
      );
    });
  }
}
