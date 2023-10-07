import 'package:flutter/cupertino.dart';
import 'package:gtau_app_front/widgets/common/register_detail.dart';
import 'package:gtau_app_front/widgets/common/section_detail.dart';

import '../../models/enums/element_type.dart';
import 'catchment_detail.dart';

class DetailElementWidget extends StatefulWidget {
  final ElementType? elementType;

  const DetailElementWidget({Key? key, this.elementType}) : super(key: key);

  @override
  State<DetailElementWidget> createState() => _DetailWidgetState();
}

class _DetailWidgetState extends State<DetailElementWidget> {
  @override
  Widget build(BuildContext context) {
    switch (widget.elementType) {
      case ElementType.catchment:
        return const CatchmentDetail();
      case ElementType.register:
        return const RegisterDetail();
      case ElementType.section:
        return const SectionDetail();
      default:
        throw Exception('Invalid status string: ${widget.elementType}');
    }
  }
}
