import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.read<UserProvider>().isAdmin;

    return Container(
      width: 80,
      margin: const EdgeInsets.all(8), // Margen exterior
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // Bordes redondeados
        color: lightBackground,
        // border: Border.all(
        //   // Aquí defines el borde
        //   color: primarySwatch[50]!, // Color del borde
        //   width: 2.0, // Ancho del borde
        // ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(200, 217, 184, 0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ], // Color de fondo
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        // Relleno interior
        tileColor: Colors.transparent,
        // Color de fondo del ListTile
        horizontalTitleGap: 20,
        subtitle: Text(
          '${task!.inspectionType}',
          style: const TextStyle(fontSize: 15),
        ),
        title: Text('${task!.getWorkNumber}'),
        leading: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
          child: CircleAvatar(
            backgroundColor: primarySwatch[900],
            // Cambia el color de fondo del círculo según tus preferencias
            radius: 20,
            // Tamaño del círculo
            child: const Icon(Icons.abc_sharp,
                color: Colors
                    .white), // Puedes usar un Icon o una imagen en lugar del Icon
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (kIsWeb)
              const VerticalDivider(
                color: Colors.black,
                width: 20, // Ancho de la línea vertical
              ),
            if (kIsWeb)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                // Alinea el texto a la izquierda
                children: [
                  Align(
                    alignment: Alignment.centerLeft, // Centra verticalmente
                    child: Text(
                      parseDateTimeOnFormatHour(task!.getAddDate!),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft, // Centra verticalmente
                    child: Text(
                      task!.getUser!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            const SizedBox(width: 24),
            IconButton(
              onPressed: () {
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
              },
              icon: const Icon(Icons.edit),
            ),
            //const SizedBox(width: 4),
            Visibility(
              visible: isAdmin != null && isAdmin,
              child: IconButton(
                onPressed: () async {
                  await _showDeleteConfirmationDialog(context);
                },
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
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
