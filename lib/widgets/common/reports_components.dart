import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/viewmodels/scheduled_viewmodel.dart';
import 'package:gtau_app_front/widgets/common/custom_elevated_button.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/scheduled/report.dart';
import '../../providers/user_provider.dart';
import '../../utils/date_utils.dart';

class ReportComponent extends StatefulWidget {
  int scheduledId;

  ReportComponent({Key? key, required this.scheduledId}) : super(key: key);

  @override
  State<ReportComponent> createState() => _ReportComponentState();
}

class _ReportComponentState extends State<ReportComponent> {
  bool isHovered = false;
  Report? report;
  late ScheduledViewModel scheduledViewModel;
  late String token;

  @override
  initState() {
    super.initState();
    scheduledViewModel =
        Provider.of<ScheduledViewModel>(context, listen: false);
    token = Provider.of<UserProvider>(context, listen: false).getToken!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getReport();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void getReport() async {
    try {
      Report? response = await scheduledViewModel.fetchReportScheduled(
          token, widget.scheduledId);
      report = response;
    } catch (error) {}
  }

  void postReport() async {
    try {
      Report? response = await scheduledViewModel.postReportScheduled(
          token, widget.scheduledId);
      setState(() {
        report = response;
      });
    } catch (error) {}
  }

  Future<void> downloadReport() async {
    if (report != null && report!.url != null) {
      if (await canLaunchUrl(Uri.parse(report!.url!))) {
        await launchUrl(Uri.parse(report!.url!));
      } else {
        throw 'Could not launch ${report!.url!}';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    return Consumer<ScheduledViewModel>(
        builder: (context, scheduledViewModel, child) {
      return Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: MouseRegion(
                onEnter: (_) {
                  setState(() {
                    isHovered = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    isHovered = false;
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        downloadReport();
                      },
                      iconSize: 60,
                      icon: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: lightBackground.withOpacity(0.5),
                            border: Border.all(
                                strokeAlign: 1,
                                color: Colors.black.withOpacity(0.35))),
                        child: Icon(
                          report != null
                              ? Icons.download_rounded
                              : Icons.file_download_off,
                          color: report != null
                              ? primarySwatch[700]
                              : bucketDelete,
                        ),
                      ),
                    ),
                    if (isHovered && report == null)
                      Container(
                        decoration: BoxDecoration(
                          color: primarySwatch[900]!.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: TextButton(
                          onPressed: () {
                            downloadReport();
                          },
                          child: Text(
                            appLocalizations.report_not_processed,
                            style: TextStyle(color: lightBackground),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (report != null)
            Text(
              '${appLocalizations.report_date_msg} ${parseDateTimeOnFormatHourUy(report!.date!)}',
              style: const TextStyle(fontSize: 14.0),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomElevatedButton(
                backgroundColors: [primarySwatch[700]!, primarySwatch[700]!],
                showLoading: scheduledViewModel.isLoadingReport,
                onPressed: () {
                  postReport();
                },
                maxWidth: 120,
                text: appLocalizations.report_process,
              ),
            ],
          )
        ],
      );
    });
  }
}
