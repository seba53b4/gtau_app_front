import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/models/shape_load/catchment_feature.dart';
import 'package:gtau_app_front/models/shape_load/lot_feature.dart';
import 'package:gtau_app_front/models/shape_load/register_feature.dart';
import 'package:gtau_app_front/models/shape_load/section_feature.dart';
import 'package:gtau_app_front/widgets/common/box_container.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../models/enums/message_type.dart';
import '../providers/user_provider.dart';
import '../utils/geojson_utils.dart';
import '../utils/messagesUtils.dart';
import '../viewmodels/shape_load_viewmodel.dart';
import '../widgets/common/customDialog.dart';
import '../widgets/common/custom_elevated_button.dart';
import '../widgets/common/file_upload_component.dart';
import '../widgets/common/info_icon.dart';

class UpdateElementsScreen extends StatefulWidget {
  const UpdateElementsScreen({Key? key}) : super(key: key);

  @override
  State<UpdateElementsScreen> createState() => _UpdateElementsScreenState();
}

class _UpdateElementsScreenState extends State<UpdateElementsScreen> {
  late Map<String, dynamic> geojsonFromFile = {};
  bool errorFileUpload = false;
  Map<int, bool> options = {};
  int optionSelected = 0;
  bool processing = false;
  late ShapeLoadViewModel? shapeLoadViewModel;
  late String token;
  bool isPreparing = false;
  bool isValidFile = false;

  @override
  void initState() {
    super.initState();
    options = {
      for (var index in List<int>.generate(4, (index) => index))
        index: (index == 0),
    };
  }

  @override
  void dispose() {
    super.dispose();
    shapeLoadViewModel?.reset();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    token = Provider.of<UserProvider>(context, listen: false).getToken!;
    shapeLoadViewModel =
        Provider.of<ShapeLoadViewModel>(context, listen: false);
  }

  void optionsDeleteOptions() {
    setState(() {
      options = {
        for (var index in List<int>.generate(4, (index) => index)) index: false
      };
    });
  }

  void updateSwitchSelection(int index, bool val) {
    optionsDeleteOptions();
    setState(() {
      options.update(index, (value) => val);
    });
  }

  int findSelectedIndex() {
    for (var entry in options.entries) {
      if (entry.value == true) {
        return entry.key;
      }
    }
    return -1;
  }

  bool checkLinesDataOnSelection(int selectedIndex, List<dynamic> linesData) {
    try {
      switch (selectedIndex) {
        case 0:
          SectionFeature.fromJson(linesData.first);
        case 1:
          CatchmentFeature.fromJson(linesData.first);
        case 2:
          RegisterFeature.fromJson(linesData.first);
        case 3:
          LotFeature.fromJson(linesData.first);
        default:
          return false;
      }
      return true;
    } catch (error) {
      showGenericModalError(
          context: context,
          message:
              AppLocalizations.of(context)!.shape_laod_file_format_error_msg);
      return false;
    }
  }

  void initializeProcess(int selectedIndex, List<dynamic> linesData) {
    switch (selectedIndex) {
      case 0:
        shapeLoadViewModel!.initializeProcessShapeLoad(
            token: token, entityType: 'TRAMOS', linesTramos: linesData);
        break;
      case 1:
        shapeLoadViewModel!.initializeProcessShapeLoad(
            token: token,
            entityType: 'CAPTACIONES',
            linesCaptaciones: linesData);
      case 2:
        shapeLoadViewModel!.initializeProcessShapeLoad(
            token: token, entityType: 'REGISTROS', linesRegistros: linesData);
      case 3:
        shapeLoadViewModel!.initializeProcessShapeLoad(
            token: token, entityType: 'PARCELAS', linesParcelas: linesData);
      default:
        throw Error();
    }
  }

  Future<void> manageLoadShapeProcess() async {
    setState(() {
      isPreparing = true;
    });

    int selectedIndex = findSelectedIndex();
    final List<dynamic> linesData = getFeaturesArray(geojsonFromFile);

    if (checkLinesDataOnSelection(selectedIndex, linesData)) {
      shapeLoadViewModel!.initWS();
      await shapeLoadViewModel!.waitForWebSocketConnection();
      setState(() {
        isPreparing = false;
      });
      initializeProcess(selectedIndex, linesData);
    } else {
      setState(() {
        isPreparing = false;
      });
    }
  }

  void handleSubmitTask() {
    showCustomDialog(
      context: context,
      title: AppLocalizations.of(context)!.dialogWarning,
      content: AppLocalizations.of(context)!.dialogContent,
      onDisablePressed: () {
        Navigator.of(context).pop();
      },
      onEnablePressed: () async {
        Navigator.of(context).pop();
        await manageLoadShapeProcess();
      },
      acceptButtonLabel: AppLocalizations.of(context)!.dialogAcceptButton,
      cancelbuttonLabel: AppLocalizations.of(context)!.dialogCancelButton,
    );
  }

