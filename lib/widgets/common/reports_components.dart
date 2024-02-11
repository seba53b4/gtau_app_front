import 'package:flutter/material.dart';
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
                      icon: report == null
                          ? const Icon(Icons.file_download_off)
                          : const Icon(Icons.download_rounded),
                      iconSize: 50,
                      onPressed: () {
                        downloadReport();
                      },
                    ),
                    if (isHovered)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: TextButton(
                          onPressed: () {
                            downloadReport();
                          },
                          child: Text(
                            report == null ? 'No Procesado' : 'Descargar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Text(
            report == null
                ? 'Sin Datos'
                : 'Fecha último procesamiento: ${parseDateTimeOnFormatHour(report!.date!)}',
            style: const TextStyle(fontSize: 14.0),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomElevatedButton(
                showLoading: scheduledViewModel.isLoadingReport,
                onPressed: () {
                  postReport();
                },
                maxWidth: 120,
                text: 'Procesar reporte',
              ),
            ],
          )
        ],
      );
    });
  }
}
