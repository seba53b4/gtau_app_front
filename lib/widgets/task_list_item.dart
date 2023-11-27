import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/models/task.dart';
import 'package:gtau_app_front/screens/TaskCreationScreen.dart';
import 'package:provider/provider.dart';

import '../providers/task_filters_provider.dart';
import '../providers/user_provider.dart';
import '../utils/date_utils.dart';
import '../viewmodels/task_list_viewmodel.dart';
import 'common/customDialog.dart';
import 'common/customMessageDialog.dart';

class TaskListItem extends StatelessWidget {
  final Task? task;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const TaskListItem({Key? key, required this.task, required this.scaffoldKey})
      : super(key: key);

  void _goToTaskCreationPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskCreationScreen(
          detail: true,
          idTask: task!.getId,
          type: 'inspection',
        ),
      ),
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
                child: Text(
                  'I',
                  style: GoogleFonts.merriweather(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                          '${task!.getWorkNumber}',
                          style: TextStyle(fontSize: fontSize),
                        ),
                      )),
                  const SizedBox(width: 20),
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
                                parseDateTimeOnFormatHour(task!.getAddDate!),
                                style: TextStyle(fontSize: fontSizeInfo),
                              ),
                              Text(
                                task!.getUser!,
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
        bool result = await _deleteTask(context, task!.id!);

        if (result) {
          print('Tarea ha sido eliminada correctamente');
          await showCustomMessageDialog(
            context: showDialogContext,
            messageType: DialogMessageType.success,
            onAcceptPressed: () {},
          );
        } else {
          print('No se pudo eliminar la tarea');
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
    final userName =
        Provider.of<TaskFilterProvider>(context, listen: false).userNameFilter;
    final status =
        Provider.of<TaskFilterProvider>(context, listen: false).lastStatus;
    final taskListViewModel =
        Provider.of<TaskListViewModel>(context, listen: false);
    taskListViewModel.clearListByStatus(status!);
    await taskListViewModel.initializeTasks(context, status, userName);
  }

  Future<bool> _deleteTask(BuildContext context, int id) async {
    final token = context.read<UserProvider>().getToken;
    final taskListViewModel =
        Provider.of<TaskListViewModel>(context, listen: false);
    bool result = await taskListViewModel.deleteTask(token!, id);
    return result;
  }
}