  @override
  Widget build(BuildContext context) {
    double widthContent = 480;
    final appLocalizations = AppLocalizations.of(context)!;
    return Consumer<ShapeLoadViewModel>(
        builder: (context, shapeLoadViewModel, child) {
      bool isMaxSize = (shapeLoadViewModel.result ?? false);
      List<String> errorsLines =
          shapeLoadViewModel.linesError.map<String>((error) {
        return error.toString();
      }).toList();
      if (shapeLoadViewModel.result != null) {
        geojsonFromFile = {};
      }
      return LoadingOverlay(
        isLoading: false,
        child: Center(
            child: BoxContainer(
                height: isMaxSize
                    ? 800
                    : errorFileUpload
                        ? 480
                        : 460,
                width: 600,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Carga de Elementos',
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Tipo de Elemento       ',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                        width: widthContent,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomSwitchButton(
                              value: options[0]!,
                              onPressed: (bool val) {
                                updateSwitchSelection(0, val);
                              },
                              text: appLocalizations.sections,
                            ),
                            CustomSwitchButton(
                              value: options[1]!,
                              onPressed: (bool val) {
                                updateSwitchSelection(1, val);
                              },
                              text: appLocalizations.catchments,
                            ),
                            CustomSwitchButton(
                              value: options[2]!,
                              onPressed: (bool val) {
                                updateSwitchSelection(2, val);
                              },
                              text: appLocalizations.registers,
                            ),
                            CustomSwitchButton(
                              value: options[3]!,
                              onPressed: (bool val) {
                                updateSwitchSelection(3, val);
                              },
                              text: appLocalizations.lots,
                            ),
                          ],
                        )),
                    const SizedBox(height: 24),
                    Visibility(
                      visible: !isPreparing && !shapeLoadViewModel.processing,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                appLocalizations.scheduled_file_title,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              InfoIcon(
                                  message: appLocalizations
                                      .info_icon_msg_file_upload),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: widthContent,
                            child: FileUploadComponent(
                              errorVisible: errorFileUpload,
                              errorMessage: appLocalizations
                                  .info_icon_msg_file_upload_error,
                              onDeleteSelection: () {
                                setState(() {
                                  errorFileUpload = false;
                                  isValidFile = false;
                                  geojsonFromFile = {};
                                });
                              },
                              onFileAdded: (Map<String, dynamic> fileContent) {
                                setState(() {
                                  geojsonFromFile = fileContent;
                                  isValidFile = false;
                                  shapeLoadViewModel.reset();
                                  errorFileUpload = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: isMaxSize ? 36 : 24,
                    ),
                    Visibility(
                      visible: !isPreparing && !shapeLoadViewModel.processing,
                      child: CustomElevatedButton(
                          text: appLocalizations.shape_load_process_button,
                          onPressed: () async {
                            setState(() {
                              shapeLoadViewModel.reset();
                            });
                            if (geojsonFromFile.isEmpty) {
                              setState(() {
                                errorFileUpload = true;
                              });
                            } else {
                              handleSubmitTask();
                            }
                          }),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Visibility(
                      visible: isPreparing || shapeLoadViewModel.processing,
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              isPreparing
                                  ? appLocalizations.shape_load_init
                                  : shapeLoadViewModel.processing
                                      ? appLocalizations.shape_load_proccesing
                                      : appLocalizations.shape_load_init,
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 12),
                            LoadingAnimationWidget.waveDots(
                              color: primarySwatch[400]!,
                              size: 42,
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    if (isMaxSize) const SizedBox(height: 24),
                    Visibility(
                      visible: shapeLoadViewModel.processing ||
                          (shapeLoadViewModel.result ?? false) ||
                          isPreparing,
                      child: SizedBox(
                        width: widthContent,
                        child: LinearPercentIndicator(
                          width: widthContent,
                          animation: false,
                          lineHeight: 32.0,
                          animationDuration: 500,
                          percent: shapeLoadViewModel.percent,
                          center: Text(
                              "${(shapeLoadViewModel.percent * 100).toStringAsFixed(0)}%",
                              style: TextStyle(color: primarySwatch[800]!)),
                          barRadius: const Radius.circular(20),
                          backgroundColor: lightBackground,
                          linearGradient: LinearGradient(
                            colors: [primarySwatch[50]!, primarySwatch[100]!],
                          ),
                        ),
                      ),
                    ),
                    if (isMaxSize) const SizedBox(height: 24),
                    Visibility(
                        visible: shapeLoadViewModel.result ?? false,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(shapeLoadViewModel.result ?? false
                                ? shapeLoadViewModel.linesError.isEmpty
                                    ? appLocalizations.shape_laod_success
                                    : appLocalizations.shape_laod_with_errors
                                : appLocalizations.shape_laod_with_errors),
                            const SizedBox(width: 6),
                            InfoIcon(
                                message:
                                    appLocalizations.shape_load_error_info),
                          ],
                        )),
                    if (isMaxSize) const SizedBox(height: 24),
                    Visibility(
                      visible: shapeLoadViewModel.result ?? false,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: lightBackground,
                        ),
                        height: 200,
                        width: widthContent - 120,
                        child: ListView.builder(
                          itemCount: errorsLines.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.045),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: ListTile(
                                iconColor: Colors.red,
                                leading:
                                    const Icon(Icons.error, color: Colors.red),
                                textColor: Colors.black87,
                                title: Text(
                                  errorsLines[index],
                                  style: const TextStyle(
                                      color: Colors.black87, fontSize: 12),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ))),
      );
    });
  }
}

class CustomSwitchButton extends StatelessWidget {
  final Function(bool) onPressed;
  final bool value;
  final String text;
  final Color? textColor;
  final MessageType? messageType;
  final Color? backgroundColor;

  const CustomSwitchButton({
    super.key,
    required this.onPressed,
    required this.value,
    required this.text,
    this.textColor,
    this.messageType = MessageType.success,
    this.backgroundColor = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    return CustomElevatedButton(
      onPressed: () {
        onPressed(!value);
      },
      textColor: textColor ?? (value ? lightBackground : primarySwatch[500]!),
      messageType: value ? messageType : null,
      backgroundColor: value ? null : backgroundColor,
      text: text,
    );
  }
}
