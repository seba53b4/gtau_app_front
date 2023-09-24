import 'package:flutter/material.dart';
import 'package:gtau_app_front/models/enums/element_type.dart';
import 'package:gtau_app_front/widgets/common/catchment_detail.dart';
import 'package:gtau_app_front/widgets/common/register_detail.dart';
import 'package:gtau_app_front/widgets/common/section_detail.dart';

class ElementDetailWeb extends StatefulWidget {
  final ElementType? elementType;
  final int? elementId;

  const ElementDetailWeb(
      {Key? key, required this.elementType, required this.elementId})
      : super(key: key);

  @override
  State<ElementDetailWeb> createState() => _ElementDetailWebState();
}

class _ElementDetailWebState extends State<ElementDetailWeb> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.elementType == null) {
      return CircularProgressIndicator();
    }
    switch (widget.elementType) {
      case ElementType.catchment:
        return CatchmentDetail();
      case ElementType.register:
        return RegisterDetail();
      case ElementType.section:
        return SectionDetail();
      default:
        throw Exception('Invalid status string: ${widget.elementType}');
    }
  }
}
