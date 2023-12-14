import 'package:flutter/cupertino.dart';
import 'package:gtau_app_front/widgets/common/scheduled_form_catchment.dart';
import 'package:gtau_app_front/widgets/common/scheduled_form_register.dart';
import 'package:gtau_app_front/widgets/common/scheduled_form_section.dart';
import '../../models/enums/element_type.dart';


class ScheduledFormWidget extends StatefulWidget {
  final ElementType? elementType;
  final int scheduledid;
  final int elementId;
  final VoidCallback? onAddButtonClick;

  const ScheduledFormWidget({Key? key, this.elementType, this.onAddButtonClick, required this.scheduledid, required this.elementId}) : super(key: key);

  @override
  State<ScheduledFormWidget> createState() => _ScheduledFormWidget();
}

class _ScheduledFormWidget extends State<ScheduledFormWidget> {
  @override
  Widget build(BuildContext context) {
    return switch (widget.elementType) {
    ElementType.catchment => const ScheduledFormCatchment(),
    ElementType.register => ScheduledFormRegister(registerId: widget.elementId, scheduledId: widget.scheduledid),
    ElementType.section =>  ScheduledFormSection(sectionId: widget.elementId, scheduledId: widget.scheduledid),
    _ => throw Exception('Invalid status string: ${widget.elementType}')
  };
  }
}
