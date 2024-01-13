import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'custom_labeled_checkbox.dart';

class TopStatusOptions extends StatefulWidget {
  final Function(Map<String, bool>) onChanged;
  final Map<String, bool>? initialCheckboxStates;

  TopStatusOptions(
      {required this.onChanged, this.initialCheckboxStates, Key? key})
      : super(key: key);

  @override
  _TopStatusOptionsState createState() => _TopStatusOptionsState();
}

class _TopStatusOptionsState extends State<TopStatusOptions> {
  late Map<String, bool> checkboxStates;
  Key? widgetKey;

  @override
  void initState() {
    super.initState();
    widgetKey = UniqueKey();
    checkboxStates = widget.initialCheckboxStates ??
        {for (var label in checkboxLabels) label: false};
  }

  @override
  void didUpdateWidget(covariant TopStatusOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCheckboxStates != oldWidget.initialCheckboxStates) {
      widgetKey = UniqueKey();
      setState(() {
        checkboxStates = widget.initialCheckboxStates ??
            {for (var label in checkboxLabels) label: false};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: widgetKey,
      children: [
        for (var label in checkboxLabels) _buildCheckbox(context, label: label),
      ],
    );
  }

  Widget _buildCheckbox(BuildContext context, {required String label}) {
    return CustomLabeledCheckbox(
      key: ValueKey(label),
      label: getLabelOfCheckbox(context, label),
      initialValue: widget.initialCheckboxStates?[label] ?? false,
      onChanged: (value) {
        setState(() {
          checkboxStates[label] = value ?? false;
          widget.onChanged(checkboxStates);
        });
      },
    );
  }

  static String getLabelOfCheckbox(BuildContext context, String key) {
    switch (key) {
      case 'good':
        return AppLocalizations.of(context)!.form_scheduled_top_status_good;
      case 'missing':
        return AppLocalizations.of(context)!.form_scheduled_top_status_missing;
      case 'fsunken':
        return AppLocalizations.of(context)!.form_scheduled_top_status_sunken;
      case 'fframe':
        return AppLocalizations.of(context)!.form_scheduled_top_status_frame;
      case 'broken_frame':
        return AppLocalizations.of(context)!
            .form_scheduled_top_status_broken_frame;
      case 'provisional':
        return AppLocalizations.of(context)!
            .form_scheduled_top_status_provisional;
      case 'broken':
        return AppLocalizations.of(context)!.form_scheduled_top_status_broken;
      case 'welded_sealed':
        return AppLocalizations.of(context)!
            .form_scheduled_top_status_welded_sealed;
      default:
        return '';
    }
  }

  static const List<String> checkboxLabels = [
    'good',
    'missing',
    'fsunken',
    'fframe',
    'broken_frame',
    'provisional',
    'broken',
    'welded_sealed',
  ];
}
