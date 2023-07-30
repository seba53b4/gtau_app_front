import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gtau_app_front/models/task.dart';
import 'package:gtau_app_front/screens/TaskCreationScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../viewmodels/task_list_viewmodel.dart';
import 'common/customDialog.dart';
import 'common/customMessageDialog.dart';
import 'package:http/http.dart' as http;

class TaskListItem extends StatelessWidget {
  final Task task;

  const TaskListItem({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final isAdmin = context.read<UserProvider>().isAdmin;

    return ListTile(
      contentPadding: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      tileColor: Colors.white,
      subtitle: Text('${task.inspectionType}'),
      title: Text('${task.getWorkNumber}'),
      leading: const Icon(Icons.check),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskCreationScreen(detail: true, idTask: task.getId, type: 'inspection',)),
              );
            },
            child: Text(AppLocalizations.of(context)!.taskListEditButtonLabel),
          ),
          const SizedBox(width: 10),
          if (isAdmin != null && isAdmin)
          ElevatedButton(
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.taskListDeleteButtonLabel),
          ),
        ],
      ),
    );
  }


  void _showDeleteConfirmationDialog(BuildContext context) {
    showCustomDialog(
      context: context,
      title: AppLocalizations.of(context)!.dialogWarning,
      content: AppLocalizations.of(context)!.dialogContent,
      onDisablePressed: () {
        Navigator.of(context).pop();
      },
      onEnablePressed: () {
        _deleteTask(context, task.id!);
        Navigator.of(context).pop();
      },
      acceptButtonLabel: AppLocalizations.of(context)!.dialogAcceptButton,
      cancelbuttonLabel: AppLocalizations.of(context)!.dialogCancelButton,
    );
  }

  Future<bool> _deleteTask(BuildContext context, int id) async {

    final taskListViewModel = Provider.of<TaskListViewModel>(context, listen: false);
    bool result = await taskListViewModel.deleteTask(context, id);
      if (result) {
        print('Tarea ha sido eliminada correctamente');
        showCustomMessageDialog(context: context, messageType: DialogMessageType.success, onAcceptPressed: () {});
        return true;
      } else {
        showCustomMessageDialog(context: context, messageType: DialogMessageType.error, onAcceptPressed: () {});
        print('No se pudo eliminar la tarea');
        return false;
      }
  }
}
