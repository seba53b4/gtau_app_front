import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/widgets/common/scheduled_form_common.dart';

import '../../constants/theme_constants.dart';
import '../../utils/date_utils.dart';
import 'container_divider.dart';

class ScheduledInspectionDetails extends StatelessWidget {
  final String username;
  final DateTime inspectionedDate;

  const ScheduledInspectionDetails({super.key,
    required this.username,
    required this.inspectionedDate,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128,
      child: ContainerBottomDivider(
        children: [
          ScheduledFormTitle(
              titleText: AppLocalizations.of(context)!.taskInspectionTitle),
          Center(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  '${AppLocalizations.of(context)!.user}: $username',
                  style: TextStyle(
                    color: primarySwatch[400],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${AppLocalizations.of(context)!
                      .createTaskPage_realizationDateTitle}: ${parseDateTimeOnFormatHour(
                      inspectionedDate)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
