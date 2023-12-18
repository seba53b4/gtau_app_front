import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/models/task_status.dart';

String parseTaskStatus(BuildContext context, String status) {
  TaskStatus taskStatus = getTaskStatusFromString(status);
  switch (taskStatus) {
    case TaskStatus.Doing:
      return AppLocalizations.of(context)!.task_status_doing;
    case TaskStatus.Pending:
      return AppLocalizations.of(context)!.task_status_pending;
    case TaskStatus.Blocked:
      return AppLocalizations.of(context)!.task_status_blocked;
    case TaskStatus.Done:
      return AppLocalizations.of(context)!.task_status_done;
  }
}
