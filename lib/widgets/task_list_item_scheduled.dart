import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gtau_app_front/assets/font/gtauicons.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/models/scheduled/task_scheduled.dart';
import 'package:gtau_app_front/screens/TaskCreationScreen.dart';
import 'package:gtau_app_front/viewmodels/task_list_scheduled_viewmodel.dart';
import 'package:provider/provider.dart';

import '../providers/task_filters_provider.dart';
import '../providers/user_provider.dart';
import '../utils/date_utils.dart';
import '../utils/task_utils.dart';
import 'common/customDialog.dart';
import 'common/customMessageDialog.dart';
import 'loading_overlay.dart';

class TaskListItemScheduled extends StatelessWidget {
  final TaskScheduled? taskScheduled;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const TaskListItemScheduled(
      {Key? key, required this.taskScheduled, required this.scaffoldKey})
      : super(key: key);

  void _goToTaskCreationPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskCreationScreen(
          detail: true,
          idTask: taskScheduled!.id,
          scheduledEdit: true,
          type: 'scheduled',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.read<UserProvider>().isAdmin;
    double fontSize = kIsWeb ? 12 : 10;
    double fontSizeInfo = kIsWeb ? 12 : 9;
    double titleSpace = kIsWeb ? 200 : 120;
    double dividerHeight = kIsWeb ? 32 : 24;
    double taskInfoSpace = kIsWeb ? 150 : 115;
    double iconSize = kIsWeb ? 26 : 24;
    final appLocalizations = AppLocalizations.of(context)!;

    if (!kIsWeb) {
      final widthScreen = MediaQuery.of(context).size.width;
      if (widthScreen < 400) {
        titleSpace = widthScreen * 0.25;
      }
    }

    return InkWell(
      onTap: () {
        _goToTaskCreationPage(context);
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: lightBackground,
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(94, 102, 87, 0.494),
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
                backgroundColor: Colors.deepPurple,
                radius: 20,
                child: Stack(children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 18,
                      child: const Icon(GtauIcons.tasksSurvey,
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
                          getParsedText(
                              '${taskScheduled?.title}', kIsWeb ? 74 : 56),
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
                                '${appLocalizations.list_item_date}         ${parseDateTime(taskScheduled!.addDate)}',
                                style: TextStyle(fontSize: fontSizeInfo),
                              ),
                              // Text(
                              //   taskScheduled!.getUser!,
                              //   style: TextStyle(fontSize: fontSizeInfo),
                              // ),
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

    // Mostrar el diálogo de confirmación
    await showCustomDialog(
      context: showDialogContext,
      title: AppLocalizations.of(showDialogContext)!.dialogWarning,
      content: AppLocalizations.of(showDialogContext)!.dialogContent,
      onDisablePressed: () {
        Navigator.of(showDialogContext).pop();
      },
      onEnablePressed: () async {
        Navigator.of(showDialogContext).pop();
        LoadingOverlay loadingOverlay = LoadingOverlay(
          isLoading: true,
          child: Container(),
        );
        showDialog(
          context: showDialogContext,
          builder: (BuildContext context) => loadingOverlay,
          barrierDismissible: false,
        );

        bool result = await _deleteTask(context, taskScheduled!.id!);

        Navigator.of(showDialogContext).pop();

        if (result) {
          await showCustomMessageDialog(
            context: showDialogContext,
            messageType: DialogMessageType.success,
            onAcceptPressed: () {},
          );
        } else {
          await showCustomMessageDialog(
            context: showDialogContext,
            messageType: DialogMessageType.error,
            onAcceptPressed: () {},
          );
        }
        await updateTaskListState(showDialogContext);
      },
      acceptButtonLabel: AppLocalizations.of(context)!.dialogAcceptButton,
      cancelbuttonLabel: AppLocalizations.of(context)!.dialogCancelButton,
    );
  }

  Future updateTaskListState(BuildContext context) async {
    final token = context.read<UserProvider>().getToken!;
    final status =
        Provider.of<TaskFilterProvider>(context, listen: false).statusFilter;
    final taskListScheduledViewModel =
        Provider.of<TaskListScheduledViewModel>(context, listen: false);
    taskListScheduledViewModel.clearListByStatus(status!);
    await taskListScheduledViewModel.fetchScheduledTasks(token, status);
  }

  Future<bool> _deleteTask(BuildContext context, int id) async {
    final token = context.read<UserProvider>().getToken;
    final taskListScheduledViewModel =
        Provider.of<TaskListScheduledViewModel>(context, listen: false);
    bool result =
        await taskListScheduledViewModel.deleteTaskScheduled(token!, id);
    return result;
  }
}
