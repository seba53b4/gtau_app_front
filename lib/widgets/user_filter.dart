import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/constants/app_constants.dart';
import 'package:gtau_app_front/models/enums/message_type.dart';
import 'package:gtau_app_front/models/task_status.dart';
import 'package:gtau_app_front/models/value_label.dart';
import 'package:gtau_app_front/providers/user_filter_provider.dart';
import 'package:gtau_app_front/viewmodels/task_list_scheduled_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/user_list_viewmodel.dart';
import 'package:gtau_app_front/widgets/common/custom_dropdown.dart';
import 'package:gtau_app_front/widgets/common/custom_elevated_button_length.dart';
import 'package:gtau_app_front/widgets/text_field_filter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/task_filters_provider.dart';
import '../providers/user_provider.dart';
import '../viewmodels/task_list_viewmodel.dart';
import 'common/box_container.dart';
import 'common/custom_elevated_button.dart';
import 'dropdown_button_filter.dart';

class UserFilter extends StatefulWidget {
  const UserFilter({
    super.key,
  });

  @override
  State<UserFilter> createState() => _UserFilterState();
}

class _UserFilterState extends State<UserFilter> {
  static const String notAssigned = "Sin asignar";
  String userRole = notAssigned;

  final roleController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();

  double widthRow = 640;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late UserFilterProvider filterProvider;
  late UserListViewModel userListViewModel;
  late String token;

  @override
  void initState() {
    super.initState();
    filterProvider = Provider.of<UserFilterProvider>(context, listen: false);
    userListViewModel = Provider.of<UserListViewModel>(context, listen: false);
    token = Provider.of<UserProvider>(context, listen: false).getToken!;
  }

  /*void dispose() {
    roleController.dispose();
    usernameController.dispose();
    emailController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();

    super.dispose();
  }*/


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

  Future resetUserList() async {
    final status = 'ACTIVE';
    final userListViewModel =
        Provider.of<UserListViewModel>(context, listen: false);
    userListViewModel.clearListByStatus(status!);
    await userListViewModel.initializeUsers(context, "ACTIVE", "");
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final userProvider = context.read<UserProvider>();
    final filterProvider = Provider.of<UserFilterProvider>(context);
    final List<ValueLabel> _suggestionsRoles = [
      ValueLabel(AppLocalizations.of(context)!.createUserPage_rolePlaceholder, notAssigned),
      ValueLabel(AppLocalizations.of(context)!.createUserPage_roleValueOperator, 'OPERADOR'),
      ValueLabel(AppLocalizations.of(context)!.createUserPage_roleValueAdmin, 'ADMINISTRADOR'),
    ];
    return Scaffold(
      appBar: AppBar(
          title: Padding(
        padding: const EdgeInsets.only(right: 80),
        child: Center(
            child: Text(
          appLocalizations.filter_users_title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: kIsWeb ? 18 : 22),
        )),
      )),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: widthRow,
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 8),
                  
                  DropdownButtonFilter(
                    suggestions: _suggestionsRoles,
                    valueSetter: filterProvider.setRoleFilter,
                    dropdownValue: filterProvider.roleFilter ??
                        _suggestionsRoles.first.value,
                    label: appLocalizations.createUserPage_roleTitle,
                    enabled: true,
                  ),
                  const SizedBox(height: 16),
                  TextFieldFilter(
                    valueSetter: filterProvider.setUserNameFilter,
                    value: filterProvider.userNameFilter ?? "",
                    label: appLocalizations.createUserPage_usernameTitle,
                  ),
                  const SizedBox(height: 16),
                  TextFieldFilter(
                      valueSetter: filterProvider.setEmailFilter,
                      value: filterProvider.emailFilter ?? "",
                      label: appLocalizations.createUserPage_emailTitle),
                  const SizedBox(height: 16),
                  TextFieldFilter(
                      valueSetter: filterProvider.setFirstNameFilter,
                      value: filterProvider.firstnameFilter ?? "",
                      label:
                          appLocalizations.createUserPage_firstnameTitle),
                  const SizedBox(height: 16),
                  TextFieldFilter(
                      valueSetter: filterProvider.setLastNameFilter,
                      value: filterProvider.lastnameFilter ?? "",
                      label: appLocalizations.createUserPage_lastnameTitle),
                  const SizedBox(height: 16),
                  Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                                CustomElevatedButtonLength(
                                  onPressed: () {
                                    if(filterProvider.roleFilter == notAssigned){
                                      filterProvider.setRoleFilter(null);
                                    }
                                    context.read<UserFilterProvider>().search();
                                    _SoftClearPref();
                                    updateUserListState(context);
                                    Navigator.of(context).pop();
                                  },
                                  text: appLocalizations.buttonApplyLabel,
                                ),
                                const SizedBox(height: 15),
                                CustomElevatedButtonLength(
                                  onPressed: () {
                                    var userFilterProvider =
                                        context.read<UserFilterProvider>();
                                    userFilterProvider
                                        .resetFilters();
                                    _ResetPrefs();
                                    resetUserList();
                                    Navigator.of(context).pop();
                                  },
                                  messageType: MessageType.error,
                                  text: appLocalizations.buttonCleanLabel,
                                ),
                                const SizedBox(height: 8),
                              
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future updateUserListState(BuildContext context) async {
    userListViewModel.clearListByStatus('ACTIVE');
    await userListViewModel.fetchUserByFilter(token, filterProvider.userNameFilter, filterProvider.emailFilter, filterProvider.firstnameFilter, filterProvider.lastnameFilter, filterProvider.roleFilter);
  }
}